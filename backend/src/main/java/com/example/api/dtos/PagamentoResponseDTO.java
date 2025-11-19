package com.example.api.dtos;

import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Schema(description = "Resposta completa do processamento de pagamento")
public record PagamentoResponseDTO(
    @Schema(description = "Dados do pagamento processado")
    PagamentoDTO pagamento,

    @Schema(description = "Dados do anunciante criado/convertido")
    AnuncianteDTO anunciante,

    @Schema(description = "Dados dos créditos atualizados")
    CreditoDTO credito,

    @Schema(description = "Mensagem de confirmação")
    String message
) {
}
