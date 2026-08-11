package com.octupus.agenda.model.dto;

import com.octupus.agenda.model.Evento;

import java.time.LocalDateTime;

public record EventoResponse(
        Long id,
        String titulo,
        LocalDateTime dataEvento,
        LocalDateTime dataLembrete,
        String categoria
) {
    public EventoResponse(Evento evento){
        this(
                evento.getId(),
                evento.getTitulo(),
                evento.getDataEvento(),
                evento.getDataLembrete(),
                evento.getCategoria()
        );
    }
}
