package com.example.api.dtos;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

@Schema(description = "Dados para processamento de pagamento")
public record ProcessarPagamentoDTO(
    @Schema(description = "ID do visitante que está fazendo o pagamento", example = "1", required = true)
    @NotNull(message = "ID do visitante é obrigatório")
    Long visitanteId,

    @Schema(description = "Valor do pagamento em meticais", example = "25.00", required = true)
    @NotNull(message = "Valor é obrigatório")
    @DecimalMin(value = "0.01", message = "Valor deve ser maior que zero")
    java.math.BigDecimal valor,

    @Schema(description = "Método de pagamento", example = "MPESA", allowableValues = {"MPESA", "EMOLA"}, required = true)
    @NotBlank(message = "Método de pagamento é obrigatório")
    String metodoPagamento
) {
}
