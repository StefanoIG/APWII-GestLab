<?php
namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Reserva;
use App\Events\ReservaPorTerminar; // Un nuevo evento que crearemos
use Carbon\Carbon;

class ReservasNotificarVencimiento extends Command
{
    protected $signature = 'reservas:notificar-vencimiento';
    protected $description = 'Notifica a los usuarios cuyas reservas están a punto de terminar.';

    public function handle()
    {
        $this->info('Buscando reservas a punto de finalizar...');

        $minutosAntes = 15; // Notificar 15 minutos antes
        $ahora = Carbon::now();
        $limite = $ahora->copy()->addMinutes($minutosAntes);

        $reservas = Reserva::where('estado', 'en_uso')
            ->where('fecha', $ahora->toDateString())
            ->whereTime('hora_fin', '>', $ahora->toTimeString())
            ->whereTime('hora_fin', '<=', $limite->toTimeString())
            // Para no enviar el mismo correo cada minuto
            ->where('notificacion_extension_enviada', false)
            ->get();

        foreach ($reservas as $reserva) {
            // Disparamos un evento para enviar el correo
            ReservaPorTerminar::dispatch($reserva);

            // Marcamos la reserva para no volver a notificarla
            $reserva->notificacion_extension_enviada = true;
            $reserva->save();
            
            $this->info("Notificación de vencimiento enviada para la reserva ID: {$reserva->id}");
        }

        $this->info('Proceso de notificación finalizado.');
    }
}