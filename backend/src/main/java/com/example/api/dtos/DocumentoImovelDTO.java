package com.example.api.dtos;

import com.example.api.entities.DocumentoImovel;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.OffsetDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DocumentoImovelDTO {
    private Long idDocumento;
    private Long idImovel;
    private String tipoDocumento;
    private String documentoUrl;
    private OffsetDateTime dataUpload;

    public DocumentoImovelDTO(DocumentoImovel entity) {
        this.idDocumento = entity.getIdDocumento();
        this.idImovel = entity.getImovel().getId();
        this.tipoDocumento = entity.getTipoDocumento().name();
        this.documentoUrl = entity.getDocumentoUrl();
        this.dataUpload = entity.getDataUpload();
    }
}
