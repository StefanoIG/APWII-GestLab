<x-mail::message>
# Actualización sobre tu Reserva

¡Hola, **{{ $reserva->usuario->nombre }}**!

El estado de tu reserva para el **{{ $reserva->laboratorio->nombre }}** del día **{{ \Carbon\Carbon::parse($reserva->fecha)->translatedFormat('d \d\e F') }}** ha sido actualizado.

<x-mail::panel>
**Nuevo Estado: {{ Str::headline($reserva->estado) }}**

@if($reserva->estado === 'aprobada')
¡Tu solicitud ha sido aprobada! Ya puedes hacer uso del laboratorio en la fecha y hora acordadas.
@elseif($reserva->estado === 'rechazada')
Lamentablemente, tu solicitud ha sido rechazada por el siguiente motivo:
> {{ $reserva->observaciones_admin ?? 'No se proporcionaron observaciones.' }}
@elseif($reserva->estado === 'cancelada')
Has cancelado esta reserva. El horario ha quedado liberado.
@elseif($reserva->estado === 'autocancelada')
La reserva fue cancelada automáticamente debido a que no se confirmó su uso después del tiempo de gracia de 15 minutos.
@elseif($reserva->estado === 'finalizada')
Esta reserva ha sido marcada como finalizada. ¡Gracias por usar nuestras instalaciones!
@endif
</x-mail::panel>

<x-mail::button :url="config('app.url') . '/mis-reservas/' . $reserva->id">
Ver mis Reservas
</x-mail::button>

Si tienes alguna duda, por favor contacta a la administración.

Saludos,<br>
{{ config('app.name') }}
</x-mail::message>