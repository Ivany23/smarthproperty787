package com.example.api.repositories;

import com.example.api.entities.Anunciante;
import com.example.api.entities.Visitante;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface AnuncianteRepository extends JpaRepository<Anunciante, Long> {
    Optional<Anunciante> findByVisitante(Visitante visitante);
    Optional<Anunciante> findByVisitanteId(Long visitanteId);
}
