
package com.example.api.services;

import com.example.api.dtos.FavoritoDTO;
import com.example.api.entities.Favorito;
import com.example.api.repositories.FavoritoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class FavoritoService {

    @Autowired
    private FavoritoRepository favoritoRepository;

    public FavoritoDTO adicionarFavorito(Long idVisitante, Long idImovel) {
        if (favoritoRepository.existsByIdVisitanteAndIdImovel(idVisitante, idImovel)) {
            throw new RuntimeException("Este imóvel já está nos favoritos");
        }

        Favorito favorito = new Favorito();
        favorito.setIdVisitante(idVisitante);
        favorito.setIdImovel(idImovel);
        favorito = favoritoRepository.save(favorito);

        FavoritoDTO dto = new FavoritoDTO();
        dto.setIdFavorito(favorito.getIdFavorito());
        dto.setIdVisitante(favorito.getIdVisitante());
        dto.setIdImovel(favorito.getIdImovel());
        dto.setDataRegistro(favorito.getDataRegistro());
        return dto;
    }

    public void removerFavorito(Long idVisitante, Long idImovel) {
        Optional<Favorito> favorito = favoritoRepository.findByIdVisitanteAndIdImovel(idVisitante, idImovel);
        if (favorito.isEmpty()) {
            throw new RuntimeException("Favorito não encontrado");
        }
        favoritoRepository.delete(favorito.get());
    }

    public boolean isFavorito(Long idVisitante, Long idImovel) {
        return favoritoRepository.existsByIdVisitanteAndIdImovel(idVisitante, idImovel);
    }

    public List<FavoritoDTO> getFavoritosByVisitante(Long idVisitante) {
        return favoritoRepository.findByIdVisitanteOrderByDataRegistroDesc(idVisitante).stream().map(favorito -> {
            FavoritoDTO favoritoDTO = new FavoritoDTO();
            favoritoDTO.setIdFavorito(favorito.getIdFavorito());
            favoritoDTO.setIdVisitante(favorito.getIdVisitante());
            favoritoDTO.setIdImovel(favorito.getIdImovel());
            favoritoDTO.setDataRegistro(favorito.getDataRegistro());
            return favoritoDTO;
        }).collect(Collectors.toList());
    }

    @Deprecated
    public FavoritoDTO createFavorito(FavoritoDTO favoritoDTO) {
        return adicionarFavorito(favoritoDTO.getIdVisitante(), favoritoDTO.getIdImovel());
    }

    @Deprecated
    public void deleteFavorito(Long id) {
        favoritoRepository.deleteById(id);
    }
}
