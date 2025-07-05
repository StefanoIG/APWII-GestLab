<?php
namespace App\Listeners;

use App\Events\ReservaEstadoActualizado;
use App\Mail\NotificacionReservaEstadoActualizado;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Support\Facades\Mail;

class EnviarNotificacionEstadoActualizado
{
    public function __construct()
    {
        //
    }

    public function handle(ReservaEstadoActualizado $event): void
    {
        // Enviamos el correo al email del usuario asociado a la reserva
        Mail::to($event->reserva->usuario->email)
            ->send(new NotificacionReservaEstadoActualizado($event->reserva));
    }
}