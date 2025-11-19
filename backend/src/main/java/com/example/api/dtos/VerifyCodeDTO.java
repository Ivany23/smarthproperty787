package com.example.api.dtos;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

@Schema(description = "Dados para verificação do código de recuperação")
public record VerifyCodeDTO(
    @Schema(description = "Email do usuário", example = "joao.silva@email.com", required = true)
    @NotBlank(message = "O email não pode estar em branco")
    @Email(message = "Formato de email inválido")
    String email,

    @Schema(description = "Código de verificação", example = "A1B2C3D4", required = true)
    @NotBlank(message = "O código não pode estar em branco")
    String code
) {
}
