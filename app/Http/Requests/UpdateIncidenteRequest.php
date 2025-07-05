<?php
namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateIncidenteRequest extends FormRequest
{
    public function authorize(): bool
    {
        // Solo los administradores pueden actualizar un incidente (marcarlo como resuelto)
        return $this->user()->rol->nombre === 'Administrador';
    }

    public function rules(): array
    {
        return [
            'resuelto' => 'required|boolean',
        ];
    }
}