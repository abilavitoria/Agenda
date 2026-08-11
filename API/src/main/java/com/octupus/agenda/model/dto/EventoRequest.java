package com.octupus.agenda.model.dto;

import jakarta.validation.constraints.FutureOrPresent;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.LocalDateTime;

public record EventoRequest(
        @NotBlank(message = "o título é obrigatório")
        @Size(max = 250, message = "O título deve ter no máximo 250 caracteres")
        String titulo,

        @NotNull(message = "A data do evento é obrigatória")
        @FutureOrPresent(message = "A data do evento não pode estar no passado")
        LocalDateTime dataEvento,

        LocalDateTime dataLembrete,

        @Size(max = 100, message = "A categoria deve ter no máximo 100 caracteres")
        String categoria
) {
}
