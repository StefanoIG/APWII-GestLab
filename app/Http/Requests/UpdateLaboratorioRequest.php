<?php
namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateLaboratorioRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->rol->nombre === 'Administrador';
    }

    public function rules(): array
    {
        // El 'id' del laboratorio se obtiene de la ruta
        $laboratorioId = $this->route('laboratorio')->id;
        
        return [
            // El nombre debe ser único, ignorando el laboratorio actual
            'nombre' => 'sometimes|required|string|max:255|unique:laboratorios,nombre,' . $laboratorioId,
            'capacidad' => 'sometimes|required|integer|min:1',
            'descripcion' => 'nullable|string',
            'estado' => 'sometimes|required|in:activo,inactivo,mantenimiento',
        ];
    }
}