`timescale 1ns/1ps

module tb_elevador;

    reg clk;
    reg reset;
    reg [4:0] req;
    reg person_enter;
    reg person_exit;

    wire motor_up;
    wire motor_down;
    wire [2:0] andar_atual;
    wire [2:0] andar_requisitado;
    wire [3:0] num_people;

    // Instancia o DUT (Device Under Test)
    elevador DUT (
        .clk(clk),
        .reset(reset),
        .req(req),
        .person_enter(person_enter),
        .person_exit(person_exit),
        .motor_up(motor_up),
        .motor_down(motor_down),
        .andar_atual(andar_atual),
        .andar_requisitado(andar_requisitado),
        .num_people(num_people)
    );

    // Clock de 10ns (100 MHz)
    always #5 clk = ~clk;

    initial begin
        $display("Iniciando simulação");

        // Valores iniciais
        clk = 0;
        reset = 1;
        req = 5'b00000;
        person_enter = 0;
        person_exit = 0;

        // Mantém reset por alguns ciclos
        #20 reset = 0;

        // Requisição múltipla 11010
        #10 req = 5'b11010;    // Andares 4,3,1

        #20 req = 5'b00000;   

        // Pessoas entrando 
        #50 person_enter = 1;
        #10 person_enter = 0;

        #30 person_enter = 1;
        #10 person_enter = 0;

        // Pessoas saindo
        #80 person_exit = 1;
        #10 person_exit = 0;

        // Aguarda o elevador atender todos os andares
        #300;

        $display("Fim da simulação");
        $finish;
    end

    // Monitoramento de sinais
    initial begin
        $monitor("t=%0dns | andar_atual=%0d | alvo=%0d | UP=%b | DOWN=%b | pessoas=%0d | pending_req=%b",
            $time, andar_atual, andar_requisitado, motor_up, motor_down, num_people, DUT.pending_req);
    end

endmodule
