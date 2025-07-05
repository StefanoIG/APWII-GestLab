<?php

// app/Models/Incidente.php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Incidente extends Model
{
    use HasFactory;
    protected $fillable = ['reserva_id', 'descripcion', 'resuelto'];
    
    // Un incidente pertenece a una reserva
    public function reserva()
    {
        return $this->belongsTo(Reserva::class);
    }
}