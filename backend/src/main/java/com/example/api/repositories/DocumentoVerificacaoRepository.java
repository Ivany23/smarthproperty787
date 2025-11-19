package com.example.api.repositories;

import com.example.api.entities.Anunciante;
import com.example.api.entities.DocumentoVerificacao;
import com.example.api.entities.TipoDocumento;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface DocumentoVerificacaoRepository extends JpaRepository<DocumentoVerificacao, Long> {
    List<DocumentoVerificacao> findByAnunciante(Anunciante anunciante);
    Optional<DocumentoVerificacao> findByAnuncianteAndTipoDocumento(Anunciante anunciante, TipoDocumento tipoDocumento);
}
