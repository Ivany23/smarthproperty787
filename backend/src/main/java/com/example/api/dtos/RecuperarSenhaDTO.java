package com.example.api.dtos;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public record RecuperarSenhaDTO(
        @NotBlank(message = "Email é obrigatório") @Email(message = "Email inválido") String email,

        @NotBlank(message = "Código de verificação é obrigatório") String codigoVerificacao,

        @NotBlank(message = "Nova senha é obrigatória") String novaSenha) {
}
