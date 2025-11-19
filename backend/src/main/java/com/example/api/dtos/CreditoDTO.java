package com.example.api.dtos;

import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Schema(description = "Dados dos créditos do anunciante")
public record CreditoDTO(
    @Schema(description = "ID do registro de crédito", example = "1")
    Long id,

    @Schema(description = "ID do anunciante", example = "1")
    Long idAnunciante,

    @Schema(description = "Saldo atual de créditos", example = "5.00")
    BigDecimal saldo,

    @Schema(description = "Data da última atualização", example = "2025-11-13T14:30:00")
    LocalDateTime dataAtualizacao
) {
    public CreditoDTO(com.example.api.entities.Credito credito) {
        this(
            credito.getId(),
            credito.getAnunciante().getId(),
            credito.getSaldo(),
            credito.getDataAtualizacao()
        );
    }
}
