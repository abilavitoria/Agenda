package com.octupus.agenda.service;

import com.octupus.agenda.model.Cliente;
import com.octupus.agenda.model.Evento;
import com.octupus.agenda.model.dto.ClienteRequest;
import com.octupus.agenda.model.dto.ClienteResponse;
import com.octupus.agenda.model.dto.EventoResponse;
import com.octupus.agenda.repository.ClienteRepo;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ClienteService {
    private final ClienteRepo clienteRepo;

    @Transactional
    public ClienteResponse criar(ClienteRequest clienteRequest) {
        Cliente cliente = new Cliente();
        cliente.setNome(clienteRequest.nome());
        cliente.setDocumento(clienteRequest.documento());
        cliente.setTelefone(clienteRequest.telefone());
        cliente.setEmail(clienteRequest.email());

        Cliente salvo = clienteRepo.save(cliente);
        return new ClienteResponse(salvo);
    }

    @Transactional
    public List<ClienteResponse> listarTodos(){
        return clienteRepo.findAll()
                .stream()
                .map(ClienteResponse::new)
                .toList();
    }

    @Transactional
    public ClienteResponse buscarPorId(Long id) {
        Cliente cliente = clienteRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Cliente não encontrado:" + id));
        return new ClienteResponse(cliente);
    }

    @Transactional
    public ClienteResponse atualizar(Long id, ClienteRequest clienteRequest){
        Cliente cliente = clienteRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Cliente não encontrado:" + id));
        cliente.setNome(clienteRequest.nome());
        cliente.setDocumento(clienteRequest.documento());
        cliente.setTelefone(clienteRequest.telefone());
        cliente.setEmail(clienteRequest.email());

        Cliente clienteAtualizado = clienteRepo.save(cliente);
        return new ClienteResponse(clienteAtualizado);
    }

    @Transactional
    public void deletar(Long id){
        if(!clienteRepo.existsById(id)){
            throw new RuntimeException("Cliente não encontrado:" + id);
        }clienteRepo.deleteById(id);
    }
}
