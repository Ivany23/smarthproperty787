package com.example.api.entities;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.OffsetDateTime;

@Entity
@Table(name = "imovel")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Imovel {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_imovel")
    private Long id;

    @Column(name = "titulo", nullable = false)
    private String titulo;

    @Column(name = "descricao")
    private String descricao;

    @Column(name = "preco_mzn", nullable = false)
    private BigDecimal precoMzn;

    @Column(name = "area")
    private BigDecimal area;

    @Column(name = "finalidade", nullable = false)
    private String finalidade;

    @Column(name = "status_imovel", nullable = false)
    private String statusImovel = "DISPONIVEL";

    @Column(name = "imagem_principal_url")
    private String imagemPrincipalUrl;

    @Column(name = "data_criacao", nullable = false)
    private OffsetDateTime dataCriacao = OffsetDateTime.now();

    @Column(name = "id_anunciante", nullable = false)
    private Long idAnunciante;

    @Column(name = "categoria", nullable = false)
    private String categoria = "Casa";
}
