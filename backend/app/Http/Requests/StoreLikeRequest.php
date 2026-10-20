<?php

declare(strict_types=1);

namespace App\Http\Requests;

use App\Models\Like;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

// Validasi tanda suka polymorphic pada film, review, atau list.
class StoreLikeRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'likeable_id' => ['required', 'integer', 'min:1'],
            'likeable_type' => ['required', 'string', Rule::in(Like::TYPES)],
        ];
    }
}
