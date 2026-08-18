package com.controlfotografico.backend.service;

import java.util.List;

import com.controlfotografico.backend.entity.Usuario;

public interface UsuarioService {

    List<Usuario> listar();

    Usuario buscarPorId(Long id);

    Usuario guardar(Usuario usuario);

    Usuario actualizar(Long id, Usuario usuario);

    void eliminar(Long id);

}