package com.example.api.dtos;

import com.example.api.entities.Visitante;

import java.time.LocalDateTime;

public record VisitanteDTO(
        Long id,
        String nomeCompleto,
        String email,
        String telefone,
        String statusConta,
        LocalDateTime dataRegistro,
        String codigoVerificacao
) {
    public VisitanteDTO(Visitante visitante) {
        this(
                visitante.getId(),
                visitante.getNomeCompleto(),
                visitante.getEmail(),
                visitante.getTelefone(),
                visitante.getStatusConta(),
                visitante.getDataRegistro(),
                visitante.getCodigoVerificacao()
        );
    }
}
