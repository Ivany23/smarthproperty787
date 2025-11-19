package com.example.api.entities;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "pagamento")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Pagamento {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_pagamento")
    private Long id;

    @ManyToOne
    @JoinColumn(name = "id_anunciante", nullable = false)
    private Anunciante anunciante;

    @Column(name = "valor", nullable = false)
    private BigDecimal valor;

    @Column(name = "creditos_adquiridos", nullable = false)
    private Integer creditosAdquiridos;

    @Column(name = "metodo_pagamento", nullable = false)
    private String metodoPagamento;

    @Column(name = "referencia", nullable = false, unique = true)
    private String referencia;

    @Column(name = "data_pagamento", nullable = false)
    private LocalDateTime dataPagamento = LocalDateTime.now();

    @Column(name = "status_pagamento", nullable = false)
    private String statusPagamento = "PENDENTE";

    @Column(name = "comprovante_url")
    private String comprovanteUrl;
}
