<?php

// database/seeders/RoleSeeder.php
namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Role; // Importar el modelo Role

class RoleSeeder extends Seeder
{
    public function run(): void
    {
        // Usamos updateOrCreate para evitar duplicados si ejecutamos el seeder varias veces
        Role::updateOrCreate(['nombre' => 'Administrador']);
        Role::updateOrCreate(['nombre' => 'Profesor']);
        Role::updateOrCreate(['nombre' => 'Estudiante']);
    }
}