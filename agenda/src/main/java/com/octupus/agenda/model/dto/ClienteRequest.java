package com.octupus.agenda.model.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record ClienteRequest(
        @NotBlank(message = "O nome é obrigatório")
        @Size(max = 255, message = "O nome pode ter no máximo")
        String nome,
        @NotNull
        String documento,
        String telefone,
        @NotNull
        @Size(max = 255, message = "O email é obrigatório")
        String email
) {
}
