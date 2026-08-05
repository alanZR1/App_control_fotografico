package com.controlfotografico.backend.service;

import java.util.List;

import com.controlfotografico.backend.entity.Etapa;
import com.controlfotografico.backend.entity.Rol;
import com.controlfotografico.backend.entity.TipoFotografia;

public interface CatalogoService {

    List<Rol> listarRoles();

    List<Etapa> listarEtapas();

    List<TipoFotografia> listarTiposFotografia();

}