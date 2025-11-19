package com.example.api.repositories;

import com.example.api.entities.ImovelImagem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ImovelImagemRepository extends JpaRepository<ImovelImagem, Long> {

    @Query("SELECT i FROM ImovelImagem i WHERE i.idImovel = :idImovel ORDER BY i.ordem ASC")
    List<ImovelImagem> findByImovelOrderByOrdemAsc(@Param("idImovel") Long idImovel);

    @Query("SELECT COUNT(i) FROM ImovelImagem i WHERE i.idImovel = :idImovel")
    Long countByImovel(@Param("idImovel") Long idImovel);

    @Modifying
    @Query("UPDATE ImovelImagem i SET i.ordem = :novaOrdem WHERE i.id = :id")
    void updateOrdemById(@Param("novaOrdem") Integer novaOrdem, @Param("id") Long id);

    @Modifying
    @Query("DELETE FROM ImovelImagem i WHERE i.idImovel = :idImovel")
    void deleteByImovel(@Param("idImovel") Long idImovel);
}
