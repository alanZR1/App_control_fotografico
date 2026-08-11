package com.controlfotografico.backend.dto;

import com.controlfotografico.backend.entity.Etapa;

public class EtapaDTO {

    private Long idEtapa;
    private String nombre;
    private Integer orden;

    public EtapaDTO() {
    }
    
    public EtapaDTO(Etapa etapa) {
        this.idEtapa = etapa.getIdEtapa();
        this.nombre = etapa.getNombre();
        this.orden = etapa.getOrden();
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