package com.controlfotografico.backend.dto;

public class EtapaDTO {

    private Long idEtapa;
    private String nombre;
    private Integer orden;

    public EtapaDTO() {
    }

    public EtapaDTO(
            Long idEtapa,
            String nombre,
            Integer orden) {

        this.idEtapa = idEtapa;
        this.nombre = nombre;
        this.orden = orden;
    }

    public Long getIdEtapa() {
        return idEtapa;
    }

    public String getNombre() {
        return nombre;
    }

    public Integer getOrden() {
        return orden;
    }
}