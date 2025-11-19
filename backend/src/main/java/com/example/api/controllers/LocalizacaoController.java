package com.example.api.controllers;
import com.example.api.entities.Localizacao;
import com.example.api.dtos.LocalizacaoDTO;
import com.example.api.services.LocalizacaoService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
@RestController
@RequestMapping("/api/localizacao")
@CrossOrigin(origins = "*")
@Tag(name = "Localizacao", description = "API para localizacoes de imoveis")
public class LocalizacaoController {
    @Autowired
    private LocalizacaoService localizacaoService;
    @PostMapping("/criar")
    @Operation(summary = "Criar localizacao", description = "Cria nova localizacao")
    public ResponseEntity<?> criar(@RequestBody LocalizacaoDTO dto) {
        try {
            Localizacao localizacao = new Localizacao();
            localizacao.setPais(dto.getPais() != null ? dto.getPais() : "Moçambique");
            localizacao.setProvincia(dto.getProvincia());
            localizacao.setCidade(dto.getCidade());
            localizacao.setBairro(dto.getBairro());
            localizacao.setIdImovel(dto.getIdImovel());
            Localizacao salva = localizacaoService.salvar(localizacao);
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Localizacao criada",
                "localizacao", new LocalizacaoDTO(salva)
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "error", e.getMessage()));
        }
    }

    @GetMapping("/provincia/{provincia}")
    @Operation(summary = "Buscar por provincia", description = "Lista localizacoes por provincia")
    public ResponseEntity<List<LocalizacaoDTO>> buscarPorProvincia(@PathVariable String provincia) {
        List<LocalizacaoDTO> localizacoes = localizacaoService.buscarPorProvincia(provincia)
            .stream().map(LocalizacaoDTO::new).collect(Collectors.toList());
        return ResponseEntity.ok(localizacoes);
    }
    @GetMapping("/cidade/{cidade}")
    @Operation(summary = "Buscar por cidade", description = "Lista localizacoes por cidade")
    public ResponseEntity<List<LocalizacaoDTO>> buscarPorCidade(@PathVariable String cidade) {
        List<LocalizacaoDTO> localizacoes = localizacaoService.buscarPorCidade(cidade)
            .stream().map(LocalizacaoDTO::new).collect(Collectors.toList());
        return ResponseEntity.ok(localizacoes);
    }

    @GetMapping("/listar")
    @Operation(summary = "Listar todas", description = "Lista todas as localizacoes")
    public ResponseEntity<List<LocalizacaoDTO>> listarTodos() {
        List<LocalizacaoDTO> localizacoes = localizacaoService.listarTodos()
            .stream().map(LocalizacaoDTO::new).collect(Collectors.toList());
        return ResponseEntity.ok(localizacoes);
    }
    @PutMapping("/atualizar/{id}")
    @Operation(summary = "Atualizar localizacao", description = "Atualiza dados da localizacao")
    public ResponseEntity<?> atualizar(@PathVariable Long id, @RequestBody LocalizacaoDTO dto) {
        try {
            return localizacaoService.buscarPorId(id).map(existing -> {
                existing.setPais(dto.getPais() != null ? dto.getPais() : existing.getPais());
                existing.setProvincia(dto.getProvincia());
                existing.setCidade(dto.getCidade());
                existing.setBairro(dto.getBairro());
                if (dto.getIdImovel() != null) existing.setIdImovel(dto.getIdImovel());
                Localizacao salva = localizacaoService.salvar(existing);
                return ResponseEntity.ok(Map.of(
                    "success", true,
                    "message", "Localizacao atualizada",
                    "localizacao", new LocalizacaoDTO(salva)
                ));
            }).orElse(ResponseEntity.notFound().build());
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "error", e.getMessage()));
        }
    }
    @DeleteMapping("/deletar/{id}")
    @Operation(summary = "Deletar localizacao", description = "Remove localizacao")
    public ResponseEntity<?> deletar(@PathVariable Long id) {
        try {
            localizacaoService.deletar(id);
            return ResponseEntity.ok(Map.of("success", true, "message", "Localizacao deletada"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "error", e.getMessage()));
        }
    }
}
