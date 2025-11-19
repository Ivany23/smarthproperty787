package com.example.api.dtos;

import com.example.api.entities.Pagamento;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record PagamentoDTO(
        Long id,
        Long idAnunciante,
        BigDecimal valor,
        Integer creditosAdquiridos,
        String metodoPagamento,
        String referencia,
        LocalDateTime dataPagamento,
        String statusPagamento,
        String comprovanteUrl
) {
    public PagamentoDTO(Pagamento pagamento) {
        this(
                pagamento.getId(),
                pagamento.getAnunciante().getId(),
                pagamento.getValor(),
                pagamento.getCreditosAdquiridos(),
                pagamento.getMetodoPagamento(),
                pagamento.getReferencia(),
                pagamento.getDataPagamento(),
                pagamento.getStatusPagamento(),
                pagamento.getComprovanteUrl()
        );
    }
}
