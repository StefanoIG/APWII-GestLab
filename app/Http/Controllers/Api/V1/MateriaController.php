<?php
namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Materia;
use App\Http\Requests\StoreMateriaRequest;
use App\Http\Requests\UpdateMateriaRequest;

class MateriaController extends Controller
{
    public function index()
    {
        return response()->json(Materia::all());
    }

    public function store(StoreMateriaRequest $request)
    {
        $materia = Materia::create($request->validated());
        return response()->json($materia, 201);
    }

    public function show(Materia $materia)
    {
        return response()->json($materia);
    }

    public function update(UpdateMateriaRequest $request, Materia $materia)
    {
        $materia->update($request->validated());
        return response()->json($materia);
    }

    public function destroy(Materia $materia)
    {
        if ($this->user()->rol->nombre !== 'Administrador') {
             return response()->json(['error' => 'No autorizado'], 403);
        }
        $materia->delete();
        return response()->json(null, 204);
    }
}