<?php

// app/Models/Reserva.php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Reserva extends Model
{
    use HasFactory;

    protected $fillable = [
        'laboratorio_id',
        'usuario_id',
        'materia_id',
        'fecha',
        'hora_inicio',
        'hora_fin',
        'motivo',
        'estado',
        'confirmacion_uso',
        'observaciones_admin',
    ];
    
    // Una reserva pertenece a un laboratorio
    public function laboratorio()
    {
        return $this->belongsTo(Laboratorio::class);
    }

    // Una reserva es creada por un usuario
    public function usuario()
    {
        return $this->belongsTo(User::class, 'usuario_id');
    }

    // Una reserva puede estar asociada a una materia
    public function materia()
    {
        return $this->belongsTo(Materia::class);
    }
    
    // Una reserva puede tener muchos incidentes
    public function incidentes()
    {
        return $this->hasMany(Incidente::class);
    }
}