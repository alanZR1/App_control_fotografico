package com.controlfotografico.backend.dto;

public class TipoFotografiaDTO {

    private Long idTipo;
    private String nombre;
    private Long idEtapa;

    public TipoFotografiaDTO() {
    }

    public TipoFotografiaDTO(
            Long idTipo,
            String nombre,
            Long idEtapa) {

        this.idTipo = idTipo;
        this.nombre = nombre;
        this.idEtapa = idEtapa;
    }

    public Long getIdTipo() {
        return idTipo;
    }

    public String getNombre() {
        return nombre;
    }

    public Long getIdEtapa() {
        return idEtapa;
    }
}