package com.example.api.services;

import com.example.api.entities.Anunciante;
import com.example.api.entities.DocumentoVerificacao;
import com.example.api.entities.TipoDocumento;

import com.example.api.repositories.AnuncianteRepository;
import com.example.api.repositories.DocumentoVerificacaoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
public class DocumentoVerificacaoService {

    private static final String UPLOAD_DIR = "backend/uploads/documents/";

    @Autowired
    private DocumentoVerificacaoRepository documentoRepository;

    @Autowired
    private AnuncianteRepository anuncianteRepository;

    @Transactional
    public DocumentoVerificacao uploadDocumento(Long anuncianteId, TipoDocumento tipoDocumento, MultipartFile file) throws IOException {
        Optional<Anunciante> anuncianteOpt = anuncianteRepository.findById(anuncianteId);
        if (anuncianteOpt.isEmpty()) {
            throw new RuntimeException("Anunciante não encontrado");
        }

        Anunciante anunciante = anuncianteOpt.get();


        String fileName = UUID.randomUUID().toString() + "_" + file.getOriginalFilename();
        Path filePath = Paths.get(UPLOAD_DIR + fileName);
        Files.createDirectories(filePath.getParent());
        Files.write(filePath, file.getBytes());


        DocumentoVerificacao documento = new DocumentoVerificacao();
        documento.setAnunciante(anunciante);
        documento.setTipoDocumento(tipoDocumento);
        documento.setDocumentoUrl("/uploads/documents/" + fileName);
        documento.setVerificado(true);

        return documentoRepository.save(documento);
    }

    public List<DocumentoVerificacao> listarDocumentosPorAnunciante(Long anuncianteId) {
        Optional<Anunciante> anuncianteOpt = anuncianteRepository.findById(anuncianteId);
        if (anuncianteOpt.isEmpty()) {
            throw new RuntimeException("Anunciante não encontrado");
        }
        return documentoRepository.findByAnunciante(anuncianteOpt.get());
    }

    public List<Anunciante> listarTodosAnunciantes() {
        return anuncianteRepository.findAll();
    }

    public Optional<DocumentoVerificacao> buscarDocumento(Long id) {
        return documentoRepository.findById(id);
    }

    @Transactional
    public DocumentoVerificacao atualizarDocumento(Long id, TipoDocumento tipoDocumento, MultipartFile file) throws IOException {
        Optional<DocumentoVerificacao> documentoOpt = documentoRepository.findById(id);
        if (documentoOpt.isEmpty()) {
            throw new RuntimeException("Documento não encontrado");
        }

        DocumentoVerificacao documento = documentoOpt.get();
        documento.setTipoDocumento(tipoDocumento);


        if (file != null && !file.isEmpty()) {

            Path oldFilePath = Paths.get(UPLOAD_DIR + documento.getDocumentoUrl().substring("/uploads/documents/".length()));
            Files.deleteIfExists(oldFilePath);


            String fileName = UUID.randomUUID().toString() + "_" + file.getOriginalFilename();
            Path filePath = Paths.get(UPLOAD_DIR + fileName);
            Files.write(filePath, file.getBytes());

            documento.setDocumentoUrl("/uploads/documents/" + fileName);
        }

        documento.setVerificado(true);

        return documentoRepository.save(documento);
    }

    @Transactional
    public void deletarDocumento(Long id) {
        Optional<DocumentoVerificacao> documentoOpt = documentoRepository.findById(id);
        if (documentoOpt.isEmpty()) {
            throw new RuntimeException("Documento não encontrado");
        }

        DocumentoVerificacao documento = documentoOpt.get();


        Path filePath = Paths.get(UPLOAD_DIR + documento.getDocumentoUrl().substring("/uploads/documents/".length()));
        try {
            Files.deleteIfExists(filePath);
        } catch (IOException e) {

        }

        documentoRepository.delete(documento);
    }

    public List<DocumentoVerificacao> listarTodosDocumentos() {
        return documentoRepository.findAll();
    }
}
