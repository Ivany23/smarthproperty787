package com.example.api.services;
import com.example.api.entities.Anunciante;
import com.example.api.entities.Credito;
import com.example.api.entities.Visitante;
import com.example.api.repositories.AnuncianteRepository;
import com.example.api.repositories.CreditoRepository;
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
@Service
public class VisitanteService {
    @Autowired
    private VisitanteRepository visitanteRepository;
    @Autowired
    private AnuncianteRepository anuncianteRepository;
    @Autowired
    private CreditoRepository creditoRepository;
    private static final BigDecimal TAXA_SAQUE = new BigDecimal("50");
    @Transactional
    public Map<String, Object> sacarCreditosVisitante(Long idVisitante) {
        Optional<Visitante> visitanteOpt = visitanteRepository.findById(idVisitante);
        if (visitanteOpt.isEmpty()) {
            throw new RuntimeException("Visitante não encontrado");
        }
        boolean podeSacar = verificarSeVisitantePodeSacar(idVisitante);
        if (!podeSacar) {
            throw new RuntimeException("Visitante não tem direitos a saque. Apenas visitantes que compraram créditos para anunciantes podem solicitar reembolso. Você nunca fez compras no sistema.");
        }
        BigDecimal valorSaque = calcularValorDisponivelParaSaque(idVisitante);
        BigDecimal impostoSistema = TAXA_SAQUE;
        BigDecimal valorLiquido = valorSaque.subtract(impostoSistema);
        if (valorSaque.compareTo(BigDecimal.ZERO) <= 0) {
            throw new RuntimeException("Nenhum valor disponível para saque neste momento");
        }
        Map<String, Object> resultado = new HashMap<>();
        resultado.put("valor_sacado", String.format("%.0f MZN", valorSaque.doubleValue()));
        resultado.put("imposto_sistema", String.format("%.0f MZN", impostoSistema.doubleValue()));
        resultado.put("valor_liquido_recebido", String.format("%.0f MZN", valorLiquido.doubleValue()));
        return resultado;
    }
    private boolean verificarSeVisitantePodeSacar(Long idVisitante) {
        return false;
    }
    private BigDecimal calcularValorDisponivelParaSaque(Long idVisitante) {
        return BigDecimal.ZERO;
    }
    public List<Visitante> listarTodos() {
        return visitanteRepository.findAll();
    }
    public Optional<Visitante> buscarPorId(Long id) {
        return visitanteRepository.findById(id);
    }
    public Optional<Visitante> buscarPorEmail(String email) {
        return visitanteRepository.findByEmail(email);
    }
}
