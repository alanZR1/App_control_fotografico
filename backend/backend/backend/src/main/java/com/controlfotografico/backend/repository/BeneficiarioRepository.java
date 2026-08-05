package com.controlfotografico.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.controlfotografico.backend.entity.Beneficiario;

public interface BeneficiarioRepository extends JpaRepository<Beneficiario, Long> {

}