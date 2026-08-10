package com.controlfotografico.backend.dto;

import com.controlfotografico.backend.entity.Usuario;

public class UsuarioDTO {

    private Long idUsuario;
    private String nombre;
    private String correo;
    private String telefono;
    private Boolean activo;

    private Long idRol;
    private String nombreRol;

    private Long idObra;
    private String nombreObra;


    public UsuarioDTO(Usuario usuario) {

        this.idUsuario = usuario.getIdUsuario();
        this.nombre = usuario.getNombre();
        this.correo = usuario.getCorreo();
        this.telefono = usuario.getTelefono();
        this.activo = usuario.getActivo();
        
        if (usuario.getRol() != null) {
            this.idRol = usuario.getRol().getIdRol();
            this.nombreRol = usuario.getRol().getNombre();
        }

        if (usuario.getObra() != null) {
            this.idObra = usuario.getObra().getIdObra();
            this.nombreObra = usuario.getObra().getNombre();
        }
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

    public String getNombreRol() {
        return nombreRol;
    }

    public Long getIdObra() {
        return idObra;
    }

    public String getNombreObra() {
        return nombreObra;
    }
}