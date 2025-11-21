package com.example.api.services;

import com.example.api.entities.Visitante;
import com.example.api.repositories.VisitanteRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.Random;

@Service
public class AuthService {

    @Autowired
    private VisitanteRepository visitanteRepository;

    private BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    private String generateVerificationCode() {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        StringBuilder code = new StringBuilder();
        Random rnd = new Random();
        while (code.length() < 8) {
            int index = (int) (rnd.nextFloat() * chars.length());
            code.append(chars.charAt(index));
        }
        return code.toString();
    }

    public Map<String, Object> register(String nomeCompleto, String email, String telefone, String senha) {
        if (visitanteRepository.findByEmail(email).isPresent()) {
            throw new RuntimeException("E-mail já cadastrado");
        }

        String verificationCode = generateVerificationCode();

        Visitante visitante = new Visitante();
        visitante.setNomeCompleto(nomeCompleto);
        visitante.setEmail(email);
        visitante.setTelefone(telefone);
        visitante.setSenhaHash(passwordEncoder.encode(senha));
        visitante.setStatusConta("ATIVO");
        visitante.setCodigoVerificacao(verificationCode);
        visitante = visitanteRepository.save(visitante);

        Map<String, Object> response = new HashMap<>();
        response.put("message", "Usuário registrado com sucesso");
        response.put("visitanteId", visitante.getId());
        response.put("codigoVerificacao", verificationCode);

        return response;
    }

    public Map<String, Object> login(String email, String senha) {
        Optional<Visitante> visitanteOptional = visitanteRepository.findByEmail(email);

        if (visitanteOptional.isEmpty()) {
            throw new RuntimeException("Utilizador não encontrado ou senha inválida");
        }

        Visitante visitante = visitanteOptional.get();

        if (!passwordEncoder.matches(senha, visitante.getSenhaHash())) {
            throw new RuntimeException("Utilizador não encontrado ou senha inválida");
        }

        Map<String, Object> response = new HashMap<>();
        response.put("message", "Login bem-sucedido");
        response.put("visitanteId", visitante.getId());

        return response;
    }

    public Map<String, Object> recuperarSenha(String email, String codigoVerificacao, String novaSenha) {
        Optional<Visitante> visitanteOptional = visitanteRepository.findByEmail(email);

        if (visitanteOptional.isEmpty()) {
            throw new RuntimeException("Email não encontrado");
        }

        Visitante visitante = visitanteOptional.get();

        if (!codigoVerificacao.equals(visitante.getCodigoVerificacao())) {
            throw new RuntimeException("Código de verificação inválido");
        }

        visitante.setSenhaHash(passwordEncoder.encode(novaSenha));
        visitanteRepository.save(visitante);

        Map<String, Object> response = new HashMap<>();
        response.put("message", "Senha atualizada com sucesso");
        response.put("success", true);

        return response;
    }

    public Map<String, Object> solicitarCodigoVerificacao(String email) {
        Optional<Visitante> visitanteOptional = visitanteRepository.findByEmail(email);

        if (visitanteOptional.isEmpty()) {
            throw new RuntimeException("Email não encontrado");
        }

        Visitante visitante = visitanteOptional.get();
        String codigoVerificacao = visitante.getCodigoVerificacao();

        Map<String, Object> response = new HashMap<>();
        response.put("message", "Código de verificação encontrado");
        response.put("codigoVerificacao", codigoVerificacao);
        response.put("success", true);

        return response;
    }
}
