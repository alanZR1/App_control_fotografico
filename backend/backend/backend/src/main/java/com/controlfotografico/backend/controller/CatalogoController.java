package com.controlfotografico.backend.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.controlfotografico.backend.dto.EtapaDTO;
import com.controlfotografico.backend.dto.RolDTO;
import com.controlfotografico.backend.dto.TipoFotografiaDTO;
import com.controlfotografico.backend.entity.Etapa;
import com.controlfotografico.backend.entity.Rol;
import com.controlfotografico.backend.entity.TipoFotografia;
import com.controlfotografico.backend.service.CatalogoService;

@RestController
@RequestMapping("/api/catalogos")
@CrossOrigin(origins = "*")
public class CatalogoController {

    private final CatalogoService catalogoService;

    public CatalogoController(CatalogoService catalogoService) {
        this.catalogoService = catalogoService;
    }

    @GetMapping("/roles")
    public ResponseEntity<List<RolDTO>> listarRoles() {

        List<RolDTO> roles =
                catalogoService.listarRoles()
                        .stream()
                        .map(rol -> convertirRolDTO(rol))
                        .toList();

        return ResponseEntity.ok(roles);
    }

    @GetMapping("/etapas")
    public ResponseEntity<List<EtapaDTO>> listarEtapas() {

        List<EtapaDTO> etapas =
                catalogoService.listarEtapas()
                        .stream()
                        .map(etapa -> convertirEtapaDTO(etapa))
                        .toList();

        return ResponseEntity.ok(etapas);
    }

    @GetMapping("/tipos-fotografia")
    public ResponseEntity<List<TipoFotografiaDTO>>
            listarTiposFotografia() {

        List<TipoFotografiaDTO> tipos =
                catalogoService.listarTiposFotografia()
                        .stream()
                        .map(tipo -> convertirTipoDTO(tipo))
                        .toList();

        return ResponseEntity.ok(tipos);
    }

    private RolDTO convertirRolDTO(Rol rol) {

        return new RolDTO(
                rol.getIdRol(),
                rol.getNombre(),
                rol.getDescripcion()
        );
    }

    private EtapaDTO convertirEtapaDTO(Etapa etapa) {

        return new EtapaDTO(etapa);
    }

    private TipoFotografiaDTO convertirTipoDTO(
            TipoFotografia tipo) {

        Long idEtapa = null;

        if (tipo.getEtapa() != null) {
            idEtapa = tipo.getEtapa().getIdEtapa();
        }

        return new TipoFotografiaDTO(
                tipo.getIdTipo(),
                tipo.getNombre(),
                idEtapa
        );
    }
}