package com.example.api.services;

import com.example.api.entities.DocumentoImovel;
import com.example.api.entities.Imovel;
import com.example.api.entities.TipoDocumentoImovel;
import com.example.api.repositories.DocumentoImovelRepository;
import com.example.api.repositories.ImovelRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
public class DocumentoImovelService {

    private static final String DOCUMENTS_DIR = "backend/uploads/documents/properties/";

    @Autowired
    private DocumentoImovelRepository documentoImovelRepository;

    @Autowired
    private ImovelRepository imovelRepository;

    private static final String[] ALLOWED_DOC_TYPES = {
        "application/pdf", "application/msword", "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        "image/jpeg", "image/png", "image/gif", "image/bmp", "image/webp",
        "text/plain", "text/csv"
    };

    public List<DocumentoImovel> listarTodos() {
        return documentoImovelRepository.findAll();
    }

    public Optional<DocumentoImovel> buscarPorId(Long id) {
        return documentoImovelRepository.findById(id);
    }

    public List<DocumentoImovel> buscarPorImovel(Long idImovel) {
        Imovel imovel = imovelRepository.findById(idImovel).orElseThrow(() -> new RuntimeException("Imóvel não encontrado"));
        return documentoImovelRepository.findByImovel(imovel);
    }

    public List<DocumentoImovel> buscarPorTipo(TipoDocumentoImovel tipoDocumento) {
        return documentoImovelRepository.findByTipoDocumento(tipoDocumento);
    }

    public DocumentoImovel criarDocumento(Long idImovel, TipoDocumentoImovel tipoDocumento, MultipartFile documento) throws IOException {
        Imovel imovel = imovelRepository.findById(idImovel).orElseThrow(() -> new RuntimeException("Imóvel não encontrado"));

        validateDocumentFile(documento);

        Files.createDirectories(Paths.get(DOCUMENTS_DIR));

        String originalFileName = documento.getOriginalFilename();
        String fileExtension = getFileExtension(originalFileName);
        String fileName = UUID.randomUUID().toString() + "_property_doc_" + fileExtension;
        Path filePath = Paths.get(DOCUMENTS_DIR + fileName);
        Files.write(filePath, documento.getBytes());

        DocumentoImovel novoDocumento = new DocumentoImovel();
        novoDocumento.setImovel(imovel);
        novoDocumento.setTipoDocumento(tipoDocumento);
        novoDocumento.setDocumentoUrl("/uploads/documents/properties/" + fileName);
        novoDocumento.setDataUpload(OffsetDateTime.now());

        return documentoImovelRepository.save(novoDocumento);
    }

    public DocumentoImovel atualizarDocumento(Long idDocumento, TipoDocumentoImovel tipoDocumento, MultipartFile novoDocumento) throws IOException {
        DocumentoImovel documento = documentoImovelRepository.findById(idDocumento).orElseThrow(() -> new RuntimeException("Documento não encontrado"));

        if (tipoDocumento != null) {
            documento.setTipoDocumento(tipoDocumento);
        }

        if (novoDocumento != null && !novoDocumento.isEmpty()) {
            validateDocumentFile(novoDocumento);

            if (documento.getDocumentoUrl() != null) {
                String oldFileName = documento.getDocumentoUrl().substring("/uploads/documents/properties/".length());
                Path oldPath = Paths.get(DOCUMENTS_DIR + oldFileName);
                Files.deleteIfExists(oldPath);
            }

            String originalFileName = novoDocumento.getOriginalFilename();
            String fileExtension = getFileExtension(originalFileName);
            String fileName = UUID.randomUUID().toString() + "_property_doc_updated_" + fileExtension;
            Path filePath = Paths.get(DOCUMENTS_DIR + fileName);
            Files.write(filePath, novoDocumento.getBytes());

            documento.setDocumentoUrl("/uploads/documents/properties/" + fileName);
        }

        documento.setDataUpload(OffsetDateTime.now());
        return documentoImovelRepository.save(documento);
    }

    public void deletarDocumento(Long idDocumento) throws IOException {
        DocumentoImovel documento = documentoImovelRepository.findById(idDocumento).orElseThrow(() -> new RuntimeException("Documento não encontrado"));

        if (documento.getDocumentoUrl() != null) {
            String fileName = documento.getDocumentoUrl().substring("/uploads/documents/properties/".length());
            Path filePath = Paths.get(DOCUMENTS_DIR + fileName);
            Files.deleteIfExists(filePath);
        }

        documentoImovelRepository.delete(documento);
    }

    private void validateDocumentFile(MultipartFile file) {
        String contentType = file.getContentType();
        if (contentType == null) {
            throw new RuntimeException("Tipo de ficheiro não identificado");
        }

        boolean isValid = false;
        for (String allowedType : ALLOWED_DOC_TYPES) {
            if (allowedType.equals(contentType.toLowerCase())) {
                isValid = true;
                break;
            }
        }

        if (!isValid) {
            throw new RuntimeException("Tipo de ficheiro não permitido. Use: PDF, DOC, DOCX, imagens (JPEG, PNG, etc.), TXT, CSV");
        }
    }

    private String getFileExtension(String filename) {
        if (filename != null && filename.contains(".")) {
            return filename.substring(filename.lastIndexOf("."));
        }
        return "";
    }
}
