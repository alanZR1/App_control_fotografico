package com.controlfotografico.backend.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.controlfotografico.backend.dto.ObraDTO;
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
    public ResponseEntity<List<ObraDTO>> listar() {
        List<ObraDTO> obras =
                obraService.listar()
                        .stream()
                        .map(obra -> convertirADTO(obra))
                        .toList();

        return ResponseEntity.ok(obras);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ObraDTO> buscarPorId(@PathVariable("id") Long id) {

        Obra obra = obraService.buscarPorId(id);

        if (obra == null) {
            return ResponseEntity.notFound().build();
        }

        return ResponseEntity.ok(convertirADTO(obra));
    }

    @PostMapping
    public ResponseEntity<ObraDTO> guardar(@RequestBody Obra obra) {
        Obra obraGuardada = obraService.guardar(obra);

        return ResponseEntity.ok(convertirADTO(obraGuardada));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ObraDTO> actualizar(
            @PathVariable("id") Long id,
            @RequestBody Obra obra) {

        Obra actualizada = obraService.actualizar(id, obra);

        if (actualizada == null) {
            return ResponseEntity.notFound().build();
        }

        return ResponseEntity.ok(convertirADTO(actualizada));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {

        obraService.eliminar(id);

        return ResponseEntity.noContent().build();
    }

    private ObraDTO convertirADTO(Obra obra) {

        return new ObraDTO(obra);
    }
}