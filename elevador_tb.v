module elevador_tb;

    // Entradas para UUT
    reg clk;
    reg reset;
    reg [4:0] req;
    reg person_enter;
    reg person_exit;

    // Saídas do UUT
    wire motor_up;
    wire motor_down;
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
        .andar_atual(andar_atual),
        .andar_requisitado(andar_requisitado),
        .num_people(num_people)
    );

    // Geração do clock (a cada 5 unidades de tempo, o clock inverte)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("elevador.vcd");
        $dumpvars(0, elevador_tb);

        clk = 0;
        reset = 1;
        req = 5'b00000;
        person_enter = 0;
        person_exit = 0;
        #15;
        reset = 0;
        
        // 1. Inicio
        $display("Elevador no andar %d, pessoas a bordo: %d", andar_atual, num_people);

        // 2. Ir do térreo para o 4º andar
        req = 5'b10000; 
        $display("Requisição para o andar %d", andar_requisitado);
        
        wait (andar_atual == 3'd4);
        $display("Elevador chegou ao andar %d", andar_atual);

        // 3. Uma pessoa entra no 4º andar
        @(posedge clk); 
        person_enter = 1;
        $display("Alguem está entrando no elevador");
        @(posedge clk); 
        person_enter = 0;
        $display("Pessoas a bordo: %d", num_people);

        // 4. Outra pessoa pediu elevador no 3º andar
        req = 5'b01000;
        #10;
        $display("Requisição para o andar ", andar_requisitado);
        
        wait (andar_atual == 3'd3);
        $display("Elevador chegou ao andar %d", andar_atual);
        
        // 5. Pessoa entrando no 3º andar
        @(posedge clk); 
        person_enter = 1;
        $display("Alguém está entrando");
        @(posedge clk); 
        person_enter = 0;
        $display("Pessoas a bordo: %d", num_people);
        req = 5'b00001; 
        $display("Requisição para o andar ", andar_requisitado);
        wait (andar_atual == 3'd0);
        $display("Chegou ao andar ", andar_requisitado);

        // 6. Todo mundo sai no térreo
        while(num_people > 0) begin
            @(posedge clk); 
            person_exit = 1;
            @(posedge clk); 
            person_exit = 0;
        end
        $display("Todos saíram. Pessoas a bordo: %d", num_people);

        #10;
        $display("Acabou simulação.");
        $finish;
    end

endmodule