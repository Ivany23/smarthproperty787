package com.example.api.repositories;

import com.example.api.entities.Imovel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ImovelRepository extends JpaRepository<Imovel, Long> {

    @Query("SELECT i FROM Imovel i WHERE i.idAnunciante = :idAnunciante ORDER BY i.dataCriacao DESC")
    List<Imovel> findByAnunciante(@Param("idAnunciante") Long idAnunciante);

    @Query("SELECT i FROM Imovel i WHERE i.statusImovel = 'DISPONIVEL' ORDER BY i.dataCriacao DESC")
    List<Imovel> findDisponiveis();

    @Query("SELECT i FROM Imovel i WHERE i.categoria = :categoria AND i.statusImovel = 'DISPONIVEL'")
    List<Imovel> findByCategoria(@Param("categoria") String categoria);

    @Query("SELECT i FROM Imovel i WHERE i.finalidade = :finalidade AND i.statusImovel = 'DISPONIVEL'")
    List<Imovel> findByFinalidade(@Param("finalidade") String finalidade);
}
