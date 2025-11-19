package com.example.api.dtos;

import com.example.api.entities.ImovelImagem;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.OffsetDateTime;

@Schema(description = "Dados da imagem do imóvel")
public record ImovelImagemDTO(
    @Schema(description = "ID da imagem", example = "1")
    Long id,

    @Schema(description = "ID do imóvel", example = "1")
    Long idImovel,

    @Schema(description = "URL da imagem", example = "/uploads/properties/gallery_123.jpg")
    String imagemUrl,

    @Schema(description = "Ordem da imagem (0 = primeira/principal)", example = "0")
    Integer ordem,

    @Schema(description = "Data de criação da imagem", example = "2025-11-16T15:30:00")
    OffsetDateTime dataCriacao
) {
    public ImovelImagemDTO(ImovelImagem imagem) {
        this(
            imagem.getId(),
            imagem.getIdImovel(),
            imagem.getImagemUrl(),
            imagem.getOrdem(),
            imagem.getDataCriacao()
        );
    }
}
