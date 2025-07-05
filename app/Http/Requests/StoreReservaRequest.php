<?php
namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreReservaRequest extends FormRequest
{
    public function authorize(): bool
    {
        // Cualquier usuario autenticado puede intentar crear una reserva
        return true; 
    }

    public function rules(): array
    {
        return [
            'laboratorio_id' => 'required|exists:laboratorios,id',
            'materia_id' => 'nullable|exists:materias,id',
            'fecha' => 'required|date|after_or_equal:today',
            'hora_inicio' => 'required|date_format:H:i',
            'hora_fin' => 'required|date_format:H:i|after:hora_inicio',
            'motivo' => 'required|string',
        ];
    }
}