package com.example.api.repositories;

import com.example.api.entities.Anuncio;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface AnuncioRepository extends JpaRepository<Anuncio, Long> {

    @Query("SELECT a FROM Anuncio a WHERE a.imovel.id = :idImovel")
    List<Anuncio> findByIdImovel(@Param("idImovel") Long idImovel);

    List<Anuncio> findByStatusAnuncio(String statusAnuncio);

    List<Anuncio> findByStatusAnuncioOrderByDataPublicacaoDesc(String statusAnuncio);

    // Atualizar contador de visualizações
    @Modifying
    @Query("UPDATE Anuncio a SET a.visualizacoes = a.visualizacoes + 1 WHERE a.id = :id")
    void incrementarVisualizacoes(@Param("id") Long id);

    // Definir data de expiração
    @Modifying
    @Query("UPDATE Anuncio a SET a.dataExpiracao = :dataExpiracao WHERE a.id = :id")
    void setDataExpiracao(@Param("dataExpiracao") LocalDateTime dataExpiracao, @Param("id") Long id);

    // Atualizar status
    @Modifying
    @Query("UPDATE Anuncio a SET a.statusAnuncio = :status WHERE a.id = :id")
    void updateStatus(@Param("status") String status, @Param("id") Long id);

    // Buscar anúncios expirados
    @Query("SELECT a FROM Anuncio a WHERE a.dataExpiracao < :now AND a.statusAnuncio = 'PUBLICADO'")
    List<Anuncio> findAnunciosExpirados(@Param("now") LocalDateTime now);
}
