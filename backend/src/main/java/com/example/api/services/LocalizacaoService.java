package com.example.api.services;

import com.example.api.entities.Localizacao;
import com.example.api.repositories.LocalizacaoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class LocalizacaoService {
    @Autowired
    private LocalizacaoRepository localizacaoRepository;

    public Localizacao salvar(Localizacao localizacao) {

        Optional<Localizacao> existente = localizacaoRepository.findByIdImovel(localizacao.getIdImovel());

        if (existente.isPresent()) {

            Localizacao loc = existente.get();
            loc.setPais(localizacao.getPais());
            loc.setProvincia(localizacao.getProvincia());
            loc.setCidade(localizacao.getCidade());
            loc.setBairro(localizacao.getBairro());
            return localizacaoRepository.save(loc);
        }


        return localizacaoRepository.save(localizacao);
    }

    public Optional<Localizacao> buscarPorId(Long id) {
        return localizacaoRepository.findById(id);
    }

    public Optional<Localizacao> buscarPorImovel(Long idImovel) {
        return localizacaoRepository.findByIdImovel(idImovel);
    }

    public List<Localizacao> listarTodos() {
        return localizacaoRepository.findAll();
    }

    public void deletar(Long id) {
        localizacaoRepository.deleteById(id);
    }

    public List<Localizacao> buscarPorProvincia(String provincia) {
        return localizacaoRepository.findByProvincia(provincia);
    }

    public List<Localizacao> buscarPorCidade(String cidade) {
        return localizacaoRepository.findByCidade(cidade);
    }

    public List<Localizacao> buscarPorProvinciaAndCidade(String provincia, String cidade) {
        return localizacaoRepository.findByProvinciaAndCidade(provincia, cidade);
    }
}
