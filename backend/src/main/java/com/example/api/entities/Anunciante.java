package com.example.api.entities;

import com.example.api.entities.Visitante;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "anunciante")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Anunciante {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_anunciante")
    private Long id;

    @OneToOne
    @JoinColumn(name = "id_visitante", nullable = false)
    private Visitante visitante;

    @Column(name = "tipo_conta", nullable = false)
    private String tipoConta = "PESSOAL";

    @Column(name = "verificado", nullable = false)
    private Boolean verificado = false;

    @Column(name = "data_criacao", nullable = false)
    private LocalDateTime dataCriacao = LocalDateTime.now();
}
