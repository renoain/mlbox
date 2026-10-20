<?php

declare(strict_types=1);

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

// Validasi ubah genre oleh admin.
class UpdateGenreRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $id = (int) $this->route('id');

        return [
            'name' => ['sometimes', 'string', 'max:50', Rule::unique('genres', 'name')->ignore($id)],
            'slug' => ['nullable', 'string', 'max:50', 'regex:/^[a-z0-9-]+$/', Rule::unique('genres', 'slug')->ignore($id)],
        ];
    }
}
