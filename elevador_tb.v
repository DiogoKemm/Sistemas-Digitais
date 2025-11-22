`timescale 1ns / 1ps

module elevador_tb;

    // Entradas para UUT
    reg clk;
    reg reset;
    reg [4:0] req;
    reg person_enter;
    reg person_exit;
    reg emergency; // <--- Novo sinal de teste

    // Saídas do UUT
    wire motor_up;
    wire motor_down;
    wire [2:0] andar_atual;
    wire [2:0] andar_requisitado;
    wire [3:0] num_people;

    // Instanciação do módulo `elevador`
    // Nota: Certifique-se que o seu módulo elevador.v tem a porta 'emergency' adicionada
    elevador uut (
        .clk(clk),
        .reset(reset),
        .req(req),
        .person_enter(person_enter),
        .person_exit(person_exit),
        .emergency(emergency), // Ligação da emergência
        .motor_up(motor_up),
        .motor_down(motor_down),
        .andar_atual(andar_atual),
        .andar_requisitado(andar_requisitado),
        .num_people(num_people)
    );

    // Geração do clock (período de 10 unidades de tempo)
    always #5 clk = ~clk;

    initial begin
        // Configuração para gerar ficheiro de ondas (se usar Icarus Verilog/GTKWave)
        $dumpfile("elevador_emergencia.vcd");
        $dumpvars(0, elevador_tb);

        // Inicialização
        clk = 0;
        reset = 1;
        req = 5'b00000;
        person_enter = 0;
        person_exit = 0;
        emergency = 0;

        // Espera o reset
        #15;
        reset = 0;
        $display("=== Início da Simulação ===");
        $display("Estado Inicial: Andar %d, Pessoas %d", andar_atual, num_people);

        // -------------------------------------------------------
        // CENÁRIO 1: Operação Normal (Subir para o 4º andar)
        // -------------------------------------------------------
        #10;
        req = 5'b10000; // Requisita andar 4
        $display("[T=%0t] Requisição para o andar 4 feita.", $time);
        
        // Espera o elevador começar a mover-se (chegar ao andar 1 por exemplo)
        wait (andar_atual == 3'd1);
        $display("[T=%0t] Elevador a passar no andar %d. Motores: Up=%b, Down=%b", $time, andar_atual, motor_up, motor_down);

        // -------------------------------------------------------
        // CENÁRIO 2: Ativação da Emergência
        // -------------------------------------------------------
        @(posedge clk);
        emergency = 1; // ALARME!
        $display("[T=%0t] !!! EMERGÊNCIA ATIVADA !!!", $time);

        // Espera alguns ciclos para ver se ele para
        #20; 
        if (motor_up == 0 && motor_down == 0)
            $display("[SUCESSO] Elevador parado durante emergência no andar %d.", andar_atual);
        else
            $display("[FALHA] O elevador continua a mover-se!");

        // Verifica se o andar se mantém (não deve mudar enquanto emergency=1)
        #30;
        $display("[T=%0t] Estado durante emergência: Andar %d (Motor Up: %b)", $time, andar_atual, motor_up);

        // -------------------------------------------------------
        // CENÁRIO 3: Desativação da Emergência e Retoma
        // -------------------------------------------------------
        @(posedge clk);
        emergency = 0; // Desliga alarme
        $display("[T=%0t] Emergência desativada.", $time);

        // O elevador deve voltar a IDLE e depois detetar que ainda não chegou ao 4
        // e retomar o movimento.
        wait (andar_atual == 3'd4);
        $display("[T=%0t] Elevador chegou ao destino (andar %d) após emergência.", $time, andar_atual);

        // Retirar requisição
        req = 5'b00000;

        // -------------------------------------------------------
        // CENÁRIO 4: Teste de Passageiros (Opcional, igual ao anterior)
        // -------------------------------------------------------
        #10;
        person_enter = 1;
        @(posedge clk);
        person_enter = 0;
        #5;
        $display("[T=%0t] Pessoa entrou. Total: %d", $time, num_people);

        #20;
        $display("=== Fim da Simulação ===");
        $finish;
    end

endmodule