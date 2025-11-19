package com.example.api.controllers;
import com.example.api.dtos.ImovelImagemDTO;
import com.example.api.entities.ImovelImagem;
import com.example.api.repositories.ImovelImagemRepository;
import com.example.api.services.ImovelService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;
@RestController
@RequestMapping("/api/imovel_imagem")
@CrossOrigin(origins = "*")
@Tag(name = "Imovel Imagem", description = "API para imagens de imóveis")
public class ImovelImagemController {
    private static final String GALLERY_IMAGES_DIR = "backend/uploads/properties/gallery/";
    private static final String[] ALLOWED_IMAGE_TYPES = {
        "image/jpeg", "image/jpg", "image/png", "image/gif", "image/bmp", "image/webp"
    };
    @Autowired
    private ImovelService imovelService;
    @Autowired
    private ImovelImagemRepository imagemRepository;
    @PostMapping(value = "/adicionar", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "Adicionar imagem", description = "Sistema calcula ordem automaticamente")
    public ResponseEntity<?> adicionarImagem(
            @RequestParam("idImovel") Long idImovel,
            @RequestParam("imagem") MultipartFile imagem) {
        try {
            validateImageFile(imagem);
            Files.createDirectories(Paths.get(GALLERY_IMAGES_DIR));
            long currentCount = imagemRepository.countByImovel(idImovel);
            int ordemAutomatica = (int)currentCount;
            String fileName = UUID.randomUUID().toString() + "_gallery_" + imagem.getOriginalFilename();
            Path filePath = Paths.get(GALLERY_IMAGES_DIR + fileName);
            Files.write(filePath, imagem.getBytes());
            ImovelImagem imagemGaleria = new ImovelImagem();
            imagemGaleria.setIdImovel(idImovel);
            imagemGaleria.setImagemUrl("/uploads/properties/gallery/" + fileName);
            imagemGaleria.setOrdem(ordemAutomatica);
            imagemGaleria.setDataCriacao(OffsetDateTime.now());
            ImovelImagem salva = imagemRepository.save(imagemGaleria);
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Imagem adicionada com sucesso",
                "id_imagem", salva.getId(),
                "ordem_automatica", ordemAutomatica,
                "arquivo", fileName,
                "url_imagem", salva.getImagemUrl()
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "error", e.getMessage()
            ));
        }
    }
    @DeleteMapping("/deletar/{id}")
    @Operation(summary = "Deletar imagem", description = "Remove imagem da galeria")
    public ResponseEntity<?> deletarImagem(@PathVariable Long id) {
        try {
            imovelService.removerImagemGaleria(id);
            return ResponseEntity.ok(Map.of("success", true, "message", "Imagem deletada"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "error", e.getMessage()
            ));
        }
    }
    @GetMapping("/imovel/{idImovel}")
    @Operation(summary = "Listar por imóvel", description = "Lista imagens ordenadas")
    public ResponseEntity<List<ImovelImagemDTO>> listarPorImovel(@PathVariable Long idImovel) {
        List<ImovelImagemDTO> imagens = imovelService.listarImagensGaleria(idImovel)
                .stream()
                .map(ImovelImagemDTO::new)
                .collect(Collectors.toList());
        return ResponseEntity.ok(imagens);
    }
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
