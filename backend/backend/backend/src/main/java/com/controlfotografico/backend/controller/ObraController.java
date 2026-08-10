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
    public ResponseEntity<ObraDTO> buscarPorId(@PathVariable Long id) {

        Obra obra = obraService.buscarPorId(id);

        if (obra == null) {
            return ResponseEntity.notFound().build();
        }

        return ResponseEntity.ok(convertirADTO(obra));
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

    private ObraDTO convertirADTO(Obra obra) {
       Long idBeneficiario = null;

       if (obra.getBeneficiario() != null) {
            idBeneficiario = obra.getBeneficiario().getIdBeneficiario();
        }

        return new ObraDTO(
                obra.getIdObra(),
                obra.getNombre(),
                obra.getDescripcion(),
                obra.getDireccion(),
                obra.getLatitud(),
                obra.getLongitud(),
                obra.getRadioPermitido(),
                obra.getEstatus(),
                idBeneficiario
        );
    }
}