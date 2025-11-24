package com.example.api.entities;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "marcacao")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Marcacao {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_marcacao")
    private Long id;

    @Column(name = "id_visitante", nullable = false)
    private Long idVisitante;

    @Column(name = "id_imovel", nullable = false)
    private Long idImovel;

    @Column(name = "data_hora_inicio", nullable = false)
    private LocalDateTime dataHoraInicio;

    @Column(name = "data_hora_fim", nullable = false)
    private LocalDateTime dataHoraFim;

    @Column(name = "status")
    private String status = "PENDENTE";

    @Column(name = "observacoes")
    private String observacoes;

    @Column(name = "data_criacao")
    private LocalDateTime dataCriacao = LocalDateTime.now();
}
