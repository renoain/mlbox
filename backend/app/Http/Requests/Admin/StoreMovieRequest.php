<?php

declare(strict_types=1);

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

// Validasi tambah film baru oleh admin.
class StoreMovieRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'title' => ['required', 'string', 'max:255'],
            'original_title' => ['nullable', 'string', 'max:255'],
            'overview' => ['nullable', 'string'],
            'release_date' => ['nullable', 'date'],
            'poster' => ['nullable', 'image', 'mimes:jpg,jpeg,png,webp', 'max:2048'],
            'backdrop' => ['nullable', 'image', 'mimes:jpg,jpeg,png,webp', 'max:4096'],
            'runtime' => ['nullable', 'integer', 'min:1'],
            'language' => ['nullable', 'string', 'max:10'],
            'country' => ['nullable', 'string', 'max:100'],
            'cast' => ['nullable', 'string'],
            'crew' => ['nullable', 'string'],
            'is_featured' => ['nullable', 'boolean'],
            'genres' => ['nullable', 'array'],
            'genres.*' => ['integer', 'exists:genres,id'],
        ];
    }
}
