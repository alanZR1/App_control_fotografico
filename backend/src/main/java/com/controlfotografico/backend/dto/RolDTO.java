package com.controlfotografico.backend.dto;

public class RolDTO {

    private Long idRol;
    private String nombre;
    private String descripcion;

    public RolDTO() {
    }

    public RolDTO(
            Long idRol,
            String nombre,
            String descripcion) {

        this.idRol = idRol;
        this.nombre = nombre;
        this.descripcion = descripcion;
    }

    public Long getIdRol() {
        return idRol;
    }

    public String getNombre() {
        return nombre;
    }

    public String getDescripcion() {
        return descripcion;
    }
}