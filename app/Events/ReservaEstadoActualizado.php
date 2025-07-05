<?php
namespace App\Events;

use App\Models\Reserva;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class ReservaEstadoActualizado
{
    use Dispatchable, SerializesModels;

    public Reserva $reserva;

    public function __construct(Reserva $reserva)
    {
        $this->reserva = $reserva;
    }
}