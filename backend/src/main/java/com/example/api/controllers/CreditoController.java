package com.example.api.controllers;
import com.example.api.entities.Credito;
import com.example.api.services.AnuncianteService;
import com.example.api.services.VisitanteService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.math.BigDecimal;
import java.util.Map;
@RestController
@RequestMapping("/api/creditos")
@CrossOrigin(origins = "*")
@Tag(name = "Créditos", description = "API para créditos")
public class CreditoController {
    @Autowired
    private AnuncianteService anuncianteService;
    @Autowired
    private VisitanteService visitanteService;
    @GetMapping("/anunciante/{idAnunciante}")
    @Operation(summary = "Ver créditos", description = "Visualiza saldo de créditos")
    public ResponseEntity<?> visualizarCreditosAnunciante(@PathVariable Long idAnunciante) {
        try {
            Credito credito = anuncianteService.buscarCreditosPorAnunciante(idAnunciante);
            return ResponseEntity.ok(Map.of(
                "success", true,
                "anunciante_id", idAnunciante,
                "saldo_creditos", credito.getSaldo(),
                "ultima_atualizacao", credito.getDataAtualizacao()
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "error", e.getMessage()));
        }
    }
    @GetMapping("/todos")
    @Operation(summary = "Listar saldos", description = "Lista saldos de todos anunciantes")
    public ResponseEntity<?> listarTodosCreditos() {
        try {
            var creditos = anuncianteService.listarTodosCreditos();
            return ResponseEntity.ok(Map.of(
                "success", true,
                "creditos", creditos.isEmpty() ? "Nenhum crédito encontrado" : creditos,
                "total_registros", creditos.size()
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "error", e.getMessage()));
        }
    }

    @PostMapping("/comprar/anunciante/{idAnunciante}")
    @Operation(summary = "Comprar créditos", description = "Compra créditos usando MPESA ou EMOLA (1 MZN = 1 crédito)")
    public ResponseEntity<?> comprarCreditos(
            @PathVariable Long idAnunciante,
            @RequestParam Long idVisitante,
            @RequestParam String metodoPagamento,
            @RequestParam BigDecimal valorPago) {
        try {
            if (!metodoPagamento.equals("MPESA") && !metodoPagamento.equals("EMOLA")) {
                throw new RuntimeException("Método inválido. Use MPESA ou EMOLA");
            }
            if (valorPago.compareTo(new BigDecimal("1")) < 0 || valorPago.compareTo(new BigDecimal("1000")) > 0) {
                throw new RuntimeException("Valor deve ser entre 1-1000 MZN");
            }
            BigDecimal creditosComprados = valorPago; // 1 MZN = 1 crédito
            Map<String, Object> resultado = anuncianteService.comprarCreditosComRegistro(idAnunciante, creditosComprados, metodoPagamento, valorPago);
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Compra realizada (1 MZN = 1 crédito)",
                "comprador_id", idVisitante,
                "anunciante_id", idAnunciante,
                "metodo_pagamento", metodoPagamento,
                "valor_pago", valorPago,
                "creditos_comprados", creditosComprados,
                "saldo_atual", resultado.get("saldo_atual")
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "error", e.getMessage()));
        }
    }
}
