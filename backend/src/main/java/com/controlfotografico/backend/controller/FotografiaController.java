package com.controlfotografico.backend.controller;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import com.controlfotografico.backend.dto.FotografiaDTO;
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
    public ResponseEntity<List<FotografiaDTO>> listar() {

        List<FotografiaDTO> fotografias = fotografiaService.listar()
        .stream()
        .map(this::convertirADTO)
        .toList();
        return ResponseEntity.ok(fotografias);
    }

    @GetMapping("/{id}")
    public ResponseEntity<FotografiaDTO> buscarPorId(
            @PathVariable("id") UUID id) {

        Fotografia fotografia =
                fotografiaService.buscarPorId(id);

        if (fotografia == null) {
            return ResponseEntity.notFound().build();
        }

        return ResponseEntity.ok(convertirADTO(fotografia));
    }

    @PostMapping("/subir")
    public ResponseEntity<FotografiaDTO> subirFotografia(

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

        return ResponseEntity.ok(convertirADTO(guardada));
    }

    private FotografiaDTO convertirADTO( Fotografia fotografia) { 

        String urlImagen = null; 
        
        if (fotografia.getUrlImagen() != null) 
        
                { urlImagen = ServletUriComponentsBuilder .fromCurrentContextPath() 
                        .path("/") 
                        .path(fotografia.getUrlImagen()) 
                        .toUriString(); 
                } 
        
                return new FotografiaDTO( fotografia, urlImagen ); 
        
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


