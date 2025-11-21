package com.example.api.entities;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.OffsetDateTime;

@Entity
@Table(name = "imovel_imagem")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ImovelImagem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_imovel_imagem")
    private Long id;

    @Column(name = "id_imovel", nullable = false)
    private Long idImovel;

    @Column(name = "imagem_url", nullable = false)
    private String imagemUrl;

    @Column(name = "ordem", nullable = false)
    private Integer ordem = 0;

    @Column(name = "data_criacao", nullable = false)
    private OffsetDateTime dataCriacao = OffsetDateTime.now();


    @Transient
    private Imovel imovel;
}
