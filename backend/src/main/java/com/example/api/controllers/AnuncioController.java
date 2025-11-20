package com.example.api.controllers;

import com.example.api.entities.Anuncio;
import com.example.api.services.AnuncioService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/anuncio")
@CrossOrigin(origins = "*")
@Tag(name = "Anuncio", description = "API para anúncios")
public class AnuncioController {
    @Autowired
    private AnuncioService anuncioService;

    @PostMapping("/criar")
    @Operation(summary = "Criar e publicar anúncio", description = "Cria anúncio JÁ PUBLICADO com +30 dias de expiração e debita 50 créditos automaticamente")
    public ResponseEntity<?> criarAnuncio(@RequestParam("idImovel") Long idImovel) {
        try {
            Anuncio anuncio = anuncioService.criarAnuncio(idImovel);
            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "message", "Anúncio criado e PUBLICADO com sucesso! 50 créditos debitados. Expira em 30 dias.",
                    "anuncio", anuncio,
                    "creditos_debitados", 50));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "error", e.getMessage()));
        }
    }

    @PostMapping("/visualizar/{id}")
    @Operation(summary = "Incrementar visualização", description = "Incrementa contador de visualizações")
    public ResponseEntity<?> incrementarVisualizacao(@PathVariable Long id) {
        try {
            anuncioService.incrementarVisualizacao(id);
            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "message", "Visualização registrada"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "error", e.getMessage()));
        }
    }

    @DeleteMapping("/excluir/{id}")
    @Operation(summary = "Excluir anúncio", description = "Exclui anúncio do sistema")
    public ResponseEntity<?> excluirAnuncio(@PathVariable Long id) {
        try {
            anuncioService.excluirAnuncio(id);
            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "message", "Anúncio excluído com sucesso"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "error", e.getMessage()));
        }
    }

    @PutMapping("/expirar-anuncios")
    @Operation(summary = "Expirar anúncios", description = "Scanea anúncios expirados e marca como EXPIRADO")
    public ResponseEntity<?> expirarAnuncios() {
        try {
            anuncioService.expirarAnuncios();
            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "message", "Anúncios vencidos foram expirados"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "error", e.getMessage()));
        }
    }

    @GetMapping("/listar")
    @Operation(summary = "Listar anúncios", description = "Lista todos anúncios independente do status")
    public ResponseEntity<List<Anuncio>> listarTodos() {
        List<Anuncio> anuncios = anuncioService.listarTodos();
        return ResponseEntity.ok(anuncios);
    }

    @GetMapping("/status/{status}")
    @Operation(summary = "Filtrar por status", description = "Lista anúncios por status")
    public ResponseEntity<List<Anuncio>> buscarPorStatus(@PathVariable String status) {
        List<Anuncio> anuncios = anuncioService.buscarPorStatus(status);
        return ResponseEntity.ok(anuncios);
    }

    @GetMapping("/publicados")
    @Operation(summary = "Anúncios ativos", description = "Lista anúncios publicados por data")
    public ResponseEntity<List<Anuncio>> buscarAnunciosPublicados() {
        List<Anuncio> anunciosPublicados = anuncioService.buscarAnunciosPublicados();
        return ResponseEntity.ok(anunciosPublicados);
    }
}
