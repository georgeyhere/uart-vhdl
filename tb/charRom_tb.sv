module charRom_tb();

// TEST PARAMETERS
    parameter T_CLK = 10;

// TEST VARS
    logic       i_clk;
    logic [4:0] i_addr;
    logic [7:0] o_dout;

// DUT INSTANTIATION
    charRom  
    #(.ROM_ADDR_WIDTH(5))
    DUT
    (
    .i_clk  (i_clk),
    .i_addr (i_addr),
    .o_dout (o_dout)
    );

// CLOCK GEN
    initial i_clk = 0;
    always#(T_CLK/2) i_clk = ~i_clk;

// MAIN SIM
    initial begin
        i_addr = 0;
        #100;
        //
        for(int i=0; i<32; i++) begin
            @(posedge i_clk) begin
                i_addr <= i_addr + 1;
                $display("Addr: %2d | Dout: %c", i_addr, o_dout);
            end
        end
        #100;
        $stop();
    end

endmodule