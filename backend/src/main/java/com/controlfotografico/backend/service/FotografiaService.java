package com.controlfotografico.backend.service;

import java.util.List;
import java.util.UUID;

import org.springframework.web.multipart.MultipartFile;

import com.controlfotografico.backend.entity.Fotografia;

public interface FotografiaService {

    List<Fotografia> listar();

    Fotografia buscarPorId(UUID id);

    Fotografia guardar(Fotografia fotografia);

    Fotografia actualizar(UUID id, Fotografia fotografia);

    void eliminar(UUID id);

    Fotografia guardarFotografia(
            MultipartFile imagen,
            Fotografia fotografia
    );
}