package com.octupus.agenda.repository;

import com.octupus.agenda.model.Evento;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface EventoRepo extends JpaRepository<Evento, Long> {
    List<Evento> findByCategoriaIgnoreCase(String categoria);
}
