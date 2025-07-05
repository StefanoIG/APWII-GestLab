<?php
namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Incidente;
use App\Http\Requests\StoreIncidenteRequest;
use App\Http\Requests\UpdateIncidenteRequest;
use Illuminate\Support\Facades\Auth;

class IncidenteController extends Controller
{
    /**
     * Muestra una lista de incidentes.
     * Admin ve todos, otros usuarios solo ven los de sus propias reservas.
     */
    public function index()
    {
        $user = Auth::user();
        $query = Incidente::with(['reserva:id,fecha,laboratorio_id', 'reserva.laboratorio:id,nombre']);

        if ($user->rol->nombre !== 'Administrador') {
            $query->whereHas('reserva', function ($q) use ($user) {
                $q->where('usuario_id', $user->id);
            });
        }

        return response()->json($query->latest()->paginate());
    }

    /**
     * Guarda un nuevo incidente en la base de datos.
     */
    public function store(StoreIncidenteRequest $request)
    {
        $incidente = Incidente::create($request->validated());
        return response()->json($incidente, 201);
    }

    /**
     * Muestra un incidente específico.
     */
    public function show(Incidente $incidente)
    {
        $user = Auth::user();
        
        // Autorización: El usuario debe ser admin o el dueño de la reserva asociada.
        if ($user->rol->nombre !== 'Administrador' && $user->id !== $incidente->reserva->usuario_id) {
            return response()->json(['error' => 'No autorizado'], 403);
        }

        return response()->json($incidente->load(['reserva']));
    }

    /**
     * Actualiza un incidente (ej: marcar como resuelto).
     */
    public function update(UpdateIncidenteRequest $request, Incidente $incidente)
    {
        $incidente->update($request->validated());
        return response()->json($incidente);
    }

    /**
     * Elimina un incidente.
     */
    public function destroy(Incidente $incidente)
    {
        // Solo un administrador puede eliminar un incidente.
        if (Auth::user()->rol->nombre !== 'Administrador') {
            return response()->json(['error' => 'No autorizado'], 403);
        }

        $incidente->delete();
        return response()->json(null, 204); // No Content
    }
}