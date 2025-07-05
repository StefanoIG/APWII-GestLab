<?php

// app/Models/Laboratorio.php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Laboratorio extends Model
{
    use HasFactory;
    protected $fillable = ['nombre', 'capacidad', 'descripcion', 'estado'];

    // Un laboratorio puede tener muchas reservas
    public function reservas()
    {
        return $this->hasMany(Reserva::class);
    }
}