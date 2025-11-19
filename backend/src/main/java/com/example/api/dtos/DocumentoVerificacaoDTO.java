package com.example.api.dtos;

import com.example.api.entities.DocumentoVerificacao;
import com.example.api.entities.TipoDocumento;
import lombok.Data;
import io.swagger.v3.oas.annotations.media.Schema;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;

@Schema(description = "Dados do documento de verificação")
public record DocumentoVerificacaoDTO(
    @Schema(description = "ID do documento", example = "1")
    Long id,

    @Schema(description = "ID do anunciante", example = "1")
    Long idAnunciante,

    @Schema(description = "Tipo do documento", example = "BI", allowableValues = {"BI", "PASSAPORTE", "NUIT", "CERTIDAO_NASCIMENTO"})
    TipoDocumento tipoDocumento,

    @Schema(description = "URL do documento", example = "/uploads/documents/123.pdf")
    String documentoUrl,

    @Schema(description = "Data de upload", example = "2025-11-14T12:00:00")
    LocalDateTime dataUpload,

    @Schema(description = "Status de verificação", example = "true")
    Boolean verificado
) {
    public DocumentoVerificacaoDTO(DocumentoVerificacao documento) {
        this(
            documento.getId(),
            documento.getAnunciante().getId(),
            documento.getTipoDocumento(),
            documento.getDocumentoUrl(),
            documento.getDataUpload(),
            documento.getVerificado()
        );
    }
}

@Schema(description = "Dados para upload de documento de verificação")
class DocumentoUploadDTO {

    @Schema(description = "ID do anunciante", example = "1", required = true)
    private Long anuncianteId;

    @Schema(description = "Tipo do documento", allowableValues = {"BI", "PASSAPORTE", "NUIT", "CERTIDAO_NASCIMENTO"}, required = true)
    private TipoDocumento tipoDocumento;

    @Schema(description = "Arquivo do documento", required = true)
    private MultipartFile documento;

    public DocumentoUploadDTO() {}

    public DocumentoUploadDTO(Long anuncianteId, TipoDocumento tipoDocumento, MultipartFile documento) {
        this.anuncianteId = anuncianteId;
        this.tipoDocumento = tipoDocumento;
        this.documento = documento;
    }

    public Long getAnuncianteId() {
        return anuncianteId;
    }

    public void setAnuncianteId(Long anuncianteId) {
        this.anuncianteId = anuncianteId;
    }

    public TipoDocumento getTipoDocumento() {
        return tipoDocumento;
    }

    public void setTipoDocumento(TipoDocumento tipoDocumento) {
        this.tipoDocumento = tipoDocumento;
    }

    public MultipartFile getDocumento() {
        return documento;
    }

    public void setDocumento(MultipartFile documento) {
        this.documento = documento;
    }
}
