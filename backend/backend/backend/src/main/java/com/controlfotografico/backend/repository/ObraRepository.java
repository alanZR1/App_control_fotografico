package com.controlfotografico.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.controlfotografico.backend.entity.Obra;

public interface ObraRepository extends JpaRepository<Obra, Long> {

}