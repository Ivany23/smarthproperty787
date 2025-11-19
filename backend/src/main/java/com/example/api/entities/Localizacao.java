package com.example.api.entities;
import jakarta.persistence.*;
import java.time.LocalDateTime;
@Entity
@Table(name = "localizacao")
public class Localizacao {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_localizacao")
    private Long idLocalizacao;

    @Column(name = "pais", columnDefinition = "character varying DEFAULT 'Moçambique'::character varying")
    private String pais = "Moçambique";

    @Column(name = "provincia", nullable = false)
    private String provincia;

    @Column(name = "cidade", nullable = false)
    private String cidade;

    @Column(name = "bairro")
    private String bairro;

    @Column(name = "id_imovel", nullable = false)
    private Long idImovel;

    public Long getIdLocalizacao() {
        return idLocalizacao;
    }

    public void setIdLocalizacao(Long idLocalizacao) {
        this.idLocalizacao = idLocalizacao;
    }

    public String getPais() {
        return pais;
    }

    public void setPais(String pais) {
        this.pais = pais;
    }

    public String getProvincia() {
        return provincia;
    }

    public void setProvincia(String provincia) {
        this.provincia = provincia;
    }

    public String getCidade() {
        return cidade;
    }

    public void setCidade(String cidade) {
        this.cidade = cidade;
    }

    public String getBairro() {
        return bairro;
    }

    public void setBairro(String bairro) {
        this.bairro = bairro;
    }

    public Long getIdImovel() {
        return idImovel;
    }

    public void setIdImovel(Long idImovel) {
        this.idImovel = idImovel;
    }
}
