package com.example.api.controllers;

import com.example.api.dtos.*;
import com.example.api.entities.Anunciante;
import com.example.api.entities.Credito;
import com.example.api.entities.Pagamento;
import com.example.api.repositories.AnuncianteRepository;
import com.example.api.repositories.CreditoRepository;
import com.example.api.services.PagamentoService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/pagamentos")
@CrossOrigin(origins = "*")
@Tag(name = "Pagamentos", description = "API para gerenciamento de pagamentos")
public class PagamentoController {

    @Autowired
    private PagamentoService pagamentoService;

    @Autowired
    private AnuncianteRepository anuncianteRepository;

    @Autowired
    private CreditoRepository creditoRepository;

    @PostMapping("/processar")
    @Operation(summary = "Processar pagamento", description = "Processa um pagamento e automaticamente converte visitante em anunciante se necessário")
    public ResponseEntity<?> processarPagamento(@Valid @RequestBody ProcessarPagamentoDTO request) {
        try {
            Pagamento pagamento = pagamentoService.processarPagamento(
                request.visitanteId(),
                request.valor(),
                request.metodoPagamento(),
                null
            );

            Anunciante anunciante = pagamento.getAnunciante();
            Optional<Credito> creditoOpt = creditoRepository.findByAnunciante(anunciante);

            PagamentoResponseDTO response = new PagamentoResponseDTO(
                new PagamentoDTO(pagamento),
                new AnuncianteDTO(anunciante),
                creditoOpt.map(CreditoDTO::new).orElse(null),
                "Pagamento processado com sucesso. Visitante convertido em anunciante."
            );

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "error", e.getMessage()
            ));
        }
    }

    @GetMapping
    @Operation(summary = "Listar pagamentos", description = "Retorna todos os pagamentos ou pagamentos de um anunciante específico")
    public ResponseEntity<List<PagamentoDTO>> listarPagamentos(@RequestParam(required = false) Long anuncianteId) {
        List<Pagamento> pagamentos;
        if (anuncianteId != null) {
            pagamentos = pagamentoService.listarPagamentosPorAnunciante(anuncianteId);
        } else {
            pagamentos = pagamentoService.listarPagamentos();
        }
        List<PagamentoDTO> dtos = pagamentos.stream()
                .map(PagamentoDTO::new)
                .collect(Collectors.toList());
        return ResponseEntity.ok(dtos);
    }


}
