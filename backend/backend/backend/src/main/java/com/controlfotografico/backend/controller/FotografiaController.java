package com.controlfotografico.backend.controller;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import com.controlfotografico.backend.entity.Fotografia;
import com.controlfotografico.backend.entity.Obra;
import com.controlfotografico.backend.entity.TipoFotografia;
import com.controlfotografico.backend.entity.Usuario;
import com.controlfotografico.backend.service.FotografiaService;

@RestController
@RequestMapping("/api/fotografias")
@CrossOrigin(origins = "*")
public class FotografiaController {

    private final FotografiaService fotografiaService;

    public FotografiaController(
            FotografiaService fotografiaService) {

        this.fotografiaService = fotografiaService;
    }

    @GetMapping
    public ResponseEntity<List<Fotografia>> listar() {
        return ResponseEntity.ok(
                fotografiaService.listar()
        );
    }

    @GetMapping("/{id}")
    public ResponseEntity<Fotografia> buscarPorId(
            @PathVariable UUID id) {

        Fotografia fotografia =
                fotografiaService.buscarPorId(id);

        if (fotografia == null) {
            return ResponseEntity.notFound().build();
        }

        return ResponseEntity.ok(fotografia);
    }

    @PostMapping("/subir")
    public ResponseEntity<Fotografia> subirFotografia(

            @RequestParam("imagen")
            MultipartFile imagen,

            @RequestParam("idObra")
            Long idObra,

            @RequestParam("idUsuario")
            Long idUsuario,

            @RequestParam("idTipo")
            Long idTipo,

            @RequestParam("fechaHora")
            String fechaHora,

            @RequestParam("latitud")
            BigDecimal latitud,

            @RequestParam("longitud")
            BigDecimal longitud,

            @RequestParam(value = "direccion", required = false)
            String direccion
    ) {

        Fotografia fotografia = new Fotografia();

        fotografia.setObra(
                crearObra(idObra)
        );

        fotografia.setUsuario(
                crearUsuario(idUsuario)
        );

        fotografia.setTipoFotografia(
                crearTipoFotografia(idTipo)
        );

        fotografia.setFechaHora(
                LocalDateTime.parse(fechaHora)
        );

        fotografia.setLatitud(latitud);
        fotografia.setLongitud(longitud);
        fotografia.setDireccion(direccion);
        fotografia.setEstatus("SINCRONIZADA");

        Fotografia guardada =
                fotografiaService.guardarFotografia(
                        imagen,
                        fotografia
                );

        return ResponseEntity.ok(guardada);
    }

    private Obra crearObra(Long id) {

        Obra obra = new Obra();
        obra.setIdObra(id);

        return obra;
    }

    private Usuario crearUsuario(Long id) {

        Usuario usuario = new Usuario();
        usuario.setIdUsuario(id);

        return usuario;
    }

    private TipoFotografia crearTipoFotografia(Long id) {

        TipoFotografia tipo = new TipoFotografia();
        tipo.setIdTipo(id);

        return tipo;
    }
}