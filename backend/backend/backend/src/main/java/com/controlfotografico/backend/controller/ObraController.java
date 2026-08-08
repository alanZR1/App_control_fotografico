package com.controlfotografico.backend.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.controlfotografico.backend.entity.Obra;
import com.controlfotografico.backend.service.ObraService;

@RestController
@RequestMapping("/api/obras")
@CrossOrigin(origins = "*")
public class ObraController {

    private final ObraService obraService;

    public ObraController(ObraService obraService) {
        this.obraService = obraService;
    }

    @GetMapping
    public ResponseEntity<List<Obra>> listar() {
        return ResponseEntity.ok(obraService.listar());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Obra> buscarPorId(@PathVariable Long id) {

        Obra obra = obraService.buscarPorId(id);

        if (obra == null) {
            return ResponseEntity.notFound().build();
        }

        return ResponseEntity.ok(obra);
    }

    @PostMapping
    public ResponseEntity<Obra> guardar(@RequestBody Obra obra) {
        return ResponseEntity.ok(obraService.guardar(obra));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Obra> actualizar(
            @PathVariable Long id,
            @RequestBody Obra obra) {

        Obra actualizada = obraService.actualizar(id, obra);

        if (actualizada == null) {
            return ResponseEntity.notFound().build();
        }

        return ResponseEntity.ok(actualizada);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {

        obraService.eliminar(id);

        return ResponseEntity.noContent().build();
    }
}