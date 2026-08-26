package com.octupus.agenda.exeptions;

public class EventoNaoEncontrado extends RuntimeException {
    public EventoNaoEncontrado(String mensagem) {
        super(mensagem);
    }
}
