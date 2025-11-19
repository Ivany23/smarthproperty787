package com.example.api.dtos;
import com.example.api.entities.Localizacao;
public class LocalizacaoDTO {
    // ID não incluído - segue padrão das outras entidades
    private String pais;
    private String provincia;
    private String cidade;
    private String bairro;
    private Long idImovel;

    public LocalizacaoDTO() {}

    public LocalizacaoDTO(Localizacao localizacao) {
        this.pais = localizacao.getPais();
        this.provincia = localizacao.getProvincia();
        this.cidade = localizacao.getCidade();
        this.bairro = localizacao.getBairro();
        this.idImovel = localizacao.getIdImovel();
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
