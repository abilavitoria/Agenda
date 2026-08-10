package com.octupus.agenda.controller;

import com.octupus.agenda.model.dto.ClienteRequest;
import com.octupus.agenda.model.dto.ClienteResponse;
import com.octupus.agenda.model.dto.EventoResponse;
import com.octupus.agenda.service.ClienteService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.util.UriComponents;
import org.springframework.web.util.UriComponentsBuilder;

import java.net.URI;
import java.util.List;

@RestController
@RequestMapping("/clientes")
@RequiredArgsConstructor
public class ClienteController {
    private final ClienteService clienteService;

    @PostMapping
    public ResponseEntity<ClienteResponse> criarCliente(
            @RequestBody @Valid ClienteRequest clienteRequest,
            UriComponentsBuilder uriBuilder
    ){
        ClienteResponse novoCliente = clienteService.criar(clienteRequest);
        URI uri = uriBuilder.path("/clientes/{id}").buildAndExpand(novoCliente.id()).toUri();

        return ResponseEntity.created(uri).body(novoCliente);
    }

    @GetMapping
    public ResponseEntity<List<ClienteResponse>> listarTodos(){
        List<ClienteResponse> clientes = clienteService.listarTodos();
        return ResponseEntity.ok(clientes);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ClienteResponse> idCliente(@PathVariable Long id){
        ClienteResponse cliente = clienteService.buscarPorId(id);
        return ResponseEntity.ok(cliente);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ClienteResponse> atualizarCliente(
            @PathVariable Long id,
            @RequestBody @Valid ClienteRequest cliente
    ){
        ClienteResponse clienteAtualizado = clienteService.atualizar(id, cliente);
        return ResponseEntity.ok(clienteAtualizado);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletarCliente(@PathVariable Long id){
        clienteService.deletar(id);
        return ResponseEntity.noContent().build();
    }
}
