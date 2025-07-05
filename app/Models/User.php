<?php

namespace App\Models;

use Tymon\JWTAuth\Contracts\JWTSubject;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable implements JWTSubject
{
    use Notifiable;

    protected $fillable = [
        'nombre', 'email', 'password', 'rol_id', 'bloqueado',
    ];

    protected $hidden = [
        'password', 'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
    ];

    // Un usuario tiene un rol
    public function rol()
    {
        return $this->belongsTo(Role::class);
    }

    // Un usuario (profesor o estudiante) puede tener muchas reservas
    public function reservas()
    {
        return $this->hasMany(Reserva::class, 'usuario_id');
    }

    // Un usuario (profesor) puede impartir muchas materias (relación muchos a muchos)
    public function materias()
    {
        return $this->belongsToMany(Materia::class, 'profesor_materia', 'profesor_id', 'materia_id');
    }

    /**
     * Get the identifier that will be stored in the subject claim of the JWT.
     *
     * @return mixed
     */
    public function getJWTIdentifier()
    {
        return $this->getKey();
    }

    /**
     * Return a key value array, containing any custom claims to be added to the JWT.
     *
     * @return array
     */
    public function getJWTCustomClaims()
    {
        return [
            'nombre' => $this->nombre,
            'email' => $this->email,
            'rol' => $this->rol ? $this->rol->nombre : null, // Protección contra null
        ];
    }
}