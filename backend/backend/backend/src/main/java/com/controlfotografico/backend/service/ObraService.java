package com.controlfotografico.backend.service;

import java.util.List;

import com.controlfotografico.backend.entity.Obra;

public interface ObraService {

    List<Obra> listar();

    Obra buscarPorId(Long id);

    Obra guardar(Obra obra);

    Obra actualizar(Long id, Obra obra);

    void eliminar(Long id);

}