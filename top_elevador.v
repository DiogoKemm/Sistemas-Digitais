module top_elevador (
    input CLOCK_50,           // Clock principal da placa
    input [9:0] SW,           // Chaves (usadas como requisições e controle)
    input [3:0] KEY,          // Botões
    output [6:0] HEX0,        // Display de 7 segmentos (número de pessoas)
    output [9:0] LEDR         // LEDs vermelhos
);

    // Sinais internos
    wire clk = CLOCK_50;
    wire reset = ~KEY[0];           // Reset ativo em 0
    wire person_enter = SW[9];      // SW9 = pessoa entra
    wire person_exit  = SW[8];      // SW8 = pessoa sai
    wire [4:0] req = SW[4:0];       // SW[4..0] = andares requisitados

    wire motor_up, motor_down;
    wire [2:0] andar_atual, andar_requisitado;
    wire [3:0] num_people;

    // Instancia o módulo do elevador
    elevador elevador_inst (
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

    // Conecta o número de pessoas ao display
    hex7seg display_pessoas (
        .hex(num_people),
        .seg(HEX0)
    );

    // LEDs indicativos
    assign LEDR[0] = motor_up;              // Sobe
    assign LEDR[1] = motor_down;            // Desce
    assign LEDR[4:2] = andar_atual;         // Andar atual
    assign LEDR[9:5] = andar_requisitado;   // Andar requisitado

endmodule
