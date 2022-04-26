module uart_demo_tb();

// TEST PARAMETERS
    parameter T_CLK = 10;

// TEST VARS
    logic i_clk, i_rstn;
    logic i_RX, o_TX;
    logic [7:0] o_LED;

    assign i_RX = o_TX;

// DUT INSTANTIATION
    uart_demo DUT(
    .i_clk  (i_clk),
    .i_rstn (i_rstn),
    .i_RX   (i_RX),
    .o_TX   (o_TX)
    );

// CLOCK GEN
    initial i_clk = 0;
    always#(T_CLK/2) i_clk = !i_clk;

// MAIN SIM
    initial begin
        i_rstn = 0;
        #100;
        i_rstn = 1;
        #10000000;
        $stop();
    end

endmodule