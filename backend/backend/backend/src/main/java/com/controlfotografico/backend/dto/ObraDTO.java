package com.controlfotografico.backend.dto;

import com.controlfotografico.backend.entity.Obra;

public class ObraDTO {

    private Long idObra;
    private String nombre;
    private String descripcion;
    private String direccion;
    private Double latitud;
    private Double longitud;
    private Integer radioPermitido;
    private String estatus;
    private Long idBeneficiario;
    private String nombreBeneficiario;

    public ObraDTO() {
    }


    public ObraDTO(Obra obra) {

        this.idObra = obra.getIdObra();
        this.nombre = obra.getNombre();
        this.descripcion = obra.getDescripcion();
        this.direccion = obra.getDireccion();
        this.latitud = obra.getLatitud();
        this.longitud = obra.getLongitud();
        this.radioPermitido = obra.getRadioPermitido();
        this.estatus = obra.getEstatus();

        if (obra.getBeneficiario() != null) {
            
            this.idBeneficiario = obra.getBeneficiario().getIdBeneficiario();
        
            this.nombreBeneficiario = obra.getBeneficiario().getNombre();
        }
        
    }

    public Long getIdObra() {
        return idObra;
    }

    public String getNombre() {
        return nombre;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public String getDireccion() {
        return direccion;
    }

    public Double getLatitud() {
        return latitud;
    }

    public Double getLongitud() {
        return longitud;
    }

    public Integer getRadioPermitido() {
        return radioPermitido;
    }

    public String getEstatus() {
        return estatus;
    }

    public Long getIdBeneficiario() {
        return idBeneficiario;
    }

    public String getNombreBeneficiario() {
        return nombreBeneficiario;
    }
}