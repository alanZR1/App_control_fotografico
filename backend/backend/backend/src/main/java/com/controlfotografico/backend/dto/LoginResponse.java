package com.controlfotografico.backend.dto;

public class LoginResponse {

    private Long idUsuario;
    private String nombre;
    private String correo;

    private Long idObra;
    private Long idRol;
    private String rol;

    public LoginResponse() {
    }

    public LoginResponse(
            Long idUsuario,
            String nombre,
            String correo,
            Long idObra,
            Long idRol,
            String rol) {

        this.idUsuario = idUsuario;
        this.nombre = nombre;
        this.correo = correo;
        this.idObra = idObra;
        this.idRol = idRol;
        this.rol = rol;
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

    public Long getIdObra() {
        return idObra;
    }

    public Long getIdRol() {
        return idRol;
    }

    public String getRol() {
        return rol;
    }
}