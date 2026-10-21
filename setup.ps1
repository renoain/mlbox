[CmdletBinding()]
param(
    [switch]$Fresh,
    [switch]$SkipDemo
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

function Write-Step {
    param([string]$Message)
    Write-Host ''
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Write-Ok {
    param([string]$Message)
    Write-Host "    OK: $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "    $Message" -ForegroundColor Yellow
}

function Resolve-Executable {
    param(
        [string]$Name,
        [string[]]$FallbackPatterns
    )

    $command = Get-Command $Name -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    foreach ($pattern in $FallbackPatterns) {
        $found = Get-Item $pattern -ErrorAction SilentlyContinue |
            Sort-Object FullName -Descending |
            Select-Object -First 1
        if ($found) {
            return $found.FullName
        }
    }

    return $null
}

function Get-EnvValue {
    param(
        [string]$Path,
        [string]$Key
    )

    if (-not (Test-Path $Path)) {
        return $null
    }

    $escapedKey = [regex]::Escape($Key)
    $line = Get-Content -Path $Path |
        Where-Object { $_ -match "^\s*$escapedKey\s*=" } |
        Select-Object -Last 1

    if (-not $line) {
        return $null
    }

    $value = ($line -split '=', 2)[1]
    if ($null -eq $value) {
        return ''
    }

    $value = $value.Trim()
    if ($value.Length -ge 2) {
        $first = $value.Substring(0, 1)
        $last = $value.Substring($value.Length - 1, 1)
        if (($first -eq '"' -and $last -eq '"') -or ($first -eq "'" -and $last -eq "'")) {
            $value = $value.Substring(1, $value.Length - 2)
        }
    }

    return $value
}

function Invoke-Checked {
    param(
        [string]$FilePath,
        [string[]]$Arguments,
        [string]$ErrorMessage
    )

    & $FilePath @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "$ErrorMessage (exit code $LASTEXITCODE)"
    }
}

if (-not (Test-Path (Join-Path $repoRoot 'backend\artisan')) -or
    -not (Test-Path (Join-Path $repoRoot 'pubspec.yaml'))) {
    throw 'Jalankan setup.ps1 dari folder root proyek mlbox.'
}

Set-Location $repoRoot

Write-Step 'Memeriksa prasyarat'

$php = Resolve-Executable -Name 'php' -FallbackPatterns @(
    'C:\laragon\bin\php\php-*\php.exe',
    'C:\xampp\php\php.exe'
)
if (-not $php) {
    throw 'PHP tidak ditemukan. Install PHP 8.3+ atau buka Terminal dari Laragon.'
}

$phpVersionText = ((& $php -r 'echo PHP_VERSION;') -join '').Trim()
$phpVersion = [version]$phpVersionText
if ($phpVersion -lt [version]'8.3.0') {
    throw "PHP $phpVersionText terlalu lama. Proyek ini membutuhkan PHP 8.3+."
}
Write-Ok "PHP $phpVersionText ($php)"

$composer = Resolve-Executable -Name 'composer' -FallbackPatterns @(
    'C:\laragon\bin\composer\composer.bat',
    'C:\ProgramData\ComposerSetup\bin\composer.bat'
)
if (-not $composer) {
    throw 'Composer tidak ditemukan. Install Composer atau gunakan Terminal Laragon.'
}

$flutter = Resolve-Executable -Name 'flutter' -FallbackPatterns @(
    'C:\flutter\bin\flutter.bat',
    'C:\src\flutter\bin\flutter.bat'
)
if (-not $flutter) {
    throw 'Flutter tidak ditemukan. Install Flutter SDK dan pastikan ada di PATH.'
}
Write-Ok "Flutter ($flutter)"

$mysql = Resolve-Executable -Name 'mysql' -FallbackPatterns @(
    'C:\laragon\bin\mysql\mysql-*\bin\mysql.exe',
    'C:\xampp\mysql\bin\mysql.exe',
    'C:\Program Files\MySQL\MySQL Server*\bin\mysql.exe'
)

Write-Step 'Menyiapkan dependency Flutter'
Invoke-Checked -FilePath $flutter -Arguments @('pub', 'get') -ErrorMessage 'flutter pub get gagal'
Write-Ok 'Dependency Flutter siap'

$backend = Join-Path $repoRoot 'backend'
Push-Location $backend
try {
    Write-Step 'Menyiapkan backend Laravel'

    if (-not (Test-Path 'vendor\autoload.php')) {
        Write-Step 'Install dependency backend'
        Invoke-Checked -FilePath $composer -Arguments @('install', '--no-interaction') -ErrorMessage 'composer install gagal'
    }
    else {
        Write-Ok 'Dependency backend sudah terpasang'
    }

    if (-not (Test-Path '.env')) {
        Copy-Item '.env.example' '.env'
        Write-Ok '.env dibuat dari .env.example'
    }
    else {
        Write-Ok 'backend/.env sudah ada'
    }

    $appKey = Get-EnvValue -Path '.env' -Key 'APP_KEY'
    if ([string]::IsNullOrWhiteSpace($appKey)) {
        Write-Step 'Generate APP_KEY'
        Invoke-Checked -FilePath $php -Arguments @('artisan', 'key:generate', '--force') -ErrorMessage 'Gagal generate APP_KEY'
    }

    $dbConnection = Get-EnvValue -Path '.env' -Key 'DB_CONNECTION'
    if ([string]::IsNullOrWhiteSpace($dbConnection)) {
        $dbConnection = 'mysql'
    }

    if ($dbConnection -eq 'sqlite') {
        if (-not (Test-Path 'database\database.sqlite')) {
            New-Item -ItemType File -Path 'database\database.sqlite' | Out-Null
            Write-Ok 'Database SQLite dibuat'
        }
    }
    elseif ($dbConnection -eq 'mysql' -or $dbConnection -eq 'mariadb') {
        $dbHost = Get-EnvValue -Path '.env' -Key 'DB_HOST'
        $dbPort = Get-EnvValue -Path '.env' -Key 'DB_PORT'
        $dbDatabase = Get-EnvValue -Path '.env' -Key 'DB_DATABASE'
        $dbUsername = Get-EnvValue -Path '.env' -Key 'DB_USERNAME'
        $dbPassword = Get-EnvValue -Path '.env' -Key 'DB_PASSWORD'

        if ([string]::IsNullOrWhiteSpace($dbHost)) { $dbHost = '127.0.0.1' }
        if ([string]::IsNullOrWhiteSpace($dbPort)) { $dbPort = '3306' }
        if ([string]::IsNullOrWhiteSpace($dbUsername)) { $dbUsername = 'root' }
        if ($null -eq $dbPassword) { $dbPassword = '' }

        if ([string]::IsNullOrWhiteSpace($dbDatabase)) {
            throw 'DB_DATABASE kosong di backend/.env.'
        }
        if ($dbDatabase -notmatch '^[A-Za-z0-9_]+$') {
            throw "Nama database tidak valid: $dbDatabase"
        }

        Write-Step "Membuat database $dbDatabase jika belum ada"
        if (-not $mysql) {
            throw 'Client mysql tidak ditemukan. Jalankan lewat Terminal Laragon atau buat database secara manual.'
        }

        $mysqlArguments = @(
            "--host=$dbHost",
            "--port=$dbPort",
            "--user=$dbUsername",
            '--protocol=TCP',
            '--execute',
            "CREATE DATABASE IF NOT EXISTS $dbDatabase CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
        )
        if (-not [string]::IsNullOrEmpty($dbPassword)) {
            $mysqlArguments = @("--password=$dbPassword") + $mysqlArguments
        }

        & $mysql @mysqlArguments
        if ($LASTEXITCODE -ne 0) {
            throw 'Gagal membuat database. Pastikan MySQL Laragon sudah Start All dan kredensial di backend/.env benar.'
        }
        Write-Ok "Database $dbDatabase siap"
    }
    else {
        Write-Warn "DB_CONNECTION=$dbConnection tidak dikenali. Lewati pembuatan database."
    }

    Invoke-Checked -FilePath $php -Arguments @('artisan', 'config:clear') -ErrorMessage 'Gagal clear config Laravel'

    if ($Fresh) {
        Write-Warn 'Mode -Fresh: semua tabel dan data lama akan dihapus.'
        Write-Step 'Menjalankan migrate:fresh --seed'
        Invoke-Checked -FilePath $php -Arguments @('artisan', 'migrate:fresh', '--seed', '--force') -ErrorMessage 'Migrasi database gagal'
    }
    else {
        Write-Step 'Menjalankan migrate --seed'
        Invoke-Checked -FilePath $php -Arguments @('artisan', 'migrate', '--seed', '--force') -ErrorMessage 'Migrasi database gagal'
    }

    if (-not $SkipDemo) {
        $userCount = 0
        $countOutput = ((& $php artisan tinker --execute="echo \App\Models\User::where('role','user')->count();" 2>$null) -join '').Trim()
        if ($countOutput -match '(\d+)') {
            $userCount = [int]$Matches[1]
        }

        if ($userCount -lt 100) {
            Write-Step 'Mengisi data demo (100 user, review, like, diary)'
            Invoke-Checked -FilePath $php -Arguments @('artisan', 'db:seed', '--class=DemoContentSeeder', '--force') -ErrorMessage 'Seeder data demo gagal'
        }
        else {
            Write-Ok "Data demo sudah ada ($userCount user), seeder demo dilewati"
        }
    }

    if (-not (Test-Path 'public\storage')) {
        Write-Step 'Membuat storage link untuk poster'
        Invoke-Checked -FilePath $php -Arguments @('artisan', 'storage:link') -ErrorMessage 'Gagal membuat storage link'
    }
    else {
        Write-Ok 'Storage link sudah ada'
    }
}
finally {
    Pop-Location
}

Write-Host ''
Write-Host 'Setup selesai.' -ForegroundColor Green
Write-Host ''
Write-Host 'Jalankan backend di Terminal 1:'
Write-Host '  cd backend'
Write-Host '  php artisan serve'
Write-Host ''
Write-Host 'Jalankan Flutter di Terminal 2 (dari root proyek):'
Write-Host '  flutter run -d chrome'
Write-Host ''
Write-Host 'Login admin : admin@mailboxh.test / password'
Write-Host 'Login user  : demo@mailboxh.test / password'
Write-Host ''
