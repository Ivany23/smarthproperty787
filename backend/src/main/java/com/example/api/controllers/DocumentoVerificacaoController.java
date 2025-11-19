package com.example.api.controllers;

import com.example.api.dtos.DocumentoVerificacaoDTO;
import com.example.api.entities.Anunciante;
import com.example.api.entities.DocumentoVerificacao;
import com.example.api.entities.TipoDocumento;
import com.example.api.services.DocumentoVerificacaoService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/documentos-verificacao")
@CrossOrigin(origins = "*")
@Tag(name = "Documentos de Verificação", description = "API para gerenciamento de documentos de verificação de anunciantes")
public class DocumentoVerificacaoController {

    @Autowired
    private DocumentoVerificacaoService documentoService;

    @PostMapping(value = "/criar", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "Criar documento de verificação", description = "Cria um novo documento de verificação com upload de arquivo")
    public ResponseEntity<?> criarDocumento(
            @RequestParam("anuncianteId") Long anuncianteId,
            @RequestParam("tipoDocumento") String tipoDocumentoStr,
            @RequestParam("documento") MultipartFile documento) {
        try {
            TipoDocumento tipoDocumento = TipoDocumento.valueOf(tipoDocumentoStr);
            DocumentoVerificacao novoDocumento = documentoService.uploadDocumento(anuncianteId, tipoDocumento, documento);
            DocumentoVerificacaoDTO dto = new DocumentoVerificacaoDTO(novoDocumento);
            return ResponseEntity.ok(dto);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "error", e.getMessage()
            ));
        }
    }

    @GetMapping("/anunciante/{anuncianteId}")
    @Operation(summary = "Listar documentos por anunciante", description = "Retorna todos os documentos de verificação de um anunciante específico")
    public ResponseEntity<List<DocumentoVerificacaoDTO>> listarDocumentosPorAnunciante(@PathVariable Long anuncianteId) {
        List<DocumentoVerificacao> documentos = documentoService.listarDocumentosPorAnunciante(anuncianteId);
        List<DocumentoVerificacaoDTO> dtos = documentos.stream()
                .map(DocumentoVerificacaoDTO::new)
                .collect(Collectors.toList());
        return ResponseEntity.ok(dtos);
    }

    @GetMapping("/buscar/{id}")
    @Operation(summary = "Buscar documento específico", description = "Retorna um documento de verificação específico pelo ID")
    public ResponseEntity<DocumentoVerificacaoDTO> buscarDocumento(@PathVariable Long id) {
        return documentoService.buscarDocumento(id)
                .map(documento -> ResponseEntity.ok(new DocumentoVerificacaoDTO(documento)))
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping(value = "/atualizar/{id}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "Atualizar documento", description = "Atualiza um documento de verificação existente com novo arquivo ou tipo")
    public ResponseEntity<?> atualizarDocumento(
            @PathVariable Long id,
            @RequestParam("tipoDocumento") String tipoDocumentoStr,
            @RequestParam(value = "documento", required = false) MultipartFile documento) {
        try {
            TipoDocumento tipoDocumento = TipoDocumento.valueOf(tipoDocumentoStr);
            DocumentoVerificacao documentoAtualizado = documentoService.atualizarDocumento(id, tipoDocumento, documento);
            DocumentoVerificacaoDTO dto = new DocumentoVerificacaoDTO(documentoAtualizado);
            return ResponseEntity.ok(dto);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "error", e.getMessage()
            ));
        }
    }

    @DeleteMapping("/remover/{id}")
    @Operation(summary = "Remover documento", description = "Remove um documento de verificação e seu arquivo associado")
    public ResponseEntity<?> removerDocumento(@PathVariable Long id) {
        try {
            documentoService.deletarDocumento(id);
            return ResponseEntity.ok(Map.of("success", true, "message", "Documento removido com sucesso"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "error", e.getMessage()
            ));
        }
    }

    @GetMapping("/todos")
    @Operation(summary = "Listar todos os documentos", description = "Retorna todos os documentos de verificação do sistema")
    public ResponseEntity<List<DocumentoVerificacaoDTO>> listarTodosDocumentos() {
        List<DocumentoVerificacao> documentos = documentoService.listarTodosDocumentos();
        List<DocumentoVerificacaoDTO> dtos = documentos.stream()
                .map(DocumentoVerificacaoDTO::new)
                .collect(Collectors.toList());
        return ResponseEntity.ok(dtos);
    }


}
