package com.example.api.entities;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import java.time.OffsetDateTime;

@Entity
@Table(name = "documento_imovel")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class DocumentoImovel {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_documento")
    private Long idDocumento;

    @ManyToOne
    @JoinColumn(name = "id_imovel", nullable = false)
    private Imovel imovel;

    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_documento", nullable = false)
    private TipoDocumentoImovel tipoDocumento;

    @Column(name = "documento_url", nullable = false)
    private String documentoUrl;

    @Column(name = "data_upload", nullable = false)
    private OffsetDateTime dataUpload = OffsetDateTime.now();
}
