package com.example.api.services;

import com.example.api.dtos.MarcacaoDTO;
import com.example.api.entities.Marcacao;
import com.example.api.repositories.MarcacaoRepository;
import com.example.api.repositories.ImovelRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class MarcacaoService {

    @Autowired
    private MarcacaoRepository marcacaoRepository;

    @Autowired
    private ImovelRepository imovelRepository;

    // Criar nova marcação (sempre começa como PENDENTE)
    public MarcacaoDTO criarMarcacao(MarcacaoDTO dto) {
        // Validar se o imóvel existe
        if (!imovelRepository.existsById(dto.getIdImovel())) {
            throw new RuntimeException("Imóvel não encontrado");
        }

        // Validar se data fim é maior que data início
        if (dto.getDataHoraFim().isBefore(dto.getDataHoraInicio()) ||
                dto.getDataHoraFim().isEqual(dto.getDataHoraInicio())) {
            throw new RuntimeException("Data/hora de fim deve ser posterior à data/hora de início");
        }

        // Verificar conflito de horário para o visitante
        List<Marcacao> conflitosVisitante = marcacaoRepository.findConflitosVisitante(
                dto.getIdVisitante(),
                dto.getDataHoraInicio(),
                dto.getDataHoraFim());

        if (!conflitosVisitante.isEmpty()) {
            throw new RuntimeException("Você já tem uma marcação neste horário");
        }

        // Verificar conflito de horário para o imóvel
        List<Marcacao> conflitosImovel = marcacaoRepository.findConflitosImovel(
                dto.getIdImovel(),
                dto.getDataHoraInicio(),
                dto.getDataHoraFim());

        if (!conflitosImovel.isEmpty()) {
            throw new RuntimeException("Este imóvel já tem uma marcação neste horário");
        }

        // Criar marcação
        Marcacao marcacao = new Marcacao();
        marcacao.setIdVisitante(dto.getIdVisitante());
        marcacao.setIdImovel(dto.getIdImovel());
        marcacao.setDataHoraInicio(dto.getDataHoraInicio());
        marcacao.setDataHoraFim(dto.getDataHoraFim());
        marcacao.setStatus("PENDENTE");
        marcacao.setObservacoes(dto.getObservacoes());

        marcacao = marcacaoRepository.save(marcacao);
        return toDTO(marcacao);
    }

    // Confirmar marcação (apenas o dono do imóvel)
    public MarcacaoDTO confirmarMarcacao(Long idMarcacao, Long idAnunciante) {
        Marcacao marcacao = marcacaoRepository.findById(idMarcacao)
                .orElseThrow(() -> new RuntimeException("Marcação não encontrada"));

        // Verificar se o anunciante é dono do imóvel
        var imovel = imovelRepository.findById(marcacao.getIdImovel())
                .orElseThrow(() -> new RuntimeException("Imóvel não encontrado"));

        if (!imovel.getIdAnunciante().equals(idAnunciante)) {
            throw new RuntimeException("Apenas o dono do imóvel pode confirmar a marcação");
        }

        if (!"PENDENTE".equals(marcacao.getStatus())) {
            throw new RuntimeException("Apenas marcações pendentes podem ser confirmadas");
        }

        marcacao.setStatus("CONFIRMADA");
        marcacao = marcacaoRepository.save(marcacao);
        return toDTO(marcacao);
    }

    // Cancelar marcação (visitante ou dono do imóvel)
    public MarcacaoDTO cancelarMarcacao(Long idMarcacao, Long idUsuario, boolean isAnunciante) {
        Marcacao marcacao = marcacaoRepository.findById(idMarcacao)
                .orElseThrow(() -> new RuntimeException("Marcação não encontrada"));

        // Verificar permissão
        boolean temPermissao = false;

        if (isAnunciante) {
            // Se for anunciante, verificar se é dono do imóvel
            var imovel = imovelRepository.findById(marcacao.getIdImovel())
                    .orElseThrow(() -> new RuntimeException("Imóvel não encontrado"));
            temPermissao = imovel.getIdAnunciante().equals(idUsuario);
        } else {
            // Se for visitante, verificar se é quem criou a marcação
            temPermissao = marcacao.getIdVisitante().equals(idUsuario);
        }

        if (!temPermissao) {
            throw new RuntimeException("Você não tem permissão para cancelar esta marcação");
        }

        if ("CANCELADA".equals(marcacao.getStatus())) {
            throw new RuntimeException("Esta marcação já foi cancelada");
        }

        marcacao.setStatus("CANCELADA");
        marcacao = marcacaoRepository.save(marcacao);
        return toDTO(marcacao);
    }

    // Listar marcações de um visitante
    public List<MarcacaoDTO> listarMarcacoesVisitante(Long idVisitante) {
        return marcacaoRepository.findByIdVisitanteOrderByDataHoraInicioDesc(idVisitante)
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    // Listar marcações de um imóvel (para o dono ver)
    public List<MarcacaoDTO> listarMarcacoesImovel(Long idImovel) {
        return marcacaoRepository.findByIdImovelOrderByDataHoraInicioDesc(idImovel)
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    // Buscar marcação por ID
    public MarcacaoDTO buscarPorId(Long id) {
        Marcacao marcacao = marcacaoRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Marcação não encontrada"));
        return toDTO(marcacao);
    }

    // Converter entidade para DTO
    private MarcacaoDTO toDTO(Marcacao marcacao) {
        MarcacaoDTO dto = new MarcacaoDTO();
        dto.setId(marcacao.getId());
        dto.setIdVisitante(marcacao.getIdVisitante());
        dto.setIdImovel(marcacao.getIdImovel());
        dto.setDataHoraInicio(marcacao.getDataHoraInicio());
        dto.setDataHoraFim(marcacao.getDataHoraFim());
        dto.setStatus(marcacao.getStatus());
        dto.setObservacoes(marcacao.getObservacoes());
        dto.setDataCriacao(marcacao.getDataCriacao());
        return dto;
    }
}
