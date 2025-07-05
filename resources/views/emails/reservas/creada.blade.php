<x-mail::message>
# Solicitud de Reserva Recibida

¡Hola, **{{ $reserva->usuario->nombre }}**!

Hemos recibido correctamente tu solicitud de reserva. A continuación, te mostramos los detalles:

<x-mail::panel>
**Laboratorio:** {{ $reserva->laboratorio->nombre }} <br>
**Fecha:** {{ \Carbon\Carbon::parse($reserva->fecha)->translatedFormat('l, d \d\e F \d\e Y') }} <br>
**Horario:** {{ \Carbon\Carbon::parse($reserva->hora_inicio)->format('H:i') }} - {{ \Carbon\Carbon::parse($reserva->hora_fin)->format('H:i') }} <br>
**Motivo:** {{ $reserva->motivo }}
</x-mail::panel>

Tu solicitud se encuentra actualmente en estado: **{{ $reserva->estado }}**.

Recibirás una notificación por este medio cuando sea aprobada o rechazada.

<x-mail::button :url="config('app.url') . '/mis-reservas/' . $reserva->id">
Ver Estado de la Solicitud
</x-mail::button>

Gracias por usar el sistema,<br>
{{ config('app.name') }}
</x-mail::message>