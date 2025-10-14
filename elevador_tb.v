module tb_elevator;

    reg clk, reset;
    reg [4:0] req;
    reg [2:0] current_floor;
    reg person_enter, person_exit;
    wire motor_up, motor_down, door_open, busy;
    wire [3:0] num_people;

    elevator uut (
        .clk(clk),
        .reset(reset),
        .req(req),
        .current_floor(current_floor),
        .person_enter(person_enter),
        .person_exit(person_exit),
        .motor_up(motor_up),
        .motor_down(motor_down),
        .door_open(door_open),
        .busy(busy),
        .num_people(num_people)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("elevator.vcd");
        $dumpvars(0, tb_elevator);

        clk = 0; reset = 1; req = 5'b00000; current_floor = 3'd0;
        person_enter = 0; person_exit = 0;
        #10 reset = 0;

        // Solicita o 4º andar
        #10 req = 5'b10000;
        repeat (4) begin
            #20 current_floor = current_floor + 1;
        end
        req = 5'b00000;

        // Pessoa entra no 4º andar
        #10 person_enter = 1; #10 person_enter = 0;

        // Solicita o térreo
        #20 req = 5'b00001;
        repeat (4) begin
            #20 current_floor = current_floor - 1;
        end
        req = 5'b00000;
        
        // Pessoa sai no térreo
        #10 person_exit = 1; #10 person_exit = 0;

        #50 $finish;
    end

endmodule
