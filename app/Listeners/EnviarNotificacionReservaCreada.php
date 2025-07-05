<?php
namespace App\Listeners;

use App\Events\ReservaCreada;
use App\Mail\NotificacionReservaCreada;
use Illuminate\Support\Facades\Mail;

class EnviarNotificacionReservaCreada
{
    public function handle(ReservaCreada $event): void
    {
        Mail::to($event->reserva->usuario->email)
            ->send(new NotificacionReservaCreada($event->reserva));
    }
}