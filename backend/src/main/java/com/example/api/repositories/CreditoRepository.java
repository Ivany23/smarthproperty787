package com.example.api.repositories;

import com.example.api.entities.Anunciante;
import com.example.api.entities.Credito;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CreditoRepository extends JpaRepository<Credito, Long> {
    Optional<Credito> findByAnunciante(Anunciante anunciante);
    Optional<Credito> findByAnuncianteId(Long anuncianteId);
}
