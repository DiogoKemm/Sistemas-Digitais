module top_elevador (
    input CLOCK_50,              // clock principal
    input [3:0] KEY,             // botões (ativos em 0)
    input [9:0] SW,              // chaves
    output [9:0] LEDR,           // LEDs vermelhos
    output [7:0] LEDG,           // LEDs verdes
    output [6:0] HEX0            // display de 7 segmentos
);

    wire reset = ~KEY[0];       
    wire clk_slow;
    wire [4:0] req;                 // requisição de andares
    wire person_enter, person_exit;
    wire motor_up, motor_down;
    wire [2:0] andar_atual, andar_requisitado;
    wire [3:0] num_people;

    // Entradas
    assign person_enter = SW[8];    // pessoa entrou
    assign person_exit  = SW[9];    // pessoa saiu
    assign req = SW[4:0];           // requisições de andares

    // Diminuindo frequência do clock
    clock_divider #( .DIVISOR(25_000_000) ) div1Hz (
        .clk_in(CLOCK_50),
        .reset(reset),
        .clk_out(clk_slow)
    );

    // Instância do elevador
    elevador dut (
        .clk(clk_slow),
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

    // LEDS
    assign LEDR[4:0] = (1 << andar_requisitado); 
    assign LEDG[4:0] = (1 << andar_atual);       
    assign LEDR[9:5] = 5'b0;                     // LEDs não usados
    assign LEDG[7:5] = 3'b0;

    // Display sete segmentos
    hex7seg display_num_pessoas (
        .num(num_people),
        .seg(HEX0)
    );

endmodule
