<?php
namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use App\Models\Reserva;

class StoreIncidenteRequest extends FormRequest
{
    public function authorize(): bool
    {
        $reserva = Reserva::find($this->input('reserva_id'));

        // Permite si no existe la reserva (para que falle en la validación de 'rules' y no en 'authorize')
        if (!$reserva) {
            return true;
        }

        // Autoriza si el usuario es dueño de la reserva o es un Administrador.
        return $this->user()->id === $reserva->usuario_id || $this->user()->rol->nombre === 'Administrador';
    }

    public function rules(): array
    {
        return [
            'reserva_id' => 'required|exists:reservas,id',
            'descripcion' => 'required|string|max:2000',
        ];
    }
}