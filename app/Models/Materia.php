<?php

// app/Models/Materia.php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Materia extends Model
{
    use HasFactory;
    protected $fillable = ['nombre', 'codigo'];

    // Una materia puede ser impartida por muchos profesores
    public function profesores()
    {
        return $this->belongsToMany(User::class, 'profesor_materia', 'materia_id', 'profesor_id');
    }
}