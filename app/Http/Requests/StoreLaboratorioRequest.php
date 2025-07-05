<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreLaboratorioRequest extends FormRequest
{
    public function authorize(): bool
    {
        // Solo los administradores pueden crear laboratorios
        return $this->user()->rol->nombre === 'Administrador';
    }

    public function rules(): array
    {
        return [
            'nombre' => 'required|string|max:255|unique:laboratorios',
            'capacidad' => 'required|integer|min:1',
            'descripcion' => 'nullable|string',
            'estado' => 'sometimes|in:activo,inactivo,mantenimiento',
        ];
    }
}