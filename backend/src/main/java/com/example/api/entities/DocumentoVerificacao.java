package com.example.api.entities;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import com.example.api.entities.TipoDocumento;

import java.time.LocalDateTime;

@Entity
@Table(name = "documento_verificacao")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DocumentoVerificacao {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_documento")
    private Long id;

    @ManyToOne
    @JoinColumn(name = "id_anunciante", nullable = false)
    private Anunciante anunciante;

    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_documento", nullable = false)
    private TipoDocumento tipoDocumento;

    @Column(name = "documento_url", nullable = false)
    private String documentoUrl;

    @Column(name = "data_upload", nullable = false)
    private LocalDateTime dataUpload = LocalDateTime.now();

    @Column(name = "verificado", nullable = false)
    private Boolean verificado = false;
}
