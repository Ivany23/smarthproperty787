package com.example.api.services;

import com.example.api.entities.Anunciante;
import com.example.api.entities.Credito;
import com.example.api.entities.Pagamento;
import com.example.api.entities.Visitante;
import com.example.api.repositories.AnuncianteRepository;
import com.example.api.repositories.CreditoRepository;
import com.example.api.repositories.PagamentoRepository;
import com.example.api.repositories.VisitanteRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
public class PagamentoService {

    @Autowired
    private PagamentoRepository pagamentoRepository;

    @Autowired
    private VisitanteRepository visitanteRepository;

    @Autowired
    private AnuncianteRepository anuncianteRepository;

    @Autowired
    private CreditoRepository creditoRepository;

    @Transactional
    public Pagamento processarPagamento(Long visitanteId, BigDecimal valor, String metodoPagamento, String referencia) {
        Optional<Visitante> visitanteOpt = visitanteRepository.findById(visitanteId);
        if (visitanteOpt.isEmpty()) {
            throw new RuntimeException("Visitante não encontrado");
        }

        Visitante visitante = visitanteOpt.get();

        // Tentar buscar por ID do visitante para ser mais seguro
        Optional<Anunciante> anuncianteOpt = anuncianteRepository.findByVisitanteId(visitanteId);
        Anunciante anunciante;

        if (anuncianteOpt.isEmpty()) {
            try {
                anunciante = new Anunciante();
                anunciante.setVisitante(visitante);
                anunciante.setTipoConta("PESSOAL");
                anunciante.setVerificado(false);
                anunciante = anuncianteRepository.save(anunciante);

                Credito credito = new Credito();
                credito.setAnunciante(anunciante);
                credito.setSaldo(BigDecimal.ZERO);
                creditoRepository.save(credito);
            } catch (org.springframework.dao.DataIntegrityViolationException e) {
                // Se falhar por constraint (já existe), tenta buscar novamente
                anunciante = anuncianteRepository.findByVisitanteId(visitanteId)
                        .orElseThrow(() -> new RuntimeException("Erro ao recuperar anunciante existente"));
            }
        } else {
            anunciante = anuncianteOpt.get();
        }

        int creditosAdquiridos = valor.intValue();

        String referenciaGerada = "MZ" + metodoPagamento.substring(0, 2).toUpperCase()
                + UUID.randomUUID().toString().substring(0, 8).toUpperCase();

        Pagamento pagamento = new Pagamento();
        pagamento.setAnunciante(anunciante);
        pagamento.setValor(valor);
        pagamento.setCreditosAdquiridos(creditosAdquiridos);
        pagamento.setMetodoPagamento(metodoPagamento);
        pagamento.setReferencia(referenciaGerada);
        pagamento.setStatusPagamento("CONFIRMADO");

        pagamento = pagamentoRepository.save(pagamento);

        Optional<Credito> creditoOpt = creditoRepository.findByAnunciante(anunciante);
        if (creditoOpt.isPresent()) {
            Credito credito = creditoOpt.get();
            credito.setSaldo(credito.getSaldo().add(BigDecimal.valueOf(creditosAdquiridos)));
            creditoRepository.save(credito);
        }

        return pagamento;
    }

    public List<Pagamento> listarPagamentos() {
        return pagamentoRepository.findAll();
    }

    public List<Pagamento> listarPagamentosPorAnunciante(Long anuncianteId) {
        Optional<Anunciante> anuncianteOpt = anuncianteRepository.findById(anuncianteId);
        if (anuncianteOpt.isEmpty()) {
            throw new RuntimeException("Anunciante não encontrado");
        }
        return pagamentoRepository.findByAnunciante(anuncianteOpt.get());
    }

}
