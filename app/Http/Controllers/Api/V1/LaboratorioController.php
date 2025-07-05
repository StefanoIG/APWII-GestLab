<?php
namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Laboratorio;
use App\Http\Requests\StoreLaboratorioRequest;
use App\Http\Requests\UpdateLaboratorioRequest;
use Illuminate\Http\Request;

class LaboratorioController extends Controller
{
    // Muestra todos los laboratorios (para usuarios autenticados)
    public function index()
    {
        return response()->json(Laboratorio::all());
    }

    // Crea un nuevo laboratorio
    public function store(StoreLaboratorioRequest $request)
    {
        $laboratorio = Laboratorio::create($request->validated());
        return response()->json($laboratorio, 201); // 201: Created
    }

    // Muestra un laboratorio específico
    public function show(Laboratorio $laboratorio)
    {
        return response()->json($laboratorio);
    }

    // Actualiza un laboratorio
    public function update(UpdateLaboratorioRequest $request, Laboratorio $laboratorio)
    {
        $laboratorio->update($request->validated());
        return response()->json($laboratorio);
    }

    // Elimina un laboratorio
    public function destroy(Laboratorio $laboratorio)
    {
        if ($this->user()->rol->nombre !== 'Administrador') {
             return response()->json(['error' => 'No autorizado'], 403);
        }
        $laboratorio->delete();
        return response()->json(null, 204); // 204: No Content
    }
    
    // Función pública para ver horarios
    public function verHorariosPublicos(Request $request)
    {
        // Lógica para devolver los horarios (lo detallaremos más adelante)
        // Por ahora, devolvemos todos los laboratorios activos
        $laboratorios = Laboratorio::where('estado', 'activo')->get(['id', 'nombre', 'capacidad']);
        return response()->json($laboratorios);
    }
}