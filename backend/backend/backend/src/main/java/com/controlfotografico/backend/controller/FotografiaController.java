package com.controlfotografico.backend.controller;

import java.util.List;
import java.util.UUID;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.controlfotografico.backend.entity.Fotografia;
import com.controlfotografico.backend.service.FotografiaService;

@RestController
@RequestMapping("/api/fotografias")
@CrossOrigin(origins = "*")
public class FotografiaController {

    private final FotografiaService fotografiaService;

    public FotografiaController(FotografiaService fotografiaService) {
        this.fotografiaService = fotografiaService;
    }

    @GetMapping
    public ResponseEntity<List<Fotografia>> listar() {
        return ResponseEntity.ok(fotografiaService.listar());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Fotografia> buscarPorId(@PathVariable UUID id) {

        Fotografia fotografia = fotografiaService.buscarPorId(id);

        if (fotografia == null) {
            return ResponseEntity.notFound().build();
        }

        return ResponseEntity.ok(fotografia);
    }

    @PostMapping
    public ResponseEntity<Fotografia> guardar(
            @RequestBody Fotografia fotografia) {

        return ResponseEntity.ok(fotografiaService.guardar(fotografia));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Fotografia> actualizar(
            @PathVariable UUID id,
            @RequestBody Fotografia fotografia) {

        Fotografia actualizada =
                fotografiaService.actualizar(id, fotografia);

        if (actualizada == null) {
            return ResponseEntity.notFound().build();
        }

        return ResponseEntity.ok(actualizada);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable UUID id) {

        fotografiaService.eliminar(id);

        return ResponseEntity.noContent().build();
    }
}