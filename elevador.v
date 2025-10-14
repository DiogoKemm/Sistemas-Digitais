module elevador (
    input clk,
    input reset,
    input [4:0] req,             // Andar requisitado
    input person_enter,          // Pessoa entrou
    input person_exit,           // Pessoa saiu
    output reg motor_up,
    output reg motor_down,
    output reg door_open,
    output reg busy,
    output [2:0] andar_atual,
    output [2:0] andar_requisitado,
    output reg [3:0] num_people  // Contador de pessoas
);

    // Definição de estados da FSM
    parameter IDLE        = 2'b00;
    parameter MOVING_UP   = 2'b01;
    parameter MOVING_DOWN = 2'b10;
    parameter DOOR_OPEN   = 2'b11;

    // Registradores de estado
    reg [1:0] state, next_state;
    reg [2:0] target_floor;
    reg [2:0] current_floor_reg;

    // Conecta os registradores internos à saída do módulo
    assign andar_atual = current_floor_reg;
    assign andar_requisitado = target_floor;

    // Determina o andar alvo
    always @(*) begin
        target_floor = current_floor_reg; 
        if (req[0]) target_floor = 3'd0;
        else if (req[1]) target_floor = 3'd1;
        else if (req[2]) target_floor = 3'd2;
        else if (req[3]) target_floor = 3'd3;
        else if (req[4]) target_floor = 3'd4;
    end

    // Lógica dos estados
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            current_floor_reg <= 3'd0; // Elevador começa no térreo
        end else begin
            state <= next_state;
            if (next_state == MOVING_UP) begin
                // Sobe um andar por ciclo de clock
                current_floor_reg <= current_floor_reg + 1;
            end else if (next_state == MOVING_DOWN) begin
                // Desce um andar por ciclo de clock
                current_floor_reg <= current_floor_reg - 1;
            end
        end
    end

    // Lógica de transição de estados e saídas (bloco combinacional)
    always @(*) begin
        next_state = state;
        motor_up   = 0;
        motor_down = 0;
        door_open  = 0;
        busy       = 1;

        case (state)
            IDLE: begin
                busy = 0;
                // Se houver uma requisição
                if (req != 5'b00000) begin
                    if (target_floor > current_floor_reg)
                        next_state = MOVING_UP;
                    else if (target_floor < current_floor_reg)
                        next_state = MOVING_DOWN;
                    else // Já está no andar requisitado
                        next_state = DOOR_OPEN;
                end
            end

            MOVING_UP: begin
                motor_up = 1;
                if (current_floor_reg == target_floor)
                    next_state = DOOR_OPEN;
            end

            MOVING_DOWN: begin
                motor_down = 1;
                if (current_floor_reg == target_floor)
                    next_state = DOOR_OPEN;
            end

            DOOR_OPEN: begin
                door_open = 1;
                next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

    // Contador de pessoas (bloco sequencial)
    always @(posedge clk or posedge reset) begin
        if (reset)
            num_people <= 4'd0;
        else if (door_open) begin
            if (person_enter && num_people < 4'd15)
                num_people <= num_people + 1;
            else if (person_exit && num_people > 4'd0)
                num_people <= num_people - 1;
        end
    end

endmodule