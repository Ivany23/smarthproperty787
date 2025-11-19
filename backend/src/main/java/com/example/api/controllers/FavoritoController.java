
package com.example.api.controllers;

import com.example.api.dtos.FavoritoDTO;
import com.example.api.services.FavoritoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/favoritos")
public class FavoritoController {

    @Autowired
    private FavoritoService favoritoService;

    @PostMapping
    public ResponseEntity<FavoritoDTO> createFavorito(@RequestBody FavoritoDTO favoritoDTO) {
        return ResponseEntity.ok(favoritoService.createFavorito(favoritoDTO));
    }

    @GetMapping("/visitante/{idVisitante}")
    public ResponseEntity<List<FavoritoDTO>> getFavoritosByVisitante(@PathVariable Long idVisitante) {
        return ResponseEntity.ok(favoritoService.getFavoritosByVisitante(idVisitante));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteFavorito(@PathVariable Long id) {
        favoritoService.deleteFavorito(id);
        return ResponseEntity.noContent().build();
    }
}
