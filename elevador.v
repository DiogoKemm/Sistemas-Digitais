module elevador (
    input clk,
    input reset,
    input [4:0] req,            
    input person_enter,
    input person_exit,
    output reg motor_up,
    output reg motor_down,
    output [2:0] andar_atual,
    output [2:0] andar_requisitado,
    output reg [3:0] num_people
);

    // Estados
    parameter IDLE = 2'b00;
    parameter MOVING_UP = 2'b01;
    parameter MOVING_DOWN = 2'b10;

    reg [1:0] state, next_state;
    reg [2:0] current_floor_reg;
    reg [4:0] pending_req;      // Armazena todos os pedidos já feitos
    reg [2:0] target_floor;

    assign andar_atual = current_floor_reg;
    assign andar_requisitado = target_floor;

    // Acumula os pedidos
    always @(posedge clk or posedge reset) begin
        if (reset)
            pending_req <= 5'b00000;
        else
            pending_req <= pending_req | req;  // Adiciona novos pedidos
    end

    // Função para encontrar o maior andar requisitado
    function [2:0] next_highest_request;
        input [4:0] req_bits;
        begin
            if (req_bits[4]) next_highest_request = 3'd4;
            else if (req_bits[3]) next_highest_request = 3'd3;
            else if (req_bits[2]) next_highest_request = 3'd2;
            else if (req_bits[1]) next_highest_request = 3'd1;
            else if (req_bits[0]) next_highest_request = 3'd0;
            else next_highest_request = current_floor_reg; 
        end
    endfunction

    // Atualiza target_floor com o próximo mais alto
    always @(*) begin
        target_floor = next_highest_request(pending_req);
    end

    // Estado e movimento do elevador
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            current_floor_reg <= 3'd0;
        end else begin
            state <= next_state;

            case (next_state)
                MOVING_UP: current_floor_reg <= current_floor_reg + 1;
                MOVING_DOWN: current_floor_reg <= current_floor_reg - 1;
            endcase

            // Se chegou no andar alvo, remove o pedido
            if (current_floor_reg == target_floor)
                pending_req[target_floor] <= 1'b0;
        end
    end

    // Lógica combinacional da FSM
    always @(*) begin
        next_state = state;
        motor_up = 0;
        motor_down = 0;

        case (state)
            IDLE: begin
                if (pending_req != 5'b00000) begin
                    if (target_floor > current_floor_reg)
                        next_state = MOVING_UP;
                    else if (target_floor < current_floor_reg)
                        next_state = MOVING_DOWN;
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
        endcase
    end

    // Contador de pessoas
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
