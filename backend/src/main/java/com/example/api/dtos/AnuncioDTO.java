package com.example.api.dtos;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AnuncioDTO {
    private Long idAnuncio;
    private Long idImovel;
    private LocalDateTime dataPublicacao;
    private String statusAnuncio;
    private Integer visualizacoes;
    private LocalDateTime dataExpiracao;
    private BigDecimal custoCredito;
}
