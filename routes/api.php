<?php

// routes/api.php
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\AuthController;
use App\Http\Controllers\Api\V1\LaboratorioController;
use App\Http\Controllers\Api\V1\MateriaController;
use App\Http\Controllers\Api\V1\ReservaController;
use App\Http\Controllers\Api\V1\UserController;
use App\Http\Controllers\Api\V1\IncidenteController;


// --- Rutas de Autenticación ---
Route::group(['prefix' => 'auth'], function () {
    Route::post('login', [AuthController::class, 'login']);
    Route::post('logout', [AuthController::class, 'logout']);
    Route::post('refresh', [AuthController::class, 'refresh']);
    Route::get('me', [AuthController::class, 'me']);
});


// --- Rutas Protegidas por JWT ---
Route::group(['middleware' => 'auth:api', 'prefix' => 'v1'], function () {
    // Usamos apiResource para generar las rutas CRUD estándar
    Route::apiResource('laboratorios', LaboratorioController::class);
    Route::apiResource('materias', MateriaController::class);
    Route::apiResource('reservas', ReservaController::class);
    Route::post('reservas/{reserva}/extender', [ReservaController::class, 'extenderReserva']);
    Route::apiResource('incidentes', IncidenteController::class);
    Route::apiResource('users', UserController::class);

    // Aquí podemos añadir más rutas específicas en el futuro
});

// --- Rutas Públicas (Ej: para ver horarios sin login) ---
Route::get('v1/horarios/public', [LaboratorioController::class, 'verHorariosPublicos']);