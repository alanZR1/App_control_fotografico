package com.controlfotografico.backend.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.controlfotografico.backend.dto.UsuarioDTO;
import com.controlfotografico.backend.entity.Usuario;
import com.controlfotografico.backend.service.UsuarioService;

@RestController
@RequestMapping("/api/usuarios")
@CrossOrigin(origins = "*")
public class UsuarioController {

    private final UsuarioService usuarioService;

    public UsuarioController(UsuarioService usuarioService) {
        this.usuarioService = usuarioService;
    }

    @GetMapping
    public ResponseEntity<List<UsuarioDTO>> listar() {
        List<UsuarioDTO> usuarios =
                usuarioService.listar()
                        .stream()
                        .map(usuario -> convertirADTO(usuario))
                        .toList();

        return ResponseEntity.ok(usuarios);
    }

    @GetMapping("/{id}")
    public ResponseEntity<UsuarioDTO> buscarPorId(@PathVariable Long id) {

        Usuario usuario = usuarioService.buscarPorId(id);

        if (usuario == null) {
            return ResponseEntity.notFound().build();
        }

        return ResponseEntity.ok(convertirADTO(usuario));
    }

    @PostMapping
    public ResponseEntity<UsuarioDTO> guardar(@RequestBody Usuario usuario) {
        
        Usuario guardado = usuarioService.guardar(usuario);

        return ResponseEntity.ok( new UsuarioDTO(guardado));
    }

    @PutMapping("/{id}")
    public ResponseEntity<UsuarioDTO> actualizar(
            @PathVariable Long id,
            @RequestBody Usuario usuario) {

        Usuario actualizado = usuarioService.actualizar(id, usuario);

        if (actualizado == null) {
            return ResponseEntity.notFound().build();
        }

        return ResponseEntity.ok(new UsuarioDTO(actualizado));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {

        usuarioService.eliminar(id);

        return ResponseEntity.noContent().build();
    }

    private UsuarioDTO convertirADTO(Usuario usuario) {
        
        return new UsuarioDTO(usuario);
    }
}