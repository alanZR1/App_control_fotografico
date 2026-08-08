package com.controlfotografico.backend.service.impl;

import org.springframework.stereotype.Service;

import com.controlfotografico.backend.service.AuthService;

@Service
public class AuthServiceImpl implements AuthService {

    @Override
    public String login(String correo, String password) {
        return "Pendiente de implementar autenticación";
    }
}