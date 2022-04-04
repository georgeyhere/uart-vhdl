module uart_tx_tb();

/* TESTBENCH PARAMETERS */
    //`define TEST_PARITY    
    //
    parameter   T_CLK      = 40;
    parameter   DATA_WIDTH = 8;
    //
    localparam  DIVISOR    = 16'd27;
    localparam  FRA_ADJ    = 4'd8;

    `ifdef TEST_PARITY
    localparam PARITY_EN   = 1;
    `else  
    localparam PARITY_EN   = 0;
    `endif
    localparam FRAME_LENGTH = DATA_WIDTH + 2 + PARITY_EN;

/* TESTBENCH VARS */
    // baudgen
    logic       baud_tick;

    // uart_tx
    logic                  i_clk;
    logic                  i_rstn;
    logic [DATA_WIDTH-1:0] i_din;
    logic                  i_valid;
    logic                  o_busy;
    logic                  o_TX;

/* DUT INSTANTIATION */

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
    .o_baud_x16 () // unused
    );


    uart_tx
    #(.DATA_WIDTH (DATA_WIDTH),
      .PARITY_EN  (PARITY_EN))
    DUT (
    .i_clk   (i_clk),
    .i_rstn  (i_rstn),
    .i_baud  (baud_tick),
    //
    .i_din   (i_din),
    .i_valid (i_valid),
    //
    .o_busy  (o_busy),
    //
    .o_TX    (o_TX)
    ); 

/* CLOCK GEN */
    initial i_clk = 0;
    always#(T_CLK/2) i_clk = ~i_clk;

/* SIM TASKS */
    task sendFrame;
        input logic [DATA_WIDTH-1:0] txData;
        begin
            $display("Time: %t: Sending TX Data %b", $realtime, txData);
            // set inputs
            @(posedge i_clk) begin
                i_din   <= txData;
                i_valid <= 1;
            end
            // deassert input valid
            @(posedge i_clk) i_valid <= 0;
            wait(!o_busy);
            @(posedge i_clk);
        end
    endtask

/* MAIN SIM */
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
    end

/* ASSERTS */
    //
    /*
    sequence s_frame_length;
        @(posedge i_clk) (baud_tick) [=FRAME_LENGTH];
    endsequence

    // check that busy flag is set at start of transaction
    property p_set_busy;
        @(posedge i_clk) (i_valid & !o_busy) |=> o_busy;
    endproperty
    set_busy_chk: assert property(p_set_busy);

    // check that busy is held throughout the entire transaction
    // and that o_TX returns to idle correctly
    property p_end_of_transaction;
        @(posedge i_clk) (i_valid && !o_busy) |=>
        ((o_busy) throughout s_frame_length) ##1 (!o_busy && o_TX);
    endproperty
    end_of_transaction_chk: assert property(p_end_of_transaction);

    // check that start bit is set correctly
    property p_start_bit;
        @(posedge i_clk) (i_valid & !o_busy) |=> !o_TX;
    endproperty
    start_bit_chk: assert property(p_start_bit);
    */
    
endmodule