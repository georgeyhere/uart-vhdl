module uart_baudgen_tb();

/* TESTBENCH PARAMETERS */
	parameter T_CLK         = 40;
	parameter COUNTER_WIDTH = 20;
	parameter DIVISOR       = 27;
	parameter FRA_ADJ       = 8;

/* TESTBENCH VARS */
	// DUT
	logic        i_clk;
	logic        i_rstn;
	logic [15:0] i_divisor;
	logic [3:0]  i_fra_adj;
	logic        o_baud;
	logic        o_baud_x16;

	// Test Environment
	real t_riseTime_x16;
	real t_deltaTime_x16;
	//
	real t_riseTime_x1;
	real t_deltaTime_x1;
	//
	logic t_timeValid_x1;
	logic t_timeValid_x16;
	

/* CLOCK GEN */
	initial i_clk = 0;
	always#(T_CLK/2) i_clk = ~i_clk;

/* DUT INSTANTIATION */
	uart_baudgen
	#(.COUNTER_WIDTH(COUNTER_WIDTH))
	DUT (
	.i_clk      (i_clk),
	.i_rstn     (i_rstn),
	//
	.i_divisor  (i_divisor),
	.i_fra_adj  (i_fra_adj),
	//
	.o_baud     (o_baud),
	.o_baud_x16 (o_baud_x16)
	);

/* SIM TASKS */
	// measure baud tick period
	initial t_timeValid_x1 = 0;
	always@(posedge o_baud) begin 
		if(!t_timeValid_x1) begin 
			t_riseTime_x1  = $realtime;
			t_timeValid_x1 = 1;
		end
		else begin 
			t_deltaTime_x1 = $realtime - t_riseTime_x1;
			$display("At time %t: Baud Period = %t", $realtime, t_deltaTime_x1);
			t_timeValid_x1 = 0;
		end
	end

	// measure 16x baud tick period
	initial t_timeValid_x16 = 0;
	always@(posedge o_baud_x16) begin 
		if(!t_timeValid_x16) begin 
			t_riseTime_x16  = $realtime;
			t_timeValid_x16 = 1;
		end
		else begin
			t_deltaTime_x16 = $realtime - t_riseTime_x16;
			$display("At time %t: 16x Baud Period = %t", $realtime, t_deltaTime_x16);
			t_timeValid_x16 = 0;
		end
	end

/* MAIN SIM */
	initial begin 
		i_rstn    = 0;
		i_divisor = DIVISOR;
		i_fra_adj = FRA_ADJ;
		#100;
		i_rstn    = 1;
	end

endmodule : uart_baudgen_tb