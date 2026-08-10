package com.controlfotografico.backend.dto;

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

    public ObraDTO() {
    }

    public ObraDTO(
            Long idObra,
            String nombre,
            String descripcion,
            String direccion,
            Double latitud,
            Double longitud,
            Integer radioPermitido,
            String estatus,
            Long idBeneficiario) {

        this.idObra = idObra;
        this.nombre = nombre;
        this.descripcion = descripcion;
        this.direccion = direccion;
        this.latitud = latitud;
        this.longitud = longitud;
        this.radioPermitido = radioPermitido;
        this.estatus = estatus;
        this.idBeneficiario = idBeneficiario;
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
}