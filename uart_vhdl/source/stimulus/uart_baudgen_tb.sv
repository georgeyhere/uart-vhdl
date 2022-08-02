module uart_baudgen_tb();

/* TESTBENCH PARAMETERS */
	parameter T_CLK         = 20;
	parameter COUNTER_WIDTH = 20;
	parameter DIVISOR_X16   = 27;
	parameter FRA_ADJ_x16   = 8;

/* TESTBENCH VARS */
	// DUT
	logic        i_clk;
	logic        i_rstn;
	logic [15:0] i_divisor_x16;
	logic [3:0]  i_fra_adj_x16;
	logic        o_baud_x16;


	// Test Environment
	real t_riseTime_x16;
	real t_deltaTime_x16;
	real t_riseTime_x1;
	real t_deltaTime_x1;
	int  t_tickCount;

/* CLOCK GEN */
	initial i_clk = 0;
	always#(T_CLK/2) i_clk = ~i_clk;

/* DUT INSTANTIATION */
	uart_baudgen
	#(.COUNTER_WIDTH(COUNTER_WIDTH))
	DUT (
	.i_clk         (i_clk),
	.i_rstn        (i_rstn),
    //
    .i_divisor_x16 (i_divisor_x16),
    .i_fra_adj_x16 (i_fra_adj_x16),
    //
	.o_baud_x16    (o_baud_x16)
	);

/* SIM TASKS */
	// measure 16x baud tick period
	initial t_riseTime_x16  = 90;
	initial t_riseTime_x1   = 90;
	initial t_tickCount     = 0;
	
	always@(posedge o_baud_x16) begin 
		t_deltaTime_x16 = $realtime - t_riseTime_x16;
		$display("%t : 16x Baud Tick | Time since previous 16x Baud Tick: %t", $realtime, t_deltaTime_x16);
		t_riseTime_x16 = $realtime;
		if(t_tickCount == 15) begin 
			t_deltaTime_x1 = $realtime - t_riseTime_x1;
			$display("\n%t : 1x Baud | Time since previous Baud Tick: %t\n", $realtime, t_deltaTime_x1);
			t_tickCount = 0;
			t_riseTime_x1 = $realtime;
		end
		else begin 
			t_tickCount = t_tickCount+1;
		end
	end

/* MAIN SIM */
	initial begin 
		i_rstn        = 0;
        i_divisor_x16 = DIVISOR_X16;
		i_fra_adj_x16 = FRA_ADJ_x16;
		
		#100
		
		@(posedge i_clk);
		t_riseTime_x16 = $realtime;
		t_riseTime_x1  = $realtime;
		$display("%t : Reset deasserted", $realtime);
		i_rstn        = 1;

        #100000;

        $stop;
	end

endmodule : uart_baudgen_tb