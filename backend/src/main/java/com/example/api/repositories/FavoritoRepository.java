package com.example.api.repositories;
import com.example.api.entities.Favorito;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;
import java.util.Optional;
public interface FavoritoRepository extends JpaRepository<Favorito, Long> {
    Optional<Favorito> findByIdVisitanteAndIdImovel(Long idVisitante, Long idImovel);
    List<Favorito> findByIdVisitanteOrderByDataRegistroDesc(Long idVisitante);
    List<Favorito> findByIdImovel(Long idImovel);
    boolean existsByIdVisitanteAndIdImovel(Long idVisitante, Long idImovel);
    @Query("SELECT f FROM Favorito f WHERE f.idVisitante = :idVisitante AND f.idImovel = :idImovel")
    Optional<Favorito> findFavorito(@Param("idVisitante") Long idVisitante, @Param("idImovel") Long idImovel);
}
