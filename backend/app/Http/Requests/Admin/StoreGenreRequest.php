<?php

declare(strict_types=1);

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

// Validasi tambah genre baru oleh admin.
class StoreGenreRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:50', 'unique:genres,name'],
            'slug' => ['nullable', 'string', 'max:50', 'unique:genres,slug', 'regex:/^[a-z0-9-]+$/'],
        ];
    }
}
