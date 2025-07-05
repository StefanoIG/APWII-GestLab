<?php
namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Http\Requests\StoreUserRequest;
use App\Http\Requests\UpdateUserRequest;
use Illuminate\Support\Facades\Hash;

class UserController extends Controller
{
    public function index()
    {
        // Eager load (cargar) la relación con el rol para no hacer N+1 consultas
        return response()->json(User::with('rol')->paginate(15));
    }

    public function store(StoreUserRequest $request)
    {
        $validatedData = $request->validated();
        $validatedData['password'] = Hash::make($validatedData['password']);
        
        $user = User::create($validatedData);
        $user->load('rol'); // Cargar el rol para la respuesta

        return response()->json($user, 201);
    }

    public function show(User $user)
    {
        return response()->json($user->load('rol'));
    }

    public function update(UpdateUserRequest $request, User $user)
    {
        $validatedData = $request->validated();

        // Solo actualizar la contraseña si se proporciona una nueva
        if ($request->filled('password')) {
            $validatedData['password'] = Hash::make($validatedData['password']);
        } else {
            unset($validatedData['password']); // No actualizar si está vacía
        }

        $user->update($validatedData);
        return response()->json($user->load('rol'));
    }

    public function destroy(User $user)
    {
        // Lógica de seguridad: no permitir que un admin se borre a sí mismo
        if ($user->id === auth()->id()) {
            return response()->json(['error' => 'No puedes eliminar tu propia cuenta.'], 403);
        }

        $user->delete();
        return response()->json(null, 204);
    }
}