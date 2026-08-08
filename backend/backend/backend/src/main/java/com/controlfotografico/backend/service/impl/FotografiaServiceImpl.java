package com.controlfotografico.backend.service.impl;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.controlfotografico.backend.entity.Fotografia;
import com.controlfotografico.backend.repository.FotografiaRepository;
import com.controlfotografico.backend.service.FotografiaService;

@Service
public class FotografiaServiceImpl implements FotografiaService {

    private final FotografiaRepository fotografiaRepository;

    public FotografiaServiceImpl(FotografiaRepository fotografiaRepository) {
        this.fotografiaRepository = fotografiaRepository;
    }

    @Override
    public List<Fotografia> listar() {
        return fotografiaRepository.findAll();
    }

    @Override
    public Fotografia buscarPorId(UUID id) {
        return fotografiaRepository.findById(id).orElse(null);
    }

    @Override
    public Fotografia guardar(Fotografia fotografia) {
        return fotografiaRepository.save(fotografia);
    }

    @Override
    public Fotografia actualizar(UUID id, Fotografia fotografia) {
        Fotografia existente = fotografiaRepository.findById(id).orElse(null);

        if (existente == null) {
            return null;
        }

        existente.setObra(fotografia.getObra());
        existente.setUsuario(fotografia.getUsuario());
        existente.setTipoFotografia(fotografia.getTipoFotografia());
        existente.setFechaHora(fotografia.getFechaHora());
        existente.setLatitud(fotografia.getLatitud());
        existente.setLongitud(fotografia.getLongitud());
        existente.setDireccion(fotografia.getDireccion());
        existente.setUrlImagen(fotografia.getUrlImagen());
        existente.setEstatus(fotografia.getEstatus());

        return fotografiaRepository.save(existente);
    }

    @Override
    public void eliminar(UUID id) {
        fotografiaRepository.deleteById(id);
    }
}