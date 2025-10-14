module elevator (
    input clk,
    input reset,
    input [4:0] req,             // Andar requisitado
    input [2:0] current_floor,   // Andar atual
    input person_enter,          // Pessoa entrou
    input person_exit,           // Pessoa saiu
    output reg motor_up,
    output reg motor_down,
    output reg door_open,
    output reg busy,
    output reg [3:0] num_people  // Contador de pessoas
);

    // Definição de estados
    parameter IDLE        = 2'b00;
    parameter MOVING_UP   = 2'b01;
    parameter MOVING_DOWN = 2'b10;
    parameter DOOR_OPEN   = 2'b11;

    reg [1:0] state, next_state;
    reg [2:0] target_floor;

    // Escolha do andar requisitado
    always @(*) begin
        target_floor = current_floor;
        if (req[0]) target_floor = 3'd0;
        else if (req[1]) target_floor = 3'd1;
        else if (req[2]) target_floor = 3'd2;
        else if (req[3]) target_floor = 3'd3;
        else if (req[4]) target_floor = 3'd4;
    end

    // Lógica de transição 
    always @(*) begin
        next_state = state;
        motor_up   = 0;
        motor_down = 0;
        door_open  = 0;
        busy       = 1;

        case (state)
            IDLE: begin
                busy = 0;
                if (req != 5'b00000) begin
                    if (target_floor > current_floor)
                        next_state = MOVING_UP;
                    else if (target_floor < current_floor)
                        next_state = MOVING_DOWN;
                    else
                        next_state = DOOR_OPEN;
                end
            end

            MOVING_UP: begin
                motor_up = 1;
                if (current_floor == target_floor)
                    next_state = DOOR_OPEN;
            end

            MOVING_DOWN: begin
                motor_down = 1;
                if (current_floor == target_floor)
                    next_state = DOOR_OPEN;
            end

            DOOR_OPEN: begin
                door_open = 1;
                next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

    // Atualização do estado
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    // People counter
    always @(posedge clk or posedge reset) begin
        if (reset)
            num_people <= 4'd0;
        else begin
            if (door_open) begin
                if (person_enter && num_people < 4'd15)
                    num_people <= num_people + 1;
                else if (person_exit && num_people > 4'd0)
                    num_people <= num_people - 1;
            end
        end
    end

endmodule
