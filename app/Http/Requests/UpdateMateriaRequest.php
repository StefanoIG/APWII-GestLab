<?php
namespace App\Http\Requests;
use Illuminate\Foundation\Http\FormRequest;

class UpdateMateriaRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->rol->nombre === 'Administrador';
    }

    public function rules(): array
    {
        $materiaId = $this->route('materia')->id;
        return [
            'nombre' => 'sometimes|required|string|max:255',
            'codigo' => 'sometimes|required|string|max:50|unique:materias,codigo,' . $materiaId,
        ];
    }
}