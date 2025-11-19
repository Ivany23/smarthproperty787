package com.example.api.controllers;
import com.example.api.entities.Visitante;
import com.example.api.repositories.VisitanteRepository;
import com.example.api.services.VisitanteService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
@RestController
@RequestMapping("/api/visitante")
@CrossOrigin(origins = "*")
@Tag(name = "Visitante", description = "API para visitante")
public class VisitanteController {
    @Autowired
    private VisitanteRepository visitanteRepository;
    @Autowired
    private VisitanteService visitanteService;
    @GetMapping("/buscar/{id}")
    @Operation(summary = "Buscar visitante", description = "Consulta registro")
    public ResponseEntity<?> buscarPorId(@PathVariable Long id) {
        try {
            Optional<Visitante> visitanteOpt = visitanteRepository.findById(id);
            if (visitanteOpt.isPresent()) {
                Visitante visitante = visitanteOpt.get();
                return ResponseEntity.ok(Map.of(
                    "id", visitante.getId(),
                    "nomeCompleto", visitante.getNomeCompleto(),
                    "email", visitante.getEmail(),
                    "statusConta", visitante.getStatusConta()
                ));
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
    @PutMapping("/atualizar/{id}")
    @Operation(summary = "Atualizar completo", description = "Atualiza todos dados exceto código verificação")
    public ResponseEntity<?> atualizarVisitante(
            @PathVariable Long id,
            @RequestParam(required = false) String nomeCompleto,
            @RequestParam(required = false) String email,
            @RequestParam(required = false) String telefone,
            @RequestParam(required = false) String senha) {
        try {
            Optional<Visitante> visitanteOpt = visitanteRepository.findById(id);
            if (visitanteOpt.isPresent()) {
                Visitante visitante = visitanteOpt.get();
                if (nomeCompleto != null && !nomeCompleto.trim().isEmpty()) {
                    visitante.setNomeCompleto(nomeCompleto.trim());
                }
                if (email != null && !email.trim().isEmpty()) {
                    visitante.setEmail(email.trim());
                }
                if (telefone != null && !telefone.trim().isEmpty()) {
                    visitante.setTelefone(telefone.trim());
                }
                if (senha != null && !senha.trim().isEmpty()) {
                    visitante.setSenhaHash(new org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder().encode(senha.trim()));
                }
                Visitante salvo = visitanteRepository.save(visitante);
                return ResponseEntity.ok(Map.of(
                    "success", true,
                    "message", "Atualizado com sucesso (todos os campos exceto código verificação)",
                    "visitante", Map.of(
                        "id", salvo.getId(),
                        "nomeCompleto", salvo.getNomeCompleto(),
                        "email", salvo.getEmail(),
                        "telefone", salvo.getTelefone(),
                        "statusConta", salvo.getStatusConta(),
                        "codigoVerificacao", "PRESERVADO_ORIGINAL"
                    )
                ));
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "error", e.getMessage()));
        }
    }
    @DeleteMapping("/deletar/{id}")
    @Operation(summary = "Deletar visitante", description = "Remove registro")
    public ResponseEntity<?> deletarVisitante(@PathVariable Long id) {
        try {
            if (visitanteRepository.existsById(id)) {
                visitanteRepository.deleteById(id);
                return ResponseEntity.ok(Map.of("success", true, "message", "Deletado"));
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
    @GetMapping("/listar")
    @Operation(summary = "Listar visitantes", description = "Lista todos registros")
    public ResponseEntity<?> listarVisitantes() {
        try {
            List<Visitante> visitantes = visitanteRepository.findAll();
            List<Map<String, Object>> response = visitantes.stream()
                .map(v -> {
                    Map<String, Object> visitanteMap = new HashMap<>();
                    visitanteMap.put("id", v.getId());
                    visitanteMap.put("nomeCompleto", v.getNomeCompleto() != null ? v.getNomeCompleto() : "");
                    visitanteMap.put("email", v.getEmail() != null ? v.getEmail() : "");
                    visitanteMap.put("statusConta", v.getStatusConta() != null ? v.getStatusConta() : "");
                    return visitanteMap;
                })
                .collect(java.util.stream.Collectors.toList());
            return ResponseEntity.ok(Map.of(
                "visitantes", response,
                "total", visitantes.size()
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
    @GetMapping("/email/{email}")
    @Operation(summary = "Buscar por email", description = "Retorna dados incluindo código verificação")
    public ResponseEntity<?> buscarPorEmail(@PathVariable String email) {
        try {
            Optional<Visitante> visitanteOpt = visitanteRepository.findByEmail(email);
            if (visitanteOpt.isPresent()) {
                Visitante visitante = visitanteOpt.get();
                Map<String, Object> response = new HashMap<>();
                response.put("id", visitante.getId());
                response.put("nomeCompleto", visitante.getNomeCompleto());
                response.put("email", visitante.getEmail());
                response.put("codigoVerificacao", visitante.getCodigoVerificacao());
                response.put("statusConta", visitante.getStatusConta());
                return ResponseEntity.ok(response);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}
