package com.controlfotografico.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.controlfotografico.backend.entity.TipoFotografia;

public interface TipoFotografiaRepository extends JpaRepository<TipoFotografia, Long> {

}