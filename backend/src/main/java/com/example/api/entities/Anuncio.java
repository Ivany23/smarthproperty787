package com.example.api.entities;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "anuncio")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Anuncio {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_anuncio")
    private Long idAnuncio;

    @Column(name = "id_imovel", nullable = false)
    private Long idImovel;

    @Column(name = "data_publicacao", nullable = false)
    private LocalDateTime dataPublicacao = LocalDateTime.now();

    @Column(name = "status_anuncio", nullable = false)
    private String statusAnuncio = "PENDENTE";

    @Column(name = "visualizacoes")
    private Integer visualizacoes = 0;

    @Column(name = "data_expiracao")
    private LocalDateTime dataExpiracao;

    @Column(name = "custo_credito", nullable = false)
    private BigDecimal custoCredito = new BigDecimal("50");
}
