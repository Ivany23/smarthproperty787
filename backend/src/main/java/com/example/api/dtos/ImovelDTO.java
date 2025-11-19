package com.example.api.dtos;

import com.example.api.entities.Imovel;
import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.List;

@Schema(description = "Dados do imóvel")
public record ImovelDTO(
    @Schema(description = "ID do imóvel", example = "1")
    Long id,

    @Schema(description = "Título do imóvel", example = "Casa Moderna Centro Maputo")
    String titulo,

    @Schema(description = "Descrição detalhada", example = "Casa moderna com 3 quartos")
    String descricao,

    @Schema(description = "Preço em MZN", example = "5000000.00")
    BigDecimal precoMzn,

    @Schema(description = "Área em metros quadrados", example = "120.5")
    BigDecimal area,

    @Schema(description = "Finalidade", allowableValues = {"VENDA", "ARRENDAMENTO"}, example = "VENDA")
    String finalidade,

    @Schema(description = "Status do imóvel", allowableValues = {"RASCUNHO", "DISPONIVEL", "NEGOCIACAO", "FECHADO"}, example = "DISPONIVEL")
    String statusImovel,

    @Schema(description = "URL da imagem principal", example = "/uploads/properties/main_123.jpg")
    String imagemPrincipalUrl,

    @Schema(description = "Data de criação", example = "2025-11-16T15:30:00")
    OffsetDateTime dataCriacao,

    @Schema(description = "ID do anunciante", example = "1")
    Long idAnunciante,

    @Schema(description = "Categoria", allowableValues = {"Casa", "Apartamento", "Vivenda", "Quarto", "Flat"}, example = "Casa")
    String categoria,

    @Schema(description = "Lista de imagens do imóvel")
    List<ImovelImagemDTO> imagens
) {
    public ImovelDTO(Imovel imovel, List<ImovelImagemDTO> imagens) {
        this(
            imovel.getId(),
            imovel.getTitulo(),
            imovel.getDescricao(),
            imovel.getPrecoMzn(),
            imovel.getArea(),
            imovel.getFinalidade(),
            imovel.getStatusImovel(),
            imovel.getImagemPrincipalUrl(),
            imovel.getDataCriacao(),
            imovel.getIdAnunciante(),
            imovel.getCategoria(),
            imagens
        );
    }
}
