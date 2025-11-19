package com.example.api.controllers;

import com.example.api.dtos.ImovelDTO;
import com.example.api.entities.Imovel;import com.example.api.entities.Anunciante;
import com.example.api.entities.ImovelImagem;
import com.example.api.services.ImovelService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

import com.example.api.repositories.AnuncianteRepository;

// =========================================
// CONTROLLER PARA TABELA "imovel"
// =========================================
@RestController
@RequestMapping("/api/imovel")
@CrossOrigin(origins = "*")
@Tag(name = "Imovel - Propriedade", description = "API para gerenciamento da tabela imovel")
public class ImovelController {

    private static final String MAIN_IMAGES_DIR = "backend/uploads/properties/main/";

    // Allowed image MIME types for main image
    private static final String[] ALLOWED_IMAGE_TYPES = {
        "image/jpeg", "image/jpg", "image/png", "image/gif", "image/bmp", "image/webp"
    };

    @Autowired
    private ImovelService imovelService;

    @Autowired
    private AnuncianteRepository anuncianteRepository;

    // ============ OPERACOES BASICAS ==============

    @PostMapping(value = "/criar", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "🏠 Criar imóvel com imagem principal", description = "Cria imóvel e opcionalmente faz upload da imagem principal")
    public ResponseEntity<?> criarImovel(
            @RequestParam("titulo") String titulo,
            @RequestParam("descricao") String descricao,
            @RequestParam("precoMzn") BigDecimal precoMzn,
            @RequestParam("area") BigDecimal area,
            @RequestParam("finalidade") String finalidade,
            @RequestParam("categoria") String categoria,
            @RequestParam("idAnunciante") Long idAnunciante,
            @RequestParam(value = "imagemPrincipal", required = false) MultipartFile imagemPrincipal) {
        try {
            // Validate anunciante exists
            Optional<Anunciante> anuncianteOpt = anuncianteRepository.findById(idAnunciante);
            if (anuncianteOpt.isEmpty()) {
                throw new RuntimeException("Anunciante não encontrado");
            }

            // Handle main image upload if provided
            String mainImageUrl = null;
            if (imagemPrincipal != null && !imagemPrincipal.isEmpty()) {
                validateImageFile(imagemPrincipal);

                // Create directories
                Files.createDirectories(Paths.get(MAIN_IMAGES_DIR));

                // Generate unique filename
                String fileName = UUID.randomUUID().toString() + "_main_" + imagemPrincipal.getOriginalFilename();
                Path filePath = Paths.get(MAIN_IMAGES_DIR + fileName);
                Files.write(filePath, imagemPrincipal.getBytes());
                mainImageUrl = "/uploads/properties/main/" + fileName;
            }

            // Create property manually (since ImovelService expects MultipartFile)
            Imovel imovel = new Imovel();
            imovel.setTitulo(titulo);
            imovel.setDescricao(descricao);
            imovel.setPrecoMzn(precoMzn);
            imovel.setArea(area);
            imovel.setFinalidade(finalidade);
            imovel.setStatusImovel("DISPONIVEL");
            imovel.setImagemPrincipalUrl(mainImageUrl);
            imovel.setDataCriacao(OffsetDateTime.now());
            imovel.setIdAnunciante(idAnunciante);
            imovel.setCategoria(categoria);

            Imovel saved = imovelService.save(imovel); // Assuming we add this method

            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Imóvel criado com sucesso",
                "imovel", saved,
                "imagem_principal_url", mainImageUrl
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "error", e.getMessage()
            ));
        }
    }

    @GetMapping("/buscar/{id}")
    @Operation(summary = "Buscar imóvel", description = "Consulta um registro na tabela imovel")
    public ResponseEntity<?> buscarImovel(@PathVariable Long id) {
        return imovelService.buscarImovel(id)
                .map(imovel -> ResponseEntity.ok(Map.of(
                    "success", true,
                    "imovel", imovel
                )))
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping(value = "/atualizar/{id}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "🏠 Atualizar imóvel com imagem principal", description = "Atualiza imóvel e opcionalmente troca imagem principal")
    public ResponseEntity<?> atualizarImovel(
            @PathVariable Long id,
            @RequestParam("titulo") String titulo,
            @RequestParam("descricao") String descricao,
            @RequestParam("precoMzn") BigDecimal precoMzn,
            @RequestParam("area") BigDecimal area,
            @RequestParam("finalidade") String finalidade,
            @RequestParam("categoria") String categoria,
            @RequestParam(value = "imagemPrincipal", required = false) MultipartFile imagemPrincipal) {
        try {
            // Get existing property
            Optional<Imovel> imovelOpt = imovelService.buscarImovel(id);
            if (imovelOpt.isEmpty()) {
                return ResponseEntity.notFound().build();
            }

            Imovel imovel = imovelOpt.get();
            String oldMainImageUrl = imovel.getImagemPrincipalUrl();

            // Handle main image update if provided
            String newMainImageUrl = oldMainImageUrl;
            if (imagemPrincipal != null && !imagemPrincipal.isEmpty()) {
                validateImageFile(imagemPrincipal);

                // Delete old main image
                if (oldMainImageUrl != null) {
                    String oldFileName = oldMainImageUrl.substring("/uploads/properties/main/".length());
                    Path oldPath = Paths.get(MAIN_IMAGES_DIR + oldFileName);
                    Files.deleteIfExists(oldPath);
                }

                // Save new main image
                Files.createDirectories(Paths.get(MAIN_IMAGES_DIR));
                String fileName = UUID.randomUUID().toString() + "_main_" + imagemPrincipal.getOriginalFilename();
                Path filePath = Paths.get(MAIN_IMAGES_DIR + fileName);
                Files.write(filePath, imagemPrincipal.getBytes());
                newMainImageUrl = "/uploads/properties/main/" + fileName;
            }

            // Update property data
            imovel.setTitulo(titulo);
            imovel.setDescricao(descricao);
            imovel.setPrecoMzn(precoMzn);
            imovel.setArea(area);
            imovel.setFinalidade(finalidade);
            imovel.setCategoria(categoria);
            imovel.setImagemPrincipalUrl(newMainImageUrl);

            Imovel saved = imovelService.save(imovel);

            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Imóvel atualizado com sucesso",
                "imovel", saved,
                "imagem_principal_anterior", oldMainImageUrl,
                "imagem_principal_atual", newMainImageUrl
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "error", e.getMessage()
            ));
        }
    }

    @DeleteMapping("/deletar/{id}")
    @Operation(summary = "Deletar imóvel", description = "Remove registro da tabela imovel")
    public ResponseEntity<?> deletarImovel(@PathVariable Long id) {
        try {
            imovelService.deletarImovel(id);
            return ResponseEntity.ok(Map.of("success", true, "message", "Imóvel deletado com sucesso"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "error", e.getMessage()
            ));
        }
    }

    // ============ CONSULTAS ==============

    @GetMapping("/listar")
    @Operation(summary = "Listar imóveis", description = "Lista todos registros de imóveis disponíveis")
    public ResponseEntity<List<Imovel>> listarImoveis() {
        List<Imovel> imoveis = imovelService.listarImoveis();
        return ResponseEntity.ok(imoveis);
    }

    @GetMapping("/anunciante/{idAnunciante}")
    @Operation(summary = "Listar imóveis por anunciante", description = "Lista imóveis de um anunciante específico")
    public ResponseEntity<List<Imovel>> listarPorAnunciante(@PathVariable Long idAnunciante) {
        List<Imovel> imoveis = imovelService.listarImoveisPorAnunciante(idAnunciante);
        return ResponseEntity.ok(imoveis);
    }

    // ============ MÉTODOS AUXILIARES ==============

    private void validateImageFile(MultipartFile file) {
        String contentType = file.getContentType();
        if (contentType == null) {
            throw new RuntimeException("Tipo de ficheiro não identificado");
        }

        boolean isValidImage = false;
        for (String allowedType : ALLOWED_IMAGE_TYPES) {
            if (allowedType.equals(contentType.toLowerCase())) {
                isValidImage = true;
                break;
            }
        }

        if (!isValidImage) {
            throw new RuntimeException("Apenas imagens são permitidas (JPEG, PNG, GIF, BMP, WebP)");
        }
    }
}
