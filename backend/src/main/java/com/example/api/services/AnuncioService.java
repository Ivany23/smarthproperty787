package com.example.api.services;

import com.example.api.entities.Anuncio;
import com.example.api.entities.Credito;
import com.example.api.entities.Imovel;
import com.example.api.repositories.AnuncioRepository;
import com.example.api.repositories.CreditoRepository;
import com.example.api.repositories.ImovelRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class AnuncioService {

    private static final BigDecimal CUSTO_ANUNCIO = new BigDecimal("50");
    private static final int DURACAO_ANUNCIO_DIAS = 30; // 30 dias por padrão

    @Autowired
    private AnuncioRepository anuncioRepository;

    @Autowired
    private ImovelRepository imovelRepository;

    @Autowired
    private CreditoRepository creditoRepository;

    // ========== DEBITO AUTOMÁTICO DE CRÉDITOS ==========

    @Transactional
    public Anuncio criarAnuncio(Long idImovel) {
        // 1. Verificar se imóvel existe
        Optional<Imovel> imovelOpt = imovelRepository.findById(idImovel);
        if (imovelOpt.isEmpty()) {
            throw new RuntimeException("Imóvel não encontrado");
        }

        Imovel imovel = imovelOpt.get();

        // 2. Verificar se há anúncios pendentes para este imóvel
        List<Anuncio> anunciosPendentes = anuncioRepository.findByIdImovel(idImovel);
        boolean temPendenteOuPublicado = anunciosPendentes.stream()
                .anyMatch(a -> "PENDENTE".equals(a.getStatusAnuncio()) || "PUBLICADO".equals(a.getStatusAnuncio()));

        if (temPendenteOuPublicado) {
            throw new RuntimeException("Este imóvel já tem um anúncio pendente ou publicado");
        }

        Credito credito = verificarECalcularCreditos(imovel.getIdAnunciante(), CUSTO_ANUNCIO);

        debitoCreditos(credito, CUSTO_ANUNCIO);

        Anuncio anuncio = new Anuncio();
        anuncio.setImovel(imovel);
        anuncio.setDataPublicacao(LocalDateTime.now());
        anuncio.setStatusAnuncio("PUBLICADO");
        anuncio.setDataExpiracao(LocalDateTime.now().plusDays(DURACAO_ANUNCIO_DIAS)); // ✅ +30 dias
        anuncio.setVisualizacoes(0);
        anuncio.setCustoCredito(CUSTO_ANUNCIO);

        return anuncioRepository.save(anuncio);
    }

    // ========== GESTÃO DE CRÉDITOS ==========

    private Credito verificarECalcularCreditos(Long idAnunciante, BigDecimal custoNecessario) {
        Optional<Credito> creditoOpt = creditoRepository.findByAnuncianteId(idAnunciante);

        if (creditoOpt.isEmpty()) {
            throw new RuntimeException("Anunciante não possui registro de créditos");
        }

        Credito credito = creditoOpt.get();

        if (credito.getSaldo().compareTo(custoNecessario) < 0) {
            throw new RuntimeException(
                    String.format("Créditos insuficientes. Possui: %.0f, Necessário: %.0f",
                            credito.getSaldo().doubleValue(),
                            custoNecessario.doubleValue()));
        }

        return credito;
    }

    private void debitoCreditos(Credito credito, BigDecimal valor) {
        BigDecimal novoSaldo = credito.getSaldo().subtract(valor);
        credito.setSaldo(novoSaldo);
        credito.setDataAtualizacao(LocalDateTime.now());
        creditoRepository.save(credito);
    }

    // ========== GESTÃO DE ANÚNCIOS ==========

    @Transactional
    public Anuncio suspenderAnuncio(Long idAnuncio) {
        Optional<Anuncio> anuncioOpt = anuncioRepository.findById(idAnuncio);
        if (anuncioOpt.isEmpty()) {
            throw new RuntimeException("Anúncio não encontrado");
        }

        Anuncio anuncio = anuncioOpt.get();
        anuncio.setStatusAnuncio("SUSPENSO");

        return anuncioRepository.save(anuncio);
    }

    // ========== VISUALIZAÇÕES E EXPIRAÇÃO ==========

    @Transactional
    public void incrementarVisualizacao(Long idAnuncio) {
        Optional<Anuncio> anuncioOpt = anuncioRepository.findById(idAnuncio);
        if (anuncioOpt.isPresent() && "PUBLICADO".equals(anuncioOpt.get().getStatusAnuncio())) {
            anuncioRepository.incrementarVisualizacoes(idAnuncio);
        }
    }

    @Transactional
    public void expirarAnuncios() {
        List<Anuncio> anunciosVencidos = anuncioRepository.findAnunciosExpirados(LocalDateTime.now());

        for (Anuncio anuncio : anunciosVencidos) {
            Long idAnunciante = anuncio.getImovel() != null
                    ? imovelRepository.findById(anuncio.getImovel().getId())
                            .map(Imovel::getIdAnunciante)
                            .orElse(null)
                    : null;

            if (idAnunciante != null) {
                Credito credito = verificarECalcularCreditos(idAnunciante, CUSTO_ANUNCIO);
                // Se chegou aqui, tem créditos suficientes (>= 50)

                try {
                    // 🟢 RENOVAR AUTOMATICAMENTE: Debitar 50 créditos e renovar anúncio por +30
                    // dias
                    debitoCreditos(credito, CUSTO_ANUNCIO);
                    anuncio.setDataExpiracao(LocalDateTime.now().plusDays(DURACAO_ANUNCIO_DIAS));
                    anuncioRepository.save(anuncio);

                    // 💡 Poderia registrar renovação, mas manter anúncio PUBLICA DO

                } catch (Exception e) {
                    // 🔴 SEM CRÉDITOS: Expira o anúncio
                    anuncio.setStatusAnuncio("EXPIRADO");
                    anuncioRepository.save(anuncio);
                }
            } else {
                // 🔴 IMÓVEL SEM ANUNCIANTE: Expira
                anuncio.setStatusAnuncio("EXPIRADO");
                anuncioRepository.save(anuncio);
            }
        }
    }

    // ========== CONSULTAS BÁSICAS ==========

    public List<Anuncio> listarTodos() {
        return anuncioRepository.findAll();
    }

    public Optional<Anuncio> buscarPorId(Long id) {
        return anuncioRepository.findById(id);
    }

    public List<Anuncio> buscarPorImovel(Long idImovel) {
        return anuncioRepository.findByIdImovel(idImovel);
    }

    public List<Anuncio> buscarPorStatus(String status) {
        return anuncioRepository.findByStatusAnuncio(status);
    }

    public void excluirAnuncio(Long id) {
        Optional<Anuncio> anuncioOpt = anuncioRepository.findById(id);
        if (anuncioOpt.isEmpty()) {
            throw new RuntimeException("Anúncio não encontrado");
        }

        Anuncio anuncio = anuncioOpt.get();

        // Se for anúncio publicado, verificar se pode excluir (opção futura)
        // Por enquanto, permite excluir qualquer anúncio

        anuncioRepository.deleteById(id);
    }

    public List<Anuncio> buscarAnunciosPublicados() {
        return anuncioRepository.findByStatusAnuncioOrderByDataPublicacaoDesc("PUBLICADO");
    }
}
