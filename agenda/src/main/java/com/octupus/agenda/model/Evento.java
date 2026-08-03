package com.octupus.agenda.model;

import jakarta.persistence.*;
import lombok.Data;

import java.util.Date;

@Data
@Entity
public class Evento {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Number id;
    @Column
    private String  titulo;
    @Column
    private Date dataEvento;
    @Column
    private Date dataLembrete;
    @Column
    private String categoria;
}
