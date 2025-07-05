<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule; // Asegúrate de importar la clase Schedule

/*
|--------------------------------------------------------------------------
| Console Routes
|--------------------------------------------------------------------------
|
| This file is where you may define all of your Closure based console
| commands. Each Closure is bound to a command instance allowing a
| simple approach to interacting with each command's IO methods.
|
*/

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');


// 👇 AÑADE ESTA LÍNEA PARA TU TAREA PROGRAMADA
Schedule::command('reservas:cancelar-vencidas')->everyMinute();
// routes/console.php
Schedule::command('reservas:notificar-vencimiento')->everyMinute();