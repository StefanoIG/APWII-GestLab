<?php
namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;
use App\Models\Reserva;

class UpdateReservaRequest extends FormRequest
{
    public function authorize(): bool
    {
        $user = $this->user();
        $reserva = $this->route('reserva'); // Obtenemos la reserva desde la ruta

        // El admin puede hacer cualquier cambio de estado permitido.
        if ($user->rol->nombre === 'Administrador') {
            return true;
        }

        // El usuario dueño de la reserva puede cancelarla si está 'aprobada'.
        if ($user->id === $reserva->usuario_id && $reserva->estado === 'aprobada') {
            // Permitimos que solo envíen el estado 'cancelada'.
            return $this->input('estado') === 'cancelada';
        }

        // El usuario dueño de la reserva puede marcarla como 'en_uso'.
        if ($user->id === $reserva->usuario_id && $reserva->estado === 'aprobada') {
             return $this->input('estado') === 'en_uso';
        }

        return false; // Por defecto, denegar.
    }

    public function rules(): array
    {
        $user = $this->user();
        
        // Reglas para el admin
        if ($user->rol->nombre === 'Administrador') {
            return [
                'estado' => ['sometimes', 'required', Rule::in(['aprobada', 'rechazada', 'finalizada', 'cancelada'])],
                'observaciones_admin' => 'nullable|string|max:1000',
            ];
        }

        // Reglas para usuarios normales (Profesores/Estudiantes)
        return [
            'estado' => ['sometimes', 'required', Rule::in(['cancelada', 'en_uso'])],
        ];
    }
}