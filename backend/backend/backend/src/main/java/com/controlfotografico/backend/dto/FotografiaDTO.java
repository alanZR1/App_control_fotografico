package com.controlfotografico.backend.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

import com.controlfotografico.backend.entity.Fotografia;

public class FotografiaDTO {

    private UUID idFotografia;

    private Long idObra;
    private Long idUsuario;
    private Long idTipo;

    private LocalDateTime fechaHora;

    private BigDecimal latitud;
    private BigDecimal longitud;

    private String direccion;

    private String urlImagen;

    private String estatus;

    public FotografiaDTO(
            Fotografia fotografia,
            String urlImagen) {

        this.idFotografia = fotografia.getIdFotografia();

        this.idObra = fotografia.getObra().getIdObra();
        this.idUsuario = fotografia.getUsuario().getIdUsuario();
        this.idTipo = fotografia.getTipoFotografia().getIdTipo();

        this.fechaHora = fotografia.getFechaHora();

        this.latitud = fotografia.getLatitud();
        this.longitud = fotografia.getLongitud();

        this.direccion = fotografia.getDireccion();

        this.urlImagen = urlImagen;

        this.estatus = fotografia.getEstatus();
    }

    public UUID getIdFotografia() {
        return idFotografia;
    }

    public Long getIdObra() {
        return idObra;
    }

    public Long getIdUsuario() {
        return idUsuario;
    }

    public Long getIdTipo() {
        return idTipo;
    }

    public LocalDateTime getFechaHora() {
        return fechaHora;
    }

    public BigDecimal getLatitud() {
        return latitud;
    }

    public BigDecimal getLongitud() {
        return longitud;
    }

    public String getDireccion() {
        return direccion;
    }

    public String getUrlImagen() {
        return urlImagen;
    }

    public String getEstatus() {
        return estatus;
    }
}
