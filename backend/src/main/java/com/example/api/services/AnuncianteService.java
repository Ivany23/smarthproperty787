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
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;
@Service
public class AnuncianteService {
    @Autowired
    private AnuncianteRepository anuncianteRepository;
    @Autowired
    private CreditoRepository creditoRepository;
    @Autowired
    private VisitanteRepository visitanteRepository;
    @Autowired
    private PagamentoRepository pagamentoRepository;

    @Transactional
    public Anunciante criarAnunciante(Long visitanteId) {
        Optional<Visitante> visitanteOpt = visitanteRepository.findById(visitanteId);
        if (visitanteOpt.isEmpty()) {
            throw new RuntimeException("Visitante não encontrado");
        }
        Optional<Anunciante> existente = anuncianteRepository.findByVisitanteId(visitanteId);
        if (existente.isPresent()) {
            return existente.get();
        }
        Visitante visitante = visitanteOpt.get();
        Anunciante anunciante = new Anunciante();
        anunciante.setVisitante(visitante);
        anunciante.setTipoConta("PESSOAL");
        anunciante.setVerificado(false);
        anunciante = anuncianteRepository.save(anunciante);
        Credito credito = new Credito();
        credito.setAnunciante(anunciante);
        credito.setSaldo(BigDecimal.ZERO);
        creditoRepository.save(credito);
        return anunciante;
    }
    public Optional<Anunciante> buscarPorVisitanteId(Long visitanteId) {
        return anuncianteRepository.findByVisitanteId(visitanteId);
    }
    public Optional<Credito> buscarCreditoPorAnuncianteId(Long anuncianteId) {
        return creditoRepository.findByAnuncianteId(anuncianteId);
    }
    public Anunciante buscarPorId(Long id) {
        return anuncianteRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Anunciante não encontrado"));
    }
    public void removerContaAnunciante(Long id) {
        anuncianteRepository.deleteById(id);
    }
    public Credito buscarCreditosPorAnunciante(Long anuncianteId) {
        return creditoRepository.findByAnuncianteId(anuncianteId)
                .orElseThrow(() -> new RuntimeException("Crédito não encontrado para o anunciante"));
    }
    public List<Anunciante> listarTodos() {
        return anuncianteRepository.findAll();
    }
    public List<Map<String, Object>> listarTodosCreditos() {
        return creditoRepository.findAll().stream()
                .map(credito -> Map.of(
                    "anunciante_id", (Object) credito.getAnunciante().getId(),
                    "anunciante_nome", (Object) credito.getAnunciante().getVisitante().getNomeCompleto(),
                    "saldo_creditos", (Object) credito.getSaldo(),
                    "data_atualizacao", (Object) credito.getDataAtualizacao()
                ))
                .collect(Collectors.toList());
    }

    @Transactional
    public Map<String, Object> comprarCreditos(Long idAnunciante, BigDecimal creditosComprados) {
        Credito credito = buscarCreditosPorAnunciante(idAnunciante);
        BigDecimal saldoAnterior = credito.getSaldo();
        BigDecimal novoSaldo = saldoAnterior.add(creditosComprados);
        credito.setSaldo(novoSaldo);
        credito.setDataAtualizacao(LocalDateTime.now());
        creditoRepository.save(credito);
        Map<String, Object> resultado = new HashMap<>();
        resultado.put("saldo_anterior", saldoAnterior);
        resultado.put("credito_adicionado", creditosComprados);
        resultado.put("saldo_atual", novoSaldo);
        return resultado;
    }

    @Transactional
    public Map<String, Object> comprarCreditosComRegistro(Long idAnunciante, BigDecimal creditosComprados, String metodoPagamento, BigDecimal valorPago) {
        Anunciante anunciante = buscarPorId(idAnunciante);

        Pagamento pagamento = new Pagamento();
        pagamento.setAnunciante(anunciante);
        pagamento.setValor(valorPago);
        pagamento.setCreditosAdquiridos(creditosComprados.intValue());
        pagamento.setMetodoPagamento(metodoPagamento);
        pagamento.setReferencia("PAG_" + System.currentTimeMillis());
        pagamento.setStatusPagamento("PENDENTE");
        pagamentoRepository.save(pagamento);

        Credito credito = buscarCreditosPorAnunciante(idAnunciante);
        BigDecimal saldoAnterior = credito.getSaldo();
        BigDecimal novoSaldo = saldoAnterior.add(creditosComprados);
        credito.setSaldo(novoSaldo);
        credito.setDataAtualizacao(LocalDateTime.now());
        creditoRepository.save(credito);

        Map<String, Object> resultado = new HashMap<>();
        resultado.put("saldo_anterior", saldoAnterior);
        resultado.put("credito_adicionado", creditosComprados);
        resultado.put("saldo_atual", novoSaldo);
        return resultado;
    }

}
