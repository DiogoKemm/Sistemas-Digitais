module elevador_tb;

    // Entradas para o UUT (Unit Under Test)
    reg clk;
    reg reset;
    reg [4:0] req;
    reg person_enter;
    reg person_exit;

    // Saídas do UUT
    wire motor_up;
    wire motor_down;
    wire door_open;
    wire busy;
    wire [2:0] andar_atual;
    wire [2:0] andar_requisitado;
    wire [3:0] num_people;
    
    // Instanciação do módulo `elevador`
    elevador uut (
        .clk(clk),
        .reset(reset),
        .req(req),
        .person_enter(person_enter),
        .person_exit(person_exit),
        .motor_up(motor_up),
        .motor_down(motor_down),
        .door_open(door_open),
        .busy(busy),
        .andar_atual(andar_atual),
        .andar_requisitado(andar_requisitado),
        .num_people(num_people)
    );

    // Geração do clock (a cada 5 unidades de tempo, o clock inverte)
    always #5 clk = ~clk;

    // Estímulos de teste
    initial begin
        // Inicia o dump de formas de onda para visualização
        $dumpfile("elevador.vcd");
        $dumpvars(0, elevador_tb);

        // 1. Condição inicial e Reset
        clk = 0;
        reset = 1;
        req = 5'b00000;
        person_enter = 0;
        person_exit = 0;
        #15; // Espera um pouco com o reset ativo
        reset = 0;
        
        $display("Elevador no andar %d, pessoas a bordo: %d", andar_atual, num_people);
        #10;

        req = 5'b10000; 
        #10;
        $display("Requisição para o andar %d", andar_requisitado);
        
        wait (andar_atual == 3'd4 && door_open == 1);
        $display("Elevador chegou ao andar %d", andar_atual);
        #10;
        
        person_enter = 1;
        #10;
        $display("Alguem está entrando no elevador");
        person_enter = 0;

        $display("Pessoas a bordo: %d", num_people);

        req = 5'b01000; // Alguém pediu elevador no 3º andar
        #10;
        $display("Requisição para o andar ", andar_requisitado);
        
        wait (andar_atual == 3'd3 && door_open == 1);
        $display("Elevador chegou ao andar %d", andar_atual);
        #10;
        
        person_enter = 1;
        #10;
        $display("Alguém está entrando. Pessoas a bordo: %d", num_people);
        person_enter = 0;
        #10;
        req = 5'b00001; 
        #10;
        $display("Requisição para o andar ", andar_requisitado);
        
        wait (andar_atual == 3'd0 && door_open == 1);
        // loop para todos saírem
        while (num_people > 0) begin
            person_exit = 1; 
            #20;             
            person_exit = 0;
        end
        $display("Todos saíram. Pessoas a bordo: %d", num_people);


        // 6. Fim da simulação
        #50;
        $display("Acabou simulação.");
        $finish;
    end

endmodule