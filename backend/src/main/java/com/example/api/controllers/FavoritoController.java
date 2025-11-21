
package com.example.api.controllers;

import com.example.api.dtos.FavoritoDTO;
import com.example.api.services.FavoritoService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/favoritos")
@CrossOrigin(origins = "*")
@Tag(name = "Favoritos", description = "API para gerenciar favoritos de imóveis")
public class FavoritoController {

    @Autowired
    private FavoritoService favoritoService;

    @PostMapping("/adicionar")
    @Operation(summary = "❤️ Adicionar favorito", description = "Adiciona um imóvel aos favoritos do visitante")
    public ResponseEntity<?> adicionarFavorito(
            @RequestParam Long idVisitante,
            @RequestParam Long idImovel) {
        try {
            FavoritoDTO favorito = favoritoService.adicionarFavorito(idVisitante, idImovel);
            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "message", "Favorito adicionado com sucesso",
                    "favorito", favorito));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "error", e.getMessage()));
        }
    }

    @DeleteMapping("/remover")
    @Operation(summary = "💔 Remover favorito", description = "Remove um imóvel dos favoritos do visitante")
    public ResponseEntity<?> removerFavorito(
            @RequestParam Long idVisitante,
            @RequestParam Long idImovel) {
        try {
            favoritoService.removerFavorito(idVisitante, idImovel);
            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "message", "Favorito removido com sucesso"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "error", e.getMessage()));
        }
    }

    @GetMapping("/visitante/{idVisitante}")
    @Operation(summary = "📋 Listar favoritos", description = "Lista todos os favoritos de um visitante")
    public ResponseEntity<List<FavoritoDTO>> listarFavoritos(@PathVariable Long idVisitante) {
        return ResponseEntity.ok(favoritoService.getFavoritosByVisitante(idVisitante));
    }

    @GetMapping("/verificar")
    @Operation(summary = "✅ Verificar favorito", description = "Verifica se um imóvel está nos favoritos")
    public ResponseEntity<?> verificarFavorito(
            @RequestParam Long idVisitante,
            @RequestParam Long idImovel) {
        boolean isFavorito = favoritoService.isFavorito(idVisitante, idImovel);
        return ResponseEntity.ok(Map.of(
                "success", true,
                "isFavorito", isFavorito));
    }
}
