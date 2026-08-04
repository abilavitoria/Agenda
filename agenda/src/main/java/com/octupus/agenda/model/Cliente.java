package com.octupus.agenda.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Entity
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "tb_cliente")
public class Cliente {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(length = 255, nullable = false)
    private String nome;
    @Column(length = 20, nullable = false)
    private String documento;
    @Column(length = 11)
    private String telefone;
    @Column(length = 255, nullable = false)
    private String email;
}
