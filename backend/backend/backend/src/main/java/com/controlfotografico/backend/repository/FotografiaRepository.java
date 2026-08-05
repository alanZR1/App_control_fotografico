package com.controlfotografico.backend.repository;

import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.controlfotografico.backend.entity.Fotografia;

public interface FotografiaRepository extends JpaRepository<Fotografia, UUID> {

}