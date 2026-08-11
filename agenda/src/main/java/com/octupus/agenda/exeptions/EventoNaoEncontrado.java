package com.octupus.agenda.exeptions;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.boot.context.config.ConfigDataResourceNotFoundException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;

import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.Map;

public class EventoNaoEncontrado extends RuntimeException{
        public EventoNaoEncontrado(String menssagem){
            super(menssagem);
        }

    @ExceptionHandler(EventoNaoEncontrado.class)
    public ResponseEntity<Map<String, Object>> handleEventoNaoEncontrado(EventoNaoEncontrado ex, HttpServletRequest request){
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("timestamp", LocalDateTime.now());
        body.put("status", HttpStatus.NOT_FOUND.value());
        body.put("error", "Not Found");
        body.put("message", ex.getMessage());
        body.put("path", request.getRequestURI());

        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(body);
    }
}

