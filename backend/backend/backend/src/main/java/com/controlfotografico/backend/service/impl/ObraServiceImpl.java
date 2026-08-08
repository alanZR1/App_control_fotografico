package com.controlfotografico.backend.service.impl;

import java.util.List;

import org.springframework.stereotype.Service;

import com.controlfotografico.backend.entity.Obra;
import com.controlfotografico.backend.repository.ObraRepository;
import com.controlfotografico.backend.service.ObraService;

@Service
public class ObraServiceImpl implements ObraService {

    private final ObraRepository obraRepository;

    public ObraServiceImpl(ObraRepository obraRepository) {
        this.obraRepository = obraRepository;
    }

    @Override
    public List<Obra> listar() {
        return obraRepository.findAll();
    }

    @Override
    public Obra buscarPorId(Long id) {
        return obraRepository.findById(id).orElse(null);
    }

    @Override
    public Obra guardar(Obra obra) {
        return obraRepository.save(obra);
    }

    @Override
    public Obra actualizar(Long id, Obra obra) {
        Obra existente = obraRepository.findById(id).orElse(null);

        if (existente == null) {
            return null;
        }

        existente.setNombre(obra.getNombre());
        existente.setDescripcion(obra.getDescripcion());
        existente.setDireccion(obra.getDireccion());
        existente.setLatitud(obra.getLatitud());
        existente.setLongitud(obra.getLongitud());
        existente.setRadioPermitido(obra.getRadioPermitido());
        existente.setEstatus(obra.getEstatus());
        existente.setBeneficiario(obra.getBeneficiario());

        return obraRepository.save(existente);
    }

    @Override
    public void eliminar(Long id) {
        obraRepository.deleteById(id);
    }
}