package com.octupus.agenda.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.Date;

@Data
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "tb_evento")
public class Evento {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(nullable = false, length = 250)
    private String  titulo;
    @Column(name = "data_evento", nullable = false)
    private LocalDateTime dataEvento;
    @Column(name = "data_lembrete")
    private LocalDateTime dataLembrete;
    @Column(length = 100)
    private String categoria;
}
