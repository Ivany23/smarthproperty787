
package com.example.api.services;

import com.example.api.dtos.FavoritoDTO;
import com.example.api.entities.Favorito;
import com.example.api.repositories.FavoritoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class FavoritoService {

    @Autowired
    private FavoritoRepository favoritoRepository;

    public FavoritoDTO createFavorito(FavoritoDTO favoritoDTO) {
        Favorito favorito = new Favorito();
        favorito.setIdVisitante(favoritoDTO.getIdVisitante());
        favorito.setIdImovel(favoritoDTO.getIdImovel());
        favorito = favoritoRepository.save(favorito);
        favoritoDTO.setIdFavorito(favorito.getIdFavorito());
        favoritoDTO.setDataRegistro(favorito.getDataRegistro());
        return favoritoDTO;
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

    public void deleteFavorito(Long id) {
        favoritoRepository.deleteById(id);
    }
}
