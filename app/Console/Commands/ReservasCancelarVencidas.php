<?php
namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Reserva;
use Carbon\Carbon;

class ReservasCancelarVencidas extends Command
{
    // Nombre para llamar al comando
    protected $signature = 'reservas:cancelar-vencidas';

    // Descripción del comando
    protected $description = 'Cancela automáticamente las reservas aprobadas que no se marcaron como "en uso" después de un tiempo de gracia.';

    public function handle()
    {
        $this->info('Buscando reservas vencidas para cancelar...');

        // Tiempo de gracia en minutos (ej. 15 minutos)
        $tiempoDeGracia = 15;

        // 👇 LÍNEA CORREGIDA
        $reservasParaCancelar = Reserva::where('estado', 'aprobada')
            // La fecha de la reserva es hoy o pasada
            ->where('fecha', '<=', now()->toDateString())
            // La hora de inicio ya pasó, más el tiempo de gracia
            ->where('hora_inicio', '<', now()->subMinutes($tiempoDeGracia)->toTimeString())
            // Y no se ha confirmado su uso
            ->whereNull('confirmacion_uso')
            ->get();

        if ($reservasParaCancelar->isEmpty()) {
            $this->info('No se encontraron reservas para cancelar.');
            return;
        }

        foreach ($reservasParaCancelar as $reserva) {
            $reserva->estado = 'autocancelada';
            $reserva->save();

            // Opcional: Notificar al usuario de la cancelación
             ReservaEstadoActualizado::dispatch($reserva);

            $this->warn("Reserva ID: {$reserva->id} para el lab {$reserva->laboratorio->nombre} ha sido auto-cancelada.");
        }

        $this->info('Proceso de cancelación finalizado.');
    }
}