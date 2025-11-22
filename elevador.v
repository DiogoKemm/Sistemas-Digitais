module elevador (
    input clk,
    input reset,
    input [4:0] req,
    input person_enter,
    input person_exit,
    input emergency,             // <--- 1. Nova entrada de emergência
    output reg motor_up,
    output reg motor_down,
    output [2:0] andar_atual,
    output [2:0] andar_requisitado,
    output reg [3:0] num_people 
);

    // Definição de estados
    parameter IDLE        = 2'b00;
    parameter MOVING_UP   = 2'b01;
    parameter MOVING_DOWN = 2'b10;
    parameter STOPPED     = 2'b11; // <--- 2. Novo estado de paragem/emergência

    // ... (restante das declarações de registos e assign mantém-se igual) ...
    reg [1:0] state, next_state;
    reg [2:0] target_floor;
    reg [2:0] current_floor_reg;
    
    assign andar_atual = current_floor_reg;
    assign andar_requisitado = target_floor;

    // ... (Lógica de target_floor mantém-se igual) ...
    always @(*) begin
        target_floor = current_floor_reg;
        if (req[0]) target_floor = 3'd0;
        else if (req[1]) target_floor = 3'd1;
        else if (req[2]) target_floor = 3'd2;
        else if (req[3]) target_floor = 3'd3;
        else if (req[4]) target_floor = 3'd4;
    end

    // Lógica sequencial (Atualização de andar)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            current_floor_reg <= 3'd0;
        end else begin
            state <= next_state;
            // Só move se não estiver em emergência (o estado STOPPED não entra nos ifs abaixo)
            if (next_state == MOVING_UP) begin
                current_floor_reg <= current_floor_reg + 1;
            end else if (next_state == MOVING_DOWN) begin
                current_floor_reg <= current_floor_reg - 1;
            end
            // Se next_state for STOPPED, o current_floor_reg mantém o valor (o elevador para)
        end
    end

    // Lógica combinacional (Transição de estados e saídas)
    always @(*) begin
        next_state = state;
        motor_up   = 0;
        motor_down = 0;

        // 3. Verificação prioritária de emergência
        if (emergency) begin
            next_state = STOPPED;
        end else begin
            case (state)
                IDLE: begin
                    if (req != 5'b00000) begin
                        if (target_floor > current_floor_reg)
                            next_state = MOVING_UP;
                        else if (target_floor < current_floor_reg)
                            next_state = MOVING_DOWN;
                        else
                            next_state = IDLE;
                    end
                end

                MOVING_UP: begin
                    motor_up = 1;
                    if (current_floor_reg == target_floor)
                        next_state = IDLE;
                end

                MOVING_DOWN: begin
                    motor_down = 1;
                    if (current_floor_reg == target_floor)
                        next_state = IDLE;
                end

                STOPPED: begin
                    // Motores já estão a 0 por defeito no início do bloco
                    // Se a emergência for retirada (entrando no else deste bloco), volta para IDLE
                    next_state = IDLE;
                end

                default: next_state = IDLE;
            endcase
        end
    end

    // ... (Lógica do contador de pessoas mantém-se igual) ...
    always @(posedge clk or posedge reset) begin
        if (reset)
            num_people <= 4'd0;
        else begin
            if (person_enter && num_people < 4'd15)
                num_people <= num_people + 1;
            else if (person_exit && num_people > 4'd0)
                num_people <= num_people - 1;
        end
    end

endmodule