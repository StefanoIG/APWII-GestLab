<?php
namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Reserva;
use App\Http\Requests\StoreReservaRequest;
use App\Http\Requests\UpdateReservaRequest;
use Illuminate\Support\Facades\Auth;
use App\Events\ReservaCreada;
use App\Events\ReservaEstadoActualizado;
class ReservaController extends Controller
{
    public function index()
    {
        $user = Auth::user();
        $query = Reserva::with(['usuario:id,nombre', 'laboratorio:id,nombre']);

        // Admin ve todo. Profesores y Estudiantes solo ven lo suyo.
        if ($user->rol->nombre !== 'Administrador') {
            $query->where('usuario_id', $user->id);
        }

        return response()->json($query->latest()->paginate());
    }

    public function store(StoreReservaRequest $request)
    {
        $user = $request->user();
        $validatedData = $request->validated();

        // --- INICIO DEL NUEVO BLOQUE DE VALIDACIÓN ---
        // Verificamos si existe un cruce de horarios para este laboratorio y fecha.
        $conflicto = Reserva::where('laboratorio_id', $validatedData['laboratorio_id'])
            ->where('fecha', $validatedData['fecha'])
            ->whereIn('estado', ['aprobada', 'en_uso']) // Solo nos importan las reservas activas
            ->where(function ($query) use ($validatedData) {
                // Un conflicto existe si:
                // 1. La nueva reserva empieza ANTES de que la existente termine.
                $query->where('hora_inicio', '<', $validatedData['hora_fin'])
                    // 2. Y la nueva reserva termina DESPUÉS de que la existente empiece.
                    ->where('hora_fin', '>', $validatedData['hora_inicio']);
            })
            ->exists(); // Devuelve true si encuentra al menos una reserva en conflicto.

        if ($conflicto) {
            // Si hay un conflicto, devolvemos un error 409 (Conflict).
            return response()->json(['message' => 'El horario solicitado ya no está disponible.'], 409);
        }
        // --- FIN DEL NUEVO BLOQUE DE VALIDACIÓN ---

        // Asignar el usuario que crea la reserva
        $validatedData['usuario_id'] = $user->id;

        // Lógica de roles para el estado inicial (esta parte se mantiene igual)
        if (in_array($user->rol->nombre, ['Profesor', 'Administrador'])) {
            $validatedData['estado'] = 'aprobada';
        } else { // Estudiante
            $validatedData['estado'] = 'pendiente_aprobacion';
        }
        
        $reserva = Reserva::create($validatedData);
        
        ReservaCreada::dispatch($reserva);

        return response()->json($reserva, 201);
    }

    public function show(Reserva $reserva)
    {
        $user = Auth::user();

        // Un usuario solo puede ver su propia reserva, a menos que sea admin
        if ($user->id !== $reserva->usuario_id && $user->rol->nombre !== 'Administrador') {
            return response()->json(['error' => 'No autorizado para ver esta reserva.'], 403);
        }

        return response()->json($reserva->load(['usuario', 'laboratorio', 'materia', 'incidentes']));
    }

    public function update(UpdateReservaRequest $request, Reserva $reserva)
    {
        $validatedData = $request->validated();

        if (isset($validatedData['estado']) && $validatedData['estado'] === 'en_uso') {
            $validatedData['confirmacion_uso'] = now();
        }
        
        $reserva->update($validatedData);

        // Esta línea también necesita la importación para funcionar
        ReservaEstadoActualizado::dispatch($reserva);
        
        return response()->json($reserva->load('usuario', 'laboratorio'));
    }

    public function destroy(Reserva $reserva)
    {
        // Solo un Admin puede eliminar un registro de reserva permanentemente
         if (Auth::user()->rol->nombre !== 'Administrador') {
            return response()->json(['error' => 'No autorizado.'], 403);
        }
        $reserva->delete();
        return response()->json(null, 204);
    }
    // En app/Http/Controllers/Api/V1/ReservaController.php

public function extenderReserva(Request $request, Reserva $reserva)
{
    // Validamos que el usuario que extiende sea el dueño de la reserva
    if (Auth::id() !== $reserva->usuario_id) {
        return response()->json(['message' => 'No autorizado'], 403);
    }
    
    // Validamos los minutos de extensión solicitados
    $request->validate(['minutos_extension' => 'required|integer|min:1']);
    $minutosExtension = $request->input('minutos_extension');

    // Calculamos la nueva hora de finalización propuesta
    $nuevaHoraFin = Carbon::parse($reserva->hora_fin)->addMinutes($minutosExtension)->toTimeString();

    // Buscamos si hay una reserva conflictiva (otra reserva que empiece ANTES de nuestra nueva hora de fin)
    $reservaConflictiva = Reserva::where('laboratorio_id', $reserva->laboratorio_id)
        ->where('fecha', $reserva->fecha)
        ->where('id', '!=', $reserva->id)
        ->whereIn('estado', ['aprobada', 'en_uso'])
        ->where('hora_inicio', '<', $nuevaHoraFin)
        ->orderBy('hora_inicio', 'asc') // Tomamos la más próxima
        ->first();

    // ---- LÓGICA DE DECISIÓN ----

    // CASO 1: No hay ningún conflicto. ¡Vía libre!
    if (!$reservaConflictiva) {
        $reserva->hora_fin = $nuevaHoraFin;dame dadame de nuevo ahDame ahora de nuevo{

            "estado": "aprobada",
        
            "observaciones_admin": "Aprobado. Por favor, cuidar los equipos."
        
        } todoora 
        $reserva->save();
        // TODO: Enviar email de confirmación de extensión al profesor actual
        return response()->json(['message' => 'Reserva extendida exitosamente.']);
    }

    // CASO 2: Hay conflicto, pero la extensión es corta (<= 10 min).
    // Y el conflicto empieza después de nuestra hora de fin original.
    if ($minutosExtension <= 10 && $reservaConflictiva->hora_inicio >= $reserva->hora_fin) {
        $reserva->hora_fin = $nuevaHoraFin;
        $reserva->save();
        // TODO: Enviar email de confirmación al profesor actual
        // TODO: Enviar email de NOTIFICACIÓN DE RETRASO al profesor de la reserva conflictiva
        return response()->json(['message' => 'Reserva extendida. Se ha notificado al siguiente profesor del retraso.']);
    }

    // CASO 3: Hay conflicto y la extensión es larga (> 10 min) o el horario ya estaba solapado.
    // Rechazamos la extensión.
    // TODO: Sugerir otro laboratorio al profesor de la reserva conflictiva. (Funcionalidad muy avanzada)
    return response()->json([
        'message' => 'No se puede extender la reserva. El horario entra en conflicto con la siguiente reserva.',
        'siguiente_reserva' => [
            'hora_inicio' => $reservaConflictiva->hora_inicio
        ]
    ], 409); // 409 Conflict
}
}