module uart_rx_tb();

// TEST PARAMETERS
	//`define TEST_PARITY
	//
	parameter  T_CLK = 40;
	localparam BAUDGEN_COUNTER_WIDTH = 20;
	//
	localparam DIVISOR = 16'd13;
	localparam FRA_ADJ = 4'd2;

	`ifdef TEST_PARITY
	localparam PARITY_EN = 1;
	`else 
	localparam PARITY_EN = 0;
	`endif

	localparam DATA_WIDTH   = 8;
	localparam TIMEOUT_CLKS = 100000;

// TEST VARS
	logic                  i_clk;
	logic                  i_rstn;
	logic                  baud_tick;
	logic                  baud_tick_x16;
	//
	logic [DATA_WIDTH-1:0] rx_data;
	logic                  rx_valid;
	logic [1:0]            rx_error;


	/* TEST ENVIRONMENT */
	logic                  TX;
	logic [DATA_WIDTH-1:0] i_din;
	logic                  i_valid;
	logic                  o_busy;


// CLOCK GEN
	initial i_clk = 0;
	always#(T_CLK/2) i_clk = ~i_clk;

// REFERENCE UART TX
	uart_tx
    #(.DATA_WIDTH (DATA_WIDTH),
      .PARITY_EN  (PARITY_EN))
    uart_tx_i (
    .i_clk   (i_clk),
    .i_rstn  (i_rstn),
    .i_baud  (baud_tick),
    //
    .i_din   (i_din),
    .i_valid (i_valid),
    //
    .o_busy  (o_busy),
    //
    .o_TX    (TX)
    ); 

// DUT INSTANTIATION
	uart_baudgen 
    #(.COUNTER_WIDTH(20))
    baudgen_i(
    .i_clk      (i_clk),
    .i_rstn     (i_rstn),
    // 
    .i_divisor  (DIVISOR),
    .i_fra_adj  (FRA_ADJ),
    //
    .o_baud     (baud_tick),
    .o_baud_x16 (baud_tick_x16) // unused
    );

    uart_rx 
    #(.DATA_WIDTH(DATA_WIDTH),
      .PARITY_EN (PARITY_EN))
    DUT(
    .i_clk      (i_clk),
    .i_rstn     (i_rstn),
    .i_baud_x16 (baud_tick_x16),
    //
    .o_dout     (rx_data),
    .o_valid    (rx_valid),
    //
    .o_error    (rx_error),
    //
    .i_RX       (TX)
    );

/* CLOCK GEN */
    initial i_clk = 0;
    //always#(T_CLK/2) i_clk = ~i_clk;

// SIM TASKS
	task sendFrame;
        input logic [DATA_WIDTH-1:0] txData;
        begin
            $display("Sending TX Data %b...", txData);
            // set inputs
            @(posedge i_clk) begin
                i_din   <= txData;
                i_valid <= 1;
            end
            // deassert input valid
            @(posedge i_clk) i_valid <= 0;
            @(posedge i_clk);
            
            wait(!rx_valid);
            for(int i=0; i<TIMEOUT_CLKS; i++) begin
                @(posedge i_clk) begin
                    if(rx_valid) begin
                        if(txData != rx_data) begin
                        	$display("ERROR! TX sends: %b || RX receives: %b", txData, rx_data);
                        	$stop();
                        end
                        else begin
                        	$display("PASS!  TX sends: %b || RX receives: %b", txData, rx_data);
                        end
                        wait(!o_busy);
                        break;
                    end
                    if(i==TIMEOUT_CLKS-1) begin
                        $display("RX failed to receive valid data!");
                        //$stop();
                        break;
                    end
                end
            end
        end
    endtask

// MAIN SIM
	initial begin
        i_rstn  = 0;
        i_din   = 0;
        i_valid = 0;
        #100;
        i_rstn  = 1;
        @(posedge i_clk);

        //
        sendFrame(8'b10100110);
        sendFrame(8'b00110111);
        sendFrame(8'b0);
        sendFrame(8'hFF);
        //
        $stop();
    end

endmodule 