package com.example.api.controllers;

import com.example.api.entities.DocumentoImovel;
import com.example.api.entities.TipoDocumentoImovel;
import com.example.api.services.DocumentoImovelService;
import com.example.api.dtos.DocumentoImovelDTO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/documento_imovel")
@CrossOrigin(origins = "*")
@Tag(name = "Documento_Imovel - Documentos de Propriedades", description = "API para gerenciamento da tabela documento_imovel")
public class DocumentoImovelController {

    @Autowired
    private DocumentoImovelService documentoImovelService;

    @PostMapping(value = "/criar", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "🔥 Criar documento com upload", description = " ✋ Adiciona novo documento com upload real de arquivo")
    public ResponseEntity<?> criarDocumento(
            @RequestParam("idImovel") Long idImovel,
            @RequestParam("tipoDocumento") TipoDocumentoImovel tipoDocumento,
            @RequestParam("documento") MultipartFile documento) {
        try {
            DocumentoImovel novoDocumento = documentoImovelService.criarDocumento(idImovel, tipoDocumento, documento);
            DocumentoImovelDTO dto = new DocumentoImovelDTO(novoDocumento);
            return ResponseEntity.ok(dto);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "error", e.getMessage()
            ));
        }
    }

    @PutMapping(value = "/atualizar/{id}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "🔧 Atualizar documento com upload novo", description = " ✋ Permite atualizar tipo e substituir arquivo")
    public ResponseEntity<?> atualizarDocumento(
            @PathVariable Long id,
            @RequestParam(value = "tipoDocumento", required = false) TipoDocumentoImovel tipoDocumento,
            @RequestParam(value = "documento", required = false) MultipartFile novoDocumento) {
        try {
            DocumentoImovel documentoAtualizado = documentoImovelService.atualizarDocumento(id, tipoDocumento, novoDocumento);
            DocumentoImovelDTO dto = new DocumentoImovelDTO(documentoAtualizado);
            return ResponseEntity.ok(dto);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "error", e.getMessage()
            ));
        }
    }

    @DeleteMapping("/deletar/{id}")
    @Operation(summary = "Deletar documento", description = "Remove documento e arquivo físico")
    public ResponseEntity<?> deletarDocumento(@PathVariable Long id) {
        try {
            documentoImovelService.deletarDocumento(id);
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Documento deletado com sucesso"
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "error", e.getMessage()
            ));
        }
    }

    @GetMapping("/{id}")
    @Operation(summary = "Buscar documento por ID", description = "Busca um documento específico pelo ID")
    public ResponseEntity<DocumentoImovelDTO> buscarPorId(@PathVariable Long id) {
        DocumentoImovel documento = documentoImovelService.buscarPorId(id)
            .orElseThrow(() -> new RuntimeException("Documento não encontrado"));
        DocumentoImovelDTO dto = new DocumentoImovelDTO(documento);
        return ResponseEntity.ok(dto);
    }

    @GetMapping("/listar")
    @Operation(summary = "Listar todos documentos", description = "Lista todos os documentos de imóveis")
    public ResponseEntity<List<DocumentoImovelDTO>> listarTodos() {
        List<DocumentoImovel> documentos = documentoImovelService.listarTodos();
        List<DocumentoImovelDTO> dtos = documentos.stream().map(DocumentoImovelDTO::new).collect(Collectors.toList());
        return ResponseEntity.ok(dtos);
    }

    @GetMapping("/imovel/{idImovel}")
    @Operation(summary = "Listar documentos por imóvel", description = "Lista todos os documentos de um imóvel específico")
    public ResponseEntity<List<DocumentoImovelDTO>> listarPorImovel(@PathVariable Long idImovel) {
        List<DocumentoImovel> documentos = documentoImovelService.buscarPorImovel(idImovel);
        List<DocumentoImovelDTO> dtos = documentos.stream().map(DocumentoImovelDTO::new).collect(Collectors.toList());
        return ResponseEntity.ok(dtos);
    }

    @GetMapping("/tipo/{tipoDocumento}")
    @Operation(summary = "Listar documentos por tipo", description = "Lista documentos por tipo (ESCRITURA, CERTIDÃO, etc.)")
    public ResponseEntity<List<DocumentoImovelDTO>> listarPorTipo(@PathVariable TipoDocumentoImovel tipoDocumento) {
        List<DocumentoImovel> documentos = documentoImovelService.buscarPorTipo(tipoDocumento);
        List<DocumentoImovelDTO> dtos = documentos.stream().map(DocumentoImovelDTO::new).collect(Collectors.toList());
        return ResponseEntity.ok(dtos);
    }
}
