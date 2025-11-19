package com.example.api.services;

import com.example.api.entities.Anunciante;
import com.example.api.entities.Imovel;
import com.example.api.entities.ImovelImagem;
import com.example.api.repositories.AnuncianteRepository;
import com.example.api.repositories.ImovelImagemRepository;
import com.example.api.repositories.ImovelRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
public class ImovelService {

    private static final String UPLOAD_DIR = "backend/uploads/properties/";
    private static final String MAIN_IMAGES_DIR = "backend/uploads/properties/main/";
    private static final String GALLERY_IMAGES_DIR = "backend/uploads/properties/gallery/";

    // Allowed image MIME types
    private static final String[] ALLOWED_IMAGE_TYPES = {
        "image/jpeg", "image/jpg", "image/png", "image/gif", "image/bmp", "image/webp"
    };

    @Autowired
    private ImovelRepository imovelRepository;

    @Autowired
    private ImovelImagemRepository imagemRepository;

    @Autowired
    private AnuncianteRepository anuncianteRepository;

    @Transactional
    public Imovel criarImovel(String titulo, String descricao, BigDecimal precoMzn,
                            BigDecimal area, String finalidade, String categoria,
                            Long idAnunciante, MultipartFile imagemPrincipal,
                            List<MultipartFile> imagensGaleria) throws IOException {

        // Validate anunciante exists
        Optional<Anunciante> anuncianteOpt = anuncianteRepository.findById(idAnunciante);
        if (anuncianteOpt.isEmpty()) {
            throw new RuntimeException("Anunciante não encontrado");
        }

        // Validate imagem principal
        if (imagemPrincipal != null) {
            validateImageFile(imagemPrincipal);
        }

        // Validate imagens da galeria
        if (imagensGaleria != null) {
            for (MultipartFile imagem : imagensGaleria) {
                validateImageFile(imagem);
            }
        }

        // Create directories if they don't exist
        Files.createDirectories(Paths.get(MAIN_IMAGES_DIR));
        Files.createDirectories(Paths.get(GALLERY_IMAGES_DIR));

        // Save main image
        String mainImageUrl = null;
        if (imagemPrincipal != null && !imagemPrincipal.isEmpty()) {
            String fileName = UUID.randomUUID().toString() + "_main_" + imagemPrincipal.getOriginalFilename();
            Path filePath = Paths.get(MAIN_IMAGES_DIR + fileName);
            Files.write(filePath, imagemPrincipal.getBytes());
            mainImageUrl = "/uploads/properties/main/" + fileName;
        }

        // Create property
        Imovel imovel = new Imovel();
        imovel.setTitulo(titulo);
        imovel.setDescricao(descricao);
        imovel.setPrecoMzn(precoMzn);
        imovel.setArea(area);
        imovel.setFinalidade(finalidade);
        imovel.setStatusImovel("DISPONIVEL"); // Always available on creation
        imovel.setImagemPrincipalUrl(mainImageUrl);
        imovel.setDataCriacao(OffsetDateTime.now());
        imovel.setIdAnunciante(idAnunciante);
        imovel.setCategoria(categoria);

        Imovel savedImovel = imovelRepository.save(imovel);

        // Save gallery images with order
        if (imagensGaleria != null && !imagensGaleria.isEmpty()) {
            for (int i = 0; i < imagensGaleria.size(); i++) {
                MultipartFile imagem = imagensGaleria.get(i);
                String fileName = UUID.randomUUID().toString() + "_gallery_" + imagem.getOriginalFilename();
                Path filePath = Paths.get(GALLERY_IMAGES_DIR + fileName);
                Files.write(filePath, imagem.getBytes());

                ImovelImagem imagemGaleria = new ImovelImagem();
                imagemGaleria.setIdImovel(savedImovel.getId());
                imagemGaleria.setImagemUrl("/uploads/properties/gallery/" + fileName);
                imagemGaleria.setOrdem(i); // Order: 0, 1, 2, 3...
                imagemGaleria.setDataCriacao(OffsetDateTime.now());

                imagemRepository.save(imagemGaleria);
            }
        }

        return savedImovel;
    }

    @Transactional
    public Imovel atualizarImovel(Long id, String titulo, String descricao, BigDecimal precoMzn,
                                BigDecimal area, String finalidade, String categoria,
                                MultipartFile imagemPrincipal, List<MultipartFile> imagensGaleria) throws IOException {

        Optional<Imovel> imovelOpt = imovelRepository.findById(id);
        if (imovelOpt.isEmpty()) {
            throw new RuntimeException("Imóvel não encontrado");
        }

        Imovel imovel = imovelOpt.get();

        // Validate images if provided
        if (imagemPrincipal != null) {
            validateImageFile(imagemPrincipal);
        }
        if (imagensGaleria != null) {
            for (MultipartFile imagem : imagensGaleria) {
                validateImageFile(imagem);
            }
        }

        // Update main image if provided
        if (imagemPrincipal != null && !imagemPrincipal.isEmpty()) {
            // Delete old main image
            if (imovel.getImagemPrincipalUrl() != null) {
                Path oldPath = Paths.get(MAIN_IMAGES_DIR + imovel.getImagemPrincipalUrl().substring("/uploads/properties/main/".length()));
                Files.deleteIfExists(oldPath);
            }

            // Save new main image
            String fileName = UUID.randomUUID().toString() + "_main_" + imagemPrincipal.getOriginalFilename();
            Path filePath = Paths.get(MAIN_IMAGES_DIR + fileName);
            Files.write(filePath, imagemPrincipal.getBytes());
            imovel.setImagemPrincipalUrl("/uploads/properties/main/" + fileName);
        }

        // Update property data
        imovel.setTitulo(titulo);
        imovel.setDescricao(descricao);
        imovel.setPrecoMzn(precoMzn);
        imovel.setArea(area);
        imovel.setFinalidade(finalidade);
        imovel.setCategoria(categoria);

        Imovel savedImovel = imovelRepository.save(imovel);

        // Add new gallery images if provided
        if (imagensGaleria != null && !imagensGaleria.isEmpty()) {
            Long currentCount = imagemRepository.countByImovel(id);
            for (int i = 0; i < imagensGaleria.size(); i++) {
                MultipartFile imagem = imagensGaleria.get(i);
                String fileName = UUID.randomUUID().toString() + "_gallery_" + imagem.getOriginalFilename();
                Path filePath = Paths.get(GALLERY_IMAGES_DIR + fileName);
                Files.write(filePath, imagem.getBytes());

                ImovelImagem imagemGaleria = new ImovelImagem();
                imagemGaleria.setIdImovel(savedImovel.getId());
                imagemGaleria.setImagemUrl("/uploads/properties/gallery/" + fileName);
                imagemGaleria.setOrdem(currentCount.intValue() + i); // Continue ordering
                imagemGaleria.setDataCriacao(OffsetDateTime.now());

                imagemRepository.save(imagemGaleria);
            }
        }

        return savedImovel;
    }

    @Transactional
    public void removerImagemGaleria(Long idImagem) {
        Optional<ImovelImagem> imagemOpt = imagemRepository.findById(idImagem);
        if (imagemOpt.isEmpty()) {
            throw new RuntimeException("Imagem não encontrada");
        }

        ImovelImagem imagem = imagemOpt.get();

        // Delete physical file
        Path filePath = Paths.get(GALLERY_IMAGES_DIR + imagem.getImagemUrl().substring("/uploads/properties/gallery/".length()));
        try {
            Files.deleteIfExists(filePath);
        } catch (IOException e) {
            // Log error but continue
        }

        imagemRepository.delete(imagem);

        // Reorder remaining images
        reorderGalleryImages(imagem.getIdImovel());
    }

    @Transactional
    public void reordenarImagens(Long idImovel, List<Long> imagemIdsOrdem) {
        for (int i = 0; i < imagemIdsOrdem.size(); i++) {
            imagemRepository.updateOrdemById(i, imagemIdsOrdem.get(i));
        }
    }

    @Transactional
    public void deletarImovel(Long id) {
        Optional<Imovel> imovelOpt = imovelRepository.findById(id);
        if (imovelOpt.isEmpty()) {
            throw new RuntimeException("Imóvel não encontrado");
        }

        Imovel imovel = imovelOpt.get();

        // Delete main image
        if (imovel.getImagemPrincipalUrl() != null) {
            Path mainPath = Paths.get(MAIN_IMAGES_DIR + imovel.getImagemPrincipalUrl().substring("/uploads/properties/main/".length()));
            try {
                Files.deleteIfExists(mainPath);
            } catch (IOException e) {
                // Log error but continue
            }
        }

        // Delete gallery images
        List<ImovelImagem> imagens = imagemRepository.findByImovelOrderByOrdemAsc(id);
        for (ImovelImagem imagem : imagens) {
            Path imagePath = Paths.get(GALLERY_IMAGES_DIR + imagem.getImagemUrl().substring("/uploads/properties/gallery/".length()));
            try {
                Files.deleteIfExists(imagePath);
            } catch (IOException e) {
                // Log error but continue
            }
        }

        // Delete from database
        imagemRepository.deleteByImovel(id);
        imovelRepository.delete(imovel);
    }

    public Optional<Imovel> buscarImovel(Long id) {
        return imovelRepository.findById(id);
    }

    public List<Imovel> listarImoveis() {
        return imovelRepository.findDisponiveis();
    }

    public List<Imovel> listarImoveisPorAnunciante(Long idAnunciante) {
        return imovelRepository.findByAnunciante(idAnunciante);
    }

    public List<ImovelImagem> listarImagensGaleria(Long idImovel) {
        return imagemRepository.findByImovelOrderByOrdemAsc(idImovel);
    }

    private void validateImageFile(MultipartFile file) {
        String contentType = file.getContentType();
        if (contentType == null) {
            throw new RuntimeException("Tipo de ficheiro não identificado");
        }

        boolean isValidImage = false;
        for (String allowedType : ALLOWED_IMAGE_TYPES) {
            if (allowedType.equals(contentType.toLowerCase())) {
                isValidImage = true;
                break;
            }
        }

        if (!isValidImage) {
            throw new RuntimeException("Apenas imagens são permitidas (JPEG, PNG, GIF, BMP, WebP)");
        }
    }

    private void reorderGalleryImages(Long idImovel) {
        List<ImovelImagem> imagens = imagemRepository.findByImovelOrderByOrdemAsc(idImovel);
        for (int i = 0; i < imagens.size(); i++) {
            imagens.get(i).setOrdem(i);
            imagemRepository.save(imagens.get(i));
        }
    }

    // Simple save method for ImovelController
    public Imovel save(Imovel imovel) {
        return imovelRepository.save(imovel);
    }
}
