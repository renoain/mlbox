import 'package:flutter/material.dart';

/// Warna-warna yang diambil dari desain Letterboxd.
class LbColors {
  static const background = Color(0xFF181B20); // latar gelap halaman auth
  static const profileBg = Color(0xFF14181C); // latar halaman profile/settings
  static const appBarBlack = Color(0xFF000000);
  static const divider = Color(0xFF2C3440);
  static const rowLabel = Color(0xFF99AABB);
  static const muted = Color(0xFF678099);
  static const segment = Color(0xFF2C3440);
  static const segmentActive = Color(0xFF556678);
  static const green = Color(0xFF00C032); // tombol GO / JOIN
  static const orange = Color(0xFFFF8300);
  static const blue = Color(0xFF33B2F5);
  static const logoGreen = Color(0xFF04C649);
  static const fieldLine = Color(0xFFE0E1E3);
  static const fieldHint = Color(0xFFB3BAC2);
  static const tabAccent = Color(0xFF40BCF4);
}

/// Logo tiga lingkaran (oranye, hijau, biru).
class LbLogo extends StatelessWidget {
  const LbLogo({super.key, this.diameter = 26});
  final double diameter;

  @override
  Widget build(BuildContext context) {
    final step = diameter * 0.88;
    return SizedBox(
      width: diameter + step * 2,
      height: diameter,
      child: CustomPaint(painter: _LogoPainter(diameter, step)),
    );
  }
}

class _LogoPainter extends CustomPainter {
  _LogoPainter(this.d, this.step);
  final double d;
  final double step;

  @override
  void paint(Canvas canvas, Size size) {
    final r = d / 2;
    final c1 = Offset(r, r);
    final c2 = Offset(r + step, r);
    final c3 = Offset(r + step * 2, r);

    canvas.drawCircle(c1, r, Paint()..color = LbColors.orange);
    canvas.drawCircle(c2, r, Paint()..color = LbColors.logoGreen);
    canvas.drawCircle(c3, r, Paint()..color = LbColors.blue);

    // Area tumpang tindih digelapkan seperti pada logo asli.
    Path circle(Offset c) =>
        Path()..addOval(Rect.fromCircle(center: c, radius: r));
    final overlap = Paint()..color = const Color(0xFF171A1F);
    canvas.drawPath(
      Path.combine(PathOperation.intersect, circle(c1), circle(c2)),
      overlap,
    );
    canvas.drawPath(
      Path.combine(PathOperation.intersect, circle(c2), circle(c3)),
      overlap,
    );
  }

  @override
  bool shouldRepaint(covariant _LogoPainter old) =>
      old.d != d || old.step != step;
}

/// Kerangka halaman Login / Register: hero artwork, logo, judul, form putih,
/// deretan tombol kecil dan teks credit.
class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.heroAsset,
    required this.heroFraction,
    required this.title,
    required this.fields,
    required this.buttons,
    required this.credit,
    required this.onClose,
    this.contentMaxWidth = 460,
  });

  final String heroAsset;
  final double heroFraction; // tinggi hero relatif terhadap tinggi layar
  final String title;
  final List<Widget> fields;
  final Widget buttons;
  final Widget credit;
  final VoidCallback onClose;

  /// Lebar maksimum kolom konten.
  ///
  /// Poster artwork-nya vertikal (sekitar 402x580). Kalau hero-nya dibentangkan
  /// selebar layar desktop, `BoxFit.cover` akan zooming berlebihan sampai
  /// subjek potter ter-crop keluar. Dengan kolom dibatasi, artwork tampil utuh
  /// dan form putih tidak melebar excessive di monitor besar.
  final double contentMaxWidth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LbColors.background,
      body: LayoutBuilder(
        builder: (context, box) {
          final heroH = box.maxHeight * heroFraction;
          return Stack(
            children: [
              // Artwork + gradasi ke warna latar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: heroH,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: contentMaxWidth),
                        child: SizedBox.expand(
                          child: Image.asset(
                            heroAsset,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            // Gambar hero tidak boleh menggagalkan seluruh
                            // halaman kalau file-nya hilang atau rusak.
                            errorBuilder: (context, error, stackTrace) =>
                                const ColoredBox(color: LbColors.background),
                          ),
                        ),
                      ),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x00181B20), LbColors.background],
                          stops: [0.80, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: box.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: contentMaxWidth),
                      child: Column(
                        children: [
                          SizedBox(height: heroH - 8),
                          const LbLogo(),
                          const SizedBox(height: 14),
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 22),
                          Container(
                            color: Colors.white,
                            child: Column(children: fields),
                          ),
                          const SizedBox(height: 18),
                          buttons,
                          const SizedBox(height: 18),
                          credit,
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Tombol close (X) di kanan atas
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 26,
                    ),
                    onPressed: onClose,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Field putih dengan garis pemisah tipis seperti desain.
class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.hint,
    this.obscure = false,
    this.keyboardType,
    this.controller,
    this.showDivider = true,
    this.enabled = true,
    this.onSubmitted,
    this.textInputAction,
    this.autofillHints,
  });

  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final bool showDivider;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                bottom: BorderSide(color: LbColors.fieldLine, width: 1),
              )
            : null,
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        obscureText: obscure,
        keyboardType: keyboardType,
        onSubmitted: onSubmitted,
        textInputAction: textInputAction,
        autofillHints: autofillHints,
        cursorColor: LbColors.green,
        style: const TextStyle(color: Color(0xFF14181C), fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: LbColors.fieldHint, fontSize: 15),
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

/// Baris pesan error di dalam kotak form putih.
class AuthError extends StatelessWidget {
  const AuthError(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFFF1F0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFFB3261E),
          fontSize: 12.5,
          height: 1.35,
        ),
      ),
    );
  }
}

/// Baris persetujuan dengan radio bulat di kanan (halaman register).
class AuthConsentRow extends StatelessWidget {
  const AuthConsentRow({
    super.key,
    required this.child,
    required this.value,
    required this.onChanged,
    this.showDivider = true,
  });

  final Widget child;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(
                  bottom: BorderSide(color: LbColors.fieldLine, width: 1),
                )
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: DefaultTextStyle(
                style: const TextStyle(
                  color: Color(0xFF8A96A3),
                  fontSize: 11.5,
                  height: 1.3,
                ),
                child: child,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: LbColors.fieldLine, width: 1.5),
                color: value ? LbColors.green : Colors.transparent,
              ),
              child: value
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Tombol kecil outline (SIGN IN / JOIN / RESET PASSWORD).
class LbOutlineButton extends StatelessWidget {
  const LbOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;

  /// Null berarti tombol nonaktif.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: LbColors.rowLabel,
        disabledForegroundColor: LbColors.muted,
        side: const BorderSide(color: Color(0xFF45515E)),
        minimumSize: const Size(0, 28),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        textStyle: const TextStyle(
          fontSize: 10.5,
          letterSpacing: 0.6,
          fontWeight: FontWeight.w500,
        ),
      ),
      child: Text(label),
    );
  }
}

/// Tombol kecil hijau (GO / JOIN).
class LbGreenButton extends StatelessWidget {
  const LbGreenButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;

  /// Null berarti tombol nonaktif.
  final VoidCallback? onPressed;

  /// Saat true tombol menampilkan spinner dan tidak bisa ditekan.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: LbColors.green,
        disabledBackgroundColor: LbColors.green.withValues(alpha: 0.55),
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(0, 28),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        textStyle: const TextStyle(
          fontSize: 10.5,
          letterSpacing: 0.6,
          fontWeight: FontWeight.w700,
        ),
      ),
      child: isLoading
          ? const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(label),
    );
  }
}

/// Teks "Artwork from <b>Film</b>".
class AuthCredit extends StatelessWidget {
  const AuthCredit({super.key, required this.film});
  final String film;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: 'Artwork from ',
        style: const TextStyle(color: LbColors.muted, fontSize: 10.5),
        children: [
          TextSpan(
            text: film,
            style: const TextStyle(
              color: LbColors.rowLabel,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
