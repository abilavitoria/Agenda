package com.octupus.agenda.service;

import com.octupus.agenda.model.Evento;
import com.octupus.agenda.model.dto.EventoRequest;
import com.octupus.agenda.model.dto.EventoResponse;
import com.octupus.agenda.repository.EventoRepo;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class EventoService {
    private final EventoRepo eventoRepo;

    @Transactional
    public EventoResponse criar(EventoRequest eventoRequest){
        Evento evento =new Evento();
        evento.setTitulo(eventoRequest.titulo());
        evento.setDataEvento(eventoRequest.dataEvento());
        evento.setDataLembrete(eventoRequest.dataLembrete());
        evento.setCategoria(eventoRequest.categoria());

        Evento salvo = eventoRepo.save(evento);
        return new EventoResponse((salvo));
    }

    @Transactional(ready)
    public List<EventoResponse> listarTodos(){
        return eventoRepo.findAll()
                .stream()
                .map(EventoResponse::new)
                .toList();
    }
}
