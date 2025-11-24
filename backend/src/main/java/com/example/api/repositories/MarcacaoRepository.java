package com.example.api.repositories;

import com.example.api.entities.Marcacao;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;

public interface MarcacaoRepository extends JpaRepository<Marcacao, Long> {

    // Buscar marcações por visitante
    List<Marcacao> findByIdVisitanteOrderByDataHoraInicioDesc(Long idVisitante);

    // Buscar marcações por imóvel
    List<Marcacao> findByIdImovelOrderByDataHoraInicioDesc(Long idImovel);

    // Verificar conflito de horário para um visitante
    @Query("SELECT m FROM Marcacao m WHERE m.idVisitante = :idVisitante " +
            "AND m.status != 'CANCELADA' " +
            "AND ((m.dataHoraInicio < :fim AND m.dataHoraFim > :inicio))")
    List<Marcacao> findConflitosVisitante(
            @Param("idVisitante") Long idVisitante,
            @Param("inicio") LocalDateTime inicio,
            @Param("fim") LocalDateTime fim);

    // Verificar conflito de horário para um imóvel
    @Query("SELECT m FROM Marcacao m WHERE m.idImovel = :idImovel " +
            "AND m.status != 'CANCELADA' " +
            "AND ((m.dataHoraInicio < :fim AND m.dataHoraFim > :inicio))")
    List<Marcacao> findConflitosImovel(
            @Param("idImovel") Long idImovel,
            @Param("inicio") LocalDateTime inicio,
            @Param("fim") LocalDateTime fim);
}
