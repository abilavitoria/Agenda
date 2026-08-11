package com.octupus.agenda.controller;

import com.octupus.agenda.model.dto.EventoRequest;
import com.octupus.agenda.model.dto.EventoResponse;
import com.octupus.agenda.service.EventoService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.util.UriComponentsBuilder;

import java.net.URI;
import java.util.List;

@RestController
@RequestMapping("/eventos")
@RequiredArgsConstructor
public class EventoController {
    private final EventoService eventoService;

    @PostMapping
    public ResponseEntity<EventoResponse> criarEvento(
            @RequestBody @Valid EventoRequest eventoRequest,
            UriComponentsBuilder uriBuilder)
    {
        EventoResponse novoEvento = eventoService.criar(eventoRequest);
        URI uri = uriBuilder.path("/eventos/{id}").buildAndExpand(novoEvento.id()).toUri();

        return ResponseEntity.created(uri).body(novoEvento);
    }

    @GetMapping
    public ResponseEntity<List<EventoResponse>> listarTodos(){
        List<EventoResponse> eventos = eventoService.listarTodos();
        return ResponseEntity.ok(eventos);
    }

    @GetMapping("/{id}")
    public ResponseEntity<EventoResponse> idEvento(@PathVariable Long id){
        EventoResponse evento = eventoService.buscarPorId(id);
        return ResponseEntity.ok(evento);
    }

    @PutMapping("/{id}")
    public ResponseEntity<EventoResponse> ataualizaEvento(
            @PathVariable Long id,
            @RequestBody @Valid EventoRequest evento
    ){
        EventoResponse eventoAtualizado = eventoService.atualizar(id, evento);
        return ResponseEntity.ok(eventoAtualizado);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletarEvento(@PathVariable Long id){
        eventoService.deletar(id);
        return ResponseEntity.noContent().build();
    }
}
