package com.example.api.repositories;
import com.example.api.entities.Localizacao;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;
import java.util.Optional;
public interface LocalizacaoRepository extends JpaRepository<Localizacao, Long> {
    Optional<Localizacao> findByIdImovel(Long idImovel);
    List<Localizacao> findByProvincia(String provincia);
    List<Localizacao> findByCidade(String cidade);
    @Query("SELECT l FROM Localizacao l WHERE l.provincia = :provincia AND l.cidade = :cidade")
    List<Localizacao> findByProvinciaAndCidade(@Param("provincia") String provincia, @Param("cidade") String cidade);
}
