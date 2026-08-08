package com.controlfotografico.backend.service.impl;

import java.util.List;

import org.springframework.stereotype.Service;

import com.controlfotografico.backend.entity.Etapa;
import com.controlfotografico.backend.entity.Rol;
import com.controlfotografico.backend.entity.TipoFotografia;
import com.controlfotografico.backend.repository.EtapaRepository;
import com.controlfotografico.backend.repository.RolRepository;
import com.controlfotografico.backend.repository.TipoFotografiaRepository;
import com.controlfotografico.backend.service.CatalogoService;

@Service
public class CatalogoServiceImpl implements CatalogoService {

    private final RolRepository rolRepository;
    private final EtapaRepository etapaRepository;
    private final TipoFotografiaRepository tipoFotografiaRepository;

    public CatalogoServiceImpl(
            RolRepository rolRepository,
            EtapaRepository etapaRepository,
            TipoFotografiaRepository tipoFotografiaRepository) {

        this.rolRepository = rolRepository;
        this.etapaRepository = etapaRepository;
        this.tipoFotografiaRepository = tipoFotografiaRepository;
    }

    @Override
    public List<Rol> listarRoles() {
        return rolRepository.findAll();
    }

    @Override
    public List<Etapa> listarEtapas() {
        return etapaRepository.findAll();
    }

    @Override
    public List<TipoFotografia> listarTiposFotografia() {
        return tipoFotografiaRepository.findAll();
    }
}
