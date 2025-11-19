package com.example.api.controllers;

import com.example.api.entities.Anunciante;
import com.example.api.entities.Credito;
import com.example.api.services.AnuncianteService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/anunciante")
@CrossOrigin(origins = "*")
@Tag(name = "Anunciante - Gestão de Conta", description = "API para gestão da conta do anunciante")
public class AnuncianteController {

    @Autowired
    private AnuncianteService anuncianteService;

    @GetMapping("/{id}")
    @Operation(summary = "ℹ️ Ver informações do anunciante", description = "Visualiza informações básicas de um anunciante")
    public ResponseEntity<?> visualizarAnunciante(@PathVariable Long id) {
        try {
            Anunciante anunciante = anuncianteService.buscarPorId(id);
            return ResponseEntity.ok(anunciante);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @GetMapping("/visitante/{visitanteId}")
    @Operation(summary = "ℹ️ Ver informações do anunciante por ID do visitante", description = "Visualiza informações de um anunciante pelo ID do visitante associado")
    public ResponseEntity<?> visualizarAnunciantePorVisitanteId(@PathVariable Long visitanteId) {
        Optional<Anunciante> anuncianteOpt = anuncianteService.buscarPorVisitanteId(visitanteId);
        if (anuncianteOpt.isPresent()) {
            return ResponseEntity.ok(anuncianteOpt.get());
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/remover-conta/{id}")
    @Operation(summary = "🗑️ Remover conta de anunciante", description = "Remove permanentemente a conta do anunciante")
    public ResponseEntity<?> removerConta(@PathVariable Long id) {
        try {
            anuncianteService.removerContaAnunciante(id);
            return ResponseEntity.ok(Map.of("success", true, "message", "Conta de anunciante removida"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @GetMapping("/{idAnunciante}/creditos")
    @Operation(summary = "💰 Ver créditos do anunciante", description = "Exibe o saldo de créditos do anunciante")
    public ResponseEntity<?> visualizarCreditos(@PathVariable Long idAnunciante) {
        try {
            Credito credito = anuncianteService.buscarCreditosPorAnunciante(idAnunciante);
            return ResponseEntity.ok(Map.of("informacoes_creditos", Map.of("saldo_atual", credito.getSaldo())));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @GetMapping("/listar")
    @Operation(summary = "📋 Listar todos os anunciantes", description = "Lista todos os anunciantes do sistema")
    public ResponseEntity<?> listarAnunciantes() {
        List<Anunciante> anunciantes = anuncianteService.listarTodos();
        return ResponseEntity.ok(Map.of("anunciantes", anunciantes, "total", anunciantes.size()));
    }
}
