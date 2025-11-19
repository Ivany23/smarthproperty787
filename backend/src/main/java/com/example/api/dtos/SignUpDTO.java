package com.example.api.dtos;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

@Schema(description = "Dados para cadastro de um novo usuário")
public record SignUpDTO(
    @Schema(description = "Nome completo do usuário", example = "João da Silva", required = true)
    @NotBlank(message = "O nome completo não pode estar em branco")
    String nomeCompleto,

    @Schema(description = "Email do usuário", example = "joao.silva@email.com", required = true)
    @NotBlank(message = "O email não pode estar em branco")
    @Email(message = "Formato de email inválido")
    String email,

    @Schema(description = "Telefone do usuário", example = "(11) 99999-9999", required = true)
    @NotBlank(message = "O telefone não pode estar em branco")
    String telefone,

    @Schema(description = "Senha do usuário", example = "MinhaSenha123", required = true)
    @NotBlank(message = "A senha não pode estar em branco")
    @Size(min = 6, message = "A senha deve ter no mínimo 6 caracteres")
    String senha
) {
}
