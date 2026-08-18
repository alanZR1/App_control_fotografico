package com.controlfotografico.backend.service;

import com.controlfotografico.backend.dto.LoginRequest;
import com.controlfotografico.backend.dto.LoginResponse;

public interface AuthService {

    LoginResponse login(LoginRequest request);

}