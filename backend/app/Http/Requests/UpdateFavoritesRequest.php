<?php

declare(strict_types=1);

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

// Validasi simpan empat film favorit sekaligus.
class UpdateFavoritesRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            // `present` (bukan `required`) supaya daftar kosong tetap boleh
            // dikirim, supaya semua film favorit bisa dihapus.
            'items' => ['present', 'array', 'max:4'],
            'items.*.position' => ['required', 'integer', 'min:1', 'max:4', 'distinct'],
            'items.*.movie_id' => ['required', 'integer', 'exists:movies,id', 'distinct'],
        ];
    }
}
