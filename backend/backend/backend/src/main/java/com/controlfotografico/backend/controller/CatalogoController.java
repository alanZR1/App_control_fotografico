package com.controlfotografico.backend.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

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
    public ResponseEntity<List<Rol>> listarRoles() {
        return ResponseEntity.ok(catalogoService.listarRoles());
    }

    @GetMapping("/etapas")
    public ResponseEntity<List<Etapa>> listarEtapas() {
        return ResponseEntity.ok(catalogoService.listarEtapas());
    }

    @GetMapping("/tipos-fotografia")
    public ResponseEntity<List<TipoFotografia>> listarTiposFotografia() {
        return ResponseEntity.ok(
                catalogoService.listarTiposFotografia()
        );
    }
}