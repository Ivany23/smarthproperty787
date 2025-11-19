package com.example.api.dtos;

import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;

@Schema(description = "Dados do anunciante")
public record AnuncianteDTO(
    @Schema(description = "ID do anunciante", example = "1")
    Long id,

    @Schema(description = "ID do visitante associado", example = "1")
    Long idVisitante,

    @Schema(description = "Nome do visitante", example = "João Silva")
    String nomeVisitante,

    @Schema(description = "Email do visitante", example = "joao.silva@email.com")
    String emailVisitante,

    @Schema(description = "Tipo de conta", example = "PESSOAL", allowableValues = {"PESSOAL", "EMPRESARIAL"})
    String tipoConta,

    @Schema(description = "Status de verificação", example = "false")
    Boolean verificado,

    @Schema(description = "Data de criação da conta", example = "2025-11-13T14:30:00")
    LocalDateTime dataCriacao
) {
    public AnuncianteDTO(com.example.api.entities.Anunciante anunciante) {
        this(
            anunciante.getId(),
            anunciante.getVisitante().getId(),
            anunciante.getVisitante().getNomeCompleto(),
            anunciante.getVisitante().getEmail(),
            anunciante.getTipoConta(),
            anunciante.getVerificado(),
            anunciante.getDataCriacao()
        );
    }
}
