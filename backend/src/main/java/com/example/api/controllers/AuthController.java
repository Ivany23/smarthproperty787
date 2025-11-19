package com.example.api.controllers;

import com.example.api.dtos.LoginDTO;
import com.example.api.dtos.SignUpDTO;
import com.example.api.services.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
@Tag(name = "Autenticação", description = "API para autenticação de usuários")
public class AuthController {

    @Autowired
    private AuthService authService;

    @PostMapping("/register")
    @Operation(summary = "✅ Registrar novo usuário", description = "Cria um novo usuário (visitante) e retorna seus dados completos")
    public ResponseEntity<?> registerUser(@Valid @RequestBody SignUpDTO signUpDTO) {
        Map<String, Object> response = authService.register(signUpDTO.nomeCompleto(), signUpDTO.email(), signUpDTO.telefone(), signUpDTO.senha());
        return ResponseEntity.ok(response);
    }

    @PostMapping("/login")
    @Operation(summary = "➡️ Login de usuário", description = "Autentica um usuário e retorna seus dados completos")
    public ResponseEntity<?> loginUser(@Valid @RequestBody LoginDTO loginDTO) {
        try {
            return ResponseEntity.ok(authService.login(loginDTO.email(), loginDTO.senha()));
        } catch (RuntimeException e) {
            return ResponseEntity.status(401).body(Map.of("success", false, "error", e.getMessage()));
        }
    }
}
