package com.controlfotografico.backend.service.impl;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.controlfotografico.backend.entity.Fotografia;
import com.controlfotografico.backend.repository.FotografiaRepository;
import com.controlfotografico.backend.service.FotografiaService;

@Service
public class FotografiaServiceImpl implements FotografiaService {

    private final FotografiaRepository fotografiaRepository;

    private final Path directorioImagenes =
            Paths.get("imagenes");

    public FotografiaServiceImpl(
            FotografiaRepository fotografiaRepository) {

        this.fotografiaRepository = fotografiaRepository;

        try {
            Files.createDirectories(directorioImagenes);
        } catch (IOException e) {
            throw new RuntimeException(
                    "No se pudo crear el directorio de imagenes", e);
        }
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

        Fotografia existente =
                fotografiaRepository.findById(id).orElse(null);

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

    @Override
    public Fotografia guardarFotografia(
            MultipartFile imagen,
            Fotografia fotografia) {

        try {

            String extension = obtenerExtension(imagen.getOriginalFilename());

            String nombreArchivo =
                    UUID.randomUUID() + extension;

            Path archivo =
                    directorioImagenes.resolve(nombreArchivo);

            Files.copy(
                    imagen.getInputStream(),
                    archivo,
                    StandardCopyOption.REPLACE_EXISTING
            );

            fotografia.setUrlImagen(
                    "imagenes/" + nombreArchivo
            );

            return fotografiaRepository.save(fotografia);

        } catch (IOException e) {

            throw new RuntimeException(
                    "Error al guardar la imagen", e);
        }
    }

    private String obtenerExtension(String nombreArchivo) {

        if (nombreArchivo == null ||
                !nombreArchivo.contains(".")) {

            return ".jpg";
        }

        return nombreArchivo.substring(
                nombreArchivo.lastIndexOf(".")
        );
    }
}