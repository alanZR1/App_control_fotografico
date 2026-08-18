package com.controlfotografico.backend.service.impl;

import org.springframework.stereotype.Service;

import com.controlfotografico.backend.dto.LoginRequest;
import com.controlfotografico.backend.dto.LoginResponse;
import com.controlfotografico.backend.entity.Usuario;
import com.controlfotografico.backend.repository.UsuarioRepository;
import com.controlfotografico.backend.service.AuthService;

@Service
public class AuthServiceImpl implements AuthService {

    private final UsuarioRepository usuarioRepository;

    public AuthServiceImpl(UsuarioRepository usuarioRepository) {
        this.usuarioRepository = usuarioRepository;
    }

    @Override
    public LoginResponse login(LoginRequest request) {
        
        Usuario usuario = usuarioRepository
            .findByCorreo(request.getCorreo())
            .orElse(null);
            
        if (usuario == null){
            throw new RuntimeException("correo o contraseña incorrectos");
        }

        if (!usuario.getActivo()){
            throw new RuntimeException("usuario inactivo");
        }

        if (!usuario.getPassword().equals(request.getPassword())){
            throw new RuntimeException("correo o contraseña incorrectos");
        }

        return new LoginResponse(
            usuario.getIdUsuario(),
            usuario.getNombre(),
            usuario.getCorreo(),
            usuario.getObra().getIdObra(),
            usuario.getRol().getIdRol(),
            usuario.getRol().getNombre()
        );
             
    }
}