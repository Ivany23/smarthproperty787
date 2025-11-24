package com.example.api.controllers;

import com.example.api.dtos.MarcacaoDTO;
import com.example.api.services.MarcacaoService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/marcacoes")
@CrossOrigin(origins = "*")
@Tag(name = "Marcações", description = "API para gerenciar marcações de visitas a imóveis")
public class MarcacaoController {

    @Autowired
    private MarcacaoService marcacaoService;

    @PostMapping("/criar")
    @Operation(summary = "📅 Criar marcação", description = "Qualquer visitante pode criar uma marcação (status inicial: PENDENTE)")
    public ResponseEntity<?> criarMarcacao(@RequestBody MarcacaoDTO marcacaoDTO) {
        try {
            MarcacaoDTO marcacao = marcacaoService.criarMarcacao(marcacaoDTO);
            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "message", "Marcação criada com sucesso. Aguardando confirmação do anunciante.",
                    "marcacao", marcacao));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "error", e.getMessage()));
        }
    }

    @PutMapping("/confirmar/{idMarcacao}")
    @Operation(summary = "✅ Confirmar marcação", description = "Apenas o dono do imóvel pode confirmar")
    public ResponseEntity<?> confirmarMarcacao(
            @PathVariable Long idMarcacao,
            @RequestParam Long idAnunciante) {
        try {
            MarcacaoDTO marcacao = marcacaoService.confirmarMarcacao(idMarcacao, idAnunciante);
            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "message", "Marcação confirmada com sucesso",
                    "marcacao", marcacao));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "error", e.getMessage()));
        }
    }

    @PutMapping("/cancelar/{idMarcacao}")
    @Operation(summary = "❌ Cancelar marcação", description = "Visitante ou dono do imóvel podem cancelar")
    public ResponseEntity<?> cancelarMarcacao(
            @PathVariable Long idMarcacao,
            @RequestParam Long idUsuario,
            @RequestParam(defaultValue = "false") boolean isAnunciante) {
        try {
            MarcacaoDTO marcacao = marcacaoService.cancelarMarcacao(idMarcacao, idUsuario, isAnunciante);
            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "message", "Marcação cancelada com sucesso",
                    "marcacao", marcacao));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "error", e.getMessage()));
        }
    }

    @GetMapping("/visitante/{idVisitante}")
    @Operation(summary = "📋 Listar marcações do visitante", description = "Lista todas as marcações de um visitante")
    public ResponseEntity<List<MarcacaoDTO>> listarMarcacoesVisitante(@PathVariable Long idVisitante) {
        return ResponseEntity.ok(marcacaoService.listarMarcacoesVisitante(idVisitante));
    }

    @GetMapping("/imovel/{idImovel}")
    @Operation(summary = "🏠 Listar marcações do imóvel", description = "Lista todas as marcações de um imóvel")
    public ResponseEntity<List<MarcacaoDTO>> listarMarcacoesImovel(@PathVariable Long idImovel) {
        return ResponseEntity.ok(marcacaoService.listarMarcacoesImovel(idImovel));
    }

    @GetMapping("/{id}")
    @Operation(summary = "🔍 Buscar marcação", description = "Busca uma marcação específica por ID")
    public ResponseEntity<?> buscarMarcacao(@PathVariable Long id) {
        try {
            MarcacaoDTO marcacao = marcacaoService.buscarPorId(id);
            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "marcacao", marcacao));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "error", e.getMessage()));
        }
    }
}
