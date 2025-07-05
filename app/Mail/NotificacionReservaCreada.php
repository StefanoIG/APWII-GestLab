<?php
namespace App\Mail;

use App\Models\Reserva;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class NotificacionReservaCreada extends Mailable
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
            subject: 'Confirmación de Solicitud de Reserva',
        );
    }

    public function content(): Content
    {
        return new Content(
            markdown: 'emails.reservas.creada',
        );
    }
}