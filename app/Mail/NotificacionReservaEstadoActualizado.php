<?php
namespace App\Mail;

use App\Models\Reserva;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class NotificacionReservaEstadoActualizado extends Mailable
{
    use Queueable, SerializesModels;

    public Reserva $reserva;

    public function __construct(Reserva $reserva)
    {
        $this->reserva = $reserva;
    }

    public function envelope(): Envelope
    {
        return new Envelope(
            subject: 'Actualización del Estado de tu Reserva',
        );
    }

    public function content(): Content
    {
        // Le pasamos la reserva a la vista para que pueda usar sus datos
        return new Content(
            markdown: 'emails.reservas.actualizada',
            with: [
                'reserva' => $this->reserva,
            ],
        );
    }
}