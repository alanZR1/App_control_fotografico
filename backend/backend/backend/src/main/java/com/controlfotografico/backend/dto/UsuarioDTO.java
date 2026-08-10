package com.controlfotografico.backend.dto;

public class UsuarioDTO {

    private Long idUsuario;
    private String nombre;
    private String correo;
    private String telefono;
    private Boolean activo;
    private Long idRol;
    private Long idObra;

    public UsuarioDTO() {
    }

    public UsuarioDTO(
            Long idUsuario,
            String nombre,
            String correo,
            String telefono,
            Boolean activo,
            Long idRol,
            Long idObra) {

        this.idUsuario = idUsuario;
        this.nombre = nombre;
        this.correo = correo;
        this.telefono = telefono;
        this.activo = activo;
        this.idRol = idRol;
        this.idObra = idObra;
    }

    public Long getIdUsuario() {
        return idUsuario;
    }

    public String getNombre() {
        return nombre;
    }

    public String getCorreo() {
        return correo;
    }

    public String getTelefono() {
        return telefono;
    }

    public Boolean getActivo() {
        return activo;
    }

    public Long getIdRol() {
        return idRol;
    }

    public Long getIdObra() {
        return idObra;
    }
}