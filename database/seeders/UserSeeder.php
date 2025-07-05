<?php

// database/seeders/UserSeeder.php
namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User; // Importar el modelo User
use App\Models\Role; // Importar el modelo Role
use Illuminate\Support\Facades\Hash; // Importar Hash para la contraseña

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // Buscamos el rol 'Administrador'
        $adminRole = Role::where('nombre', 'Administrador')->first();

        // Creamos el usuario administrador si no existe
        if ($adminRole) {
            User::updateOrCreate(
                ['email' => 'admin@example.com'], // Condición para buscar
                [
                    'nombre' => 'Admin General',
                    'password' => Hash::make('password'), // ¡Cambia esto en producción!
                    'rol_id' => $adminRole->id,
                    'email_verified_at' => now()
                ]
            );
        }
    }
}