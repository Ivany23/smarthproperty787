package com.example.api.dtos;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

@Schema(description = "Dados para login do usuário")
public record LoginDTO(
    @Schema(description = "Email do usuário", example = "joao.silva@email.com", required = true)
    @NotBlank(message = "O email não pode estar em branco")
    @Email(message = "Formato de email inválido")
    String email,

    @Schema(description = "Senha do usuário", example = "MinhaSenha123", required = true)
    @NotBlank(message = "A senha não pode estar em branco")
    String senha
) {
}
