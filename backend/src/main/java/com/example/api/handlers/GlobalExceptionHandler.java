package com.example.api.handlers;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Gestor Global de Exceções para a API.
 * Captura exceções específicas e formata a resposta de erro
 * para ser mais clara e útil para o frontend.
 */
@RestControllerAdvice
public class GlobalExceptionHandler {

    /**
     * Captura exceções de validação de DTOs (MethodArgumentNotValidException).
     * Itera sobre todos os erros de campo encontrados e cria uma lista
     * estruturada com o campo e a mensagem de erro.
     *
     * @param ex A exceção de validação capturada.
     * @return Uma ResponseEntity com status 400 (Bad Request) e um corpo
     *         contendo uma lista de erros formatados.
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, Object>> handleValidationExceptions(MethodArgumentNotValidException ex) {
        // Mapeia cada erro de campo para um objeto com "field" e "message"
        List<Map<String, String>> errors = ex.getBindingResult().getFieldErrors()
                .stream()
                .map(error -> {
                    Map<String, String> errorMap = new HashMap<>();
                    errorMap.put("field", error.getField());
                    errorMap.put("message", error.getDefaultMessage());
                    return errorMap;
                })
                .collect(Collectors.toList());

        // Cria o corpo da resposta final e humanizada
        Map<String, Object> responseBody = new HashMap<>();
        responseBody.put("success", false);
        responseBody.put("errors", errors);

        return new ResponseEntity<>(responseBody, HttpStatus.BAD_REQUEST);
    }
}
