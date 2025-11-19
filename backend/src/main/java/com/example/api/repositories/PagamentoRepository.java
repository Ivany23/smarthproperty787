package com.example.api.repositories;

import com.example.api.entities.Anunciante;
import com.example.api.entities.Pagamento;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PagamentoRepository extends JpaRepository<Pagamento, Long> {
    List<Pagamento> findByAnunciante(Anunciante anunciante);
}
