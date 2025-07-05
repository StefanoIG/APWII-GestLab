<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('reservas', function (Blueprint $table) {
            $table->id();
            $table->foreignId('laboratorio_id')->constrained('laboratorios');
            $table->foreignId('usuario_id')->constrained('users');
            $table->foreignId('materia_id')->nullable()->constrained('materias'); // Puede ser nulo
            $table->date('fecha');
            $table->time('hora_inicio');
            $table->time('hora_fin');
            $table->text('motivo');
            
            // Estado de la reserva: desde la solicitud del estudiante hasta su finalización
            $table->enum('estado', [
                'pendiente_aprobacion', // Solicitud de estudiante
                'aprobada',             // Aprobada por admin o creada por profesor
                'rechazada',            // Rechazada por admin
                'en_uso',               // Marcada como en uso
                'finalizada',           // Finalizada por el usuario
                'cancelada',            // Cancelada manualmente
                'autocancelada'         // Cancelada por el sistema
            ]);

            $table->timestamp('confirmacion_uso')->nullable(); // Momento en que se marca "en uso"
            $table->text('observaciones_admin')->nullable(); // Para justificar rechazos
            $table->timestamps();

            // Evitar reservas duplicadas en el mismo laboratorio, fecha y hora
            $table->unique(['laboratorio_id', 'fecha', 'hora_inicio']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('reservas');
    }
};