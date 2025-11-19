package com.example.api.repositories;

import com.example.api.entities.DocumentoImovel;
import com.example.api.entities.Imovel;
import com.example.api.entities.TipoDocumentoImovel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DocumentoImovelRepository extends JpaRepository<DocumentoImovel, Long> {

    List<DocumentoImovel> findByImovel(Imovel imovel);

    List<DocumentoImovel> findByTipoDocumento(TipoDocumentoImovel tipoDocumento);
}
