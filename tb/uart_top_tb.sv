module uart_top_tb();

// TEST PARAMETERS
    parameter T_CLK = 40;
    //
    localparam  DIVISOR_X16  = 16'd13;
    localparam  FRA_ADJ_X16  = 4'd6;

    localparam DATA_WIDTH = 8;
    localparam BAUDGEN_COUNTER_WIDTH = 20;
    localparam FIFO_ADDR_WIDTH = 4;
    //
    localparam CLKS_PER_BYTE = 2500;

// TEST VARS
    logic i_clk, i_rstn;
    
    logic                       i_tx_wr;
    logic [DATA_WIDTH-1:0]      i_tx_data;
    logic                       o_tx_full;
    logic [FIFO_ADDR_WIDTH:0]   o_tx_fill;
    logic                       i_tx_fifo_rst;

    logic                       i_rx_rd;
    logic [DATA_WIDTH-1:0]      o_rx_data;
    logic                       o_rx_empty;
    logic [FIFO_ADDR_WIDTH:0]   o_rx_fill;
    logic                       i_rx_fifo_rst;

    logic i_error_rst;
    logic [1:0] o_uart_rx_error;
    logic [3:0] o_fifo_rx_overrun;
    logic [3:0] o_fifo_tx_overrun;

    logic TX;
    logic RX;
    assign RX = TX; // loopback test

    // TEST ENVIRONMENT
    localparam FIFO_DEPTH = 2**FIFO_ADDR_WIDTH-1;
    logic [DATA_WIDTH-1:0] test_queue [$];
    logic [DATA_WIDTH-1:0] test_expected;

// CLOCK GEN
    initial i_clk = 0;
    always#(T_CLK/2) i_clk = !i_clk;

// DUT INSTANTIATION
    uart 
    #(.DATA_WIDTH            (DATA_WIDTH),
      .TX_PARITY_EN          (0),
      .RX_PARITY_EN          (0),
      .BAUDGEN_COUNTER_WIDTH (BAUDGEN_COUNTER_WIDTH),
      .FIFO_ADDR_WIDTH       (FIFO_ADDR_WIDTH))
    DUT (
    .i_clk             (i_clk),
    .i_rstn            (i_rstn),
    
    // baudgen cfg
    .i_divisor_x16     (DIVISOR_X16),
    .i_fra_adj_x16     (FRA_ADJ_X16),
    
    // tx fifo
    .i_tx_wr           (i_tx_wr),
    .i_tx_data         (i_tx_data),
    .o_tx_full         (o_tx_full),
    .o_tx_fill         (o_tx_fill),
    .i_tx_fifo_rst     (i_tx_fifo_rst),
    
    // rx fifo
    .i_rx_rd           (i_rx_rd),
    .o_rx_data         (o_rx_data),
    .o_rx_empty        (o_rx_empty),
    .o_rx_fill         (o_rx_fill),
    .i_rx_fifo_rst     (i_rx_fifo_rst),

    // status
    .i_error_rst       (i_error_rst),
    .o_uart_rx_error   (o_uart_rx_error),
    .o_fifo_tx_overrun (o_fifo_tx_overrun),
    .o_fifo_rx_overrun (o_fifo_rx_overrun),

    // uart interface
    .i_RX (RX),
    .o_TX (TX)
    );

// SIM TASKS

    /* Write to TX FIFO */
    task txWrite;
        input int numBytes;
        begin
            for(int i=0; i<numBytes; i++) begin
                @(posedge i_clk) begin
                    i_tx_data <= $urandom;
                    i_tx_wr   <= 1; 
                    //
                    #1;
                    if(!o_tx_full) begin
                        $display("TX FIFO writes [%2d]: %b", i, i_tx_data);
                        test_queue.push_front(i_tx_data);
                    end
                    else $display("User TX FIFO overrun! Write data: %b", i_tx_data);
                end
            end
            @(posedge i_clk) i_tx_wr <= 0;
        end
    endtask;

    /* Read from RX FIFO */
    task rxRead;
        input int numBytes;
        begin
            $display("-------------------------------");
            for(int i=0; i<numBytes; i++) begin
                @(posedge i_clk) i_rx_rd <= 1;
                @(posedge i_clk) i_rx_rd <= 0;
            end
            @(posedge i_clk) i_rx_rd <= 0;
            $display("-------------------------------");
        end
    endtask;

    /* Reset TX FIFO */
    task txFifoRst;
        begin
            @(posedge i_clk) i_tx_fifo_rst <= 1;
            @(posedge i_clk) i_tx_fifo_rst <= 0;
        end
    endtask;

    /* Reset RX FIFO */
    task rxFifoRst;
        begin
            @(posedge i_clk) i_rx_fifo_rst <= 1;
            @(posedge i_clk) i_rx_fifo_rst <= 0;
        end
    endtask;

    /* Reset error flags */
    task errorRst;
        begin 
            @(posedge i_clk) i_error_rst <= 1;
            @(posedge i_clk) i_error_rst <= 0;
        end
    endtask;



//
    always@(posedge i_clk) begin
        if(o_uart_rx_error) $display("RX ERROR!");
        if(o_fifo_rx_overrun > 0 & i_rx_rd) $display("RX OVERRUN!");
        if(o_fifo_tx_overrun > 0 & i_tx_wr) $display("TX OVERRUN!");
    end

    always@(posedge i_clk) begin
        if(!o_rx_empty & i_rx_rd) begin
            test_expected = test_queue.pop_back();
            $display("RX FIFO expected:  %b", test_expected);
            $display("RX FIFO reads:     %b", o_rx_data);
            $display("");
        end
    end

// MAIN SIM
    initial begin
        i_rstn        = 0;
        i_tx_wr       = 0;
        i_tx_data     = 0;
        i_tx_fifo_rst = 0;
        i_rx_rd       = 0;
        i_rx_fifo_rst = 0;
        i_error_rst   = 0;
        #100;
        i_rstn = 1;
        #100;

        /*
        Write 16 bytes and don't read.
        -> expect 16 bytes to be sent.
        -> expect 0 overrun errors.
        */
        txWrite(16);
        repeat(16*CLKS_PER_BYTE) begin
            @(posedge i_clk);
        end

        /*
        Read 16 bytes.
        ->
        */
        rxRead(16);

        /*
        Write 8 bytes and read them back.
        -> expect no errors and for all bytes to be successfully read back
        */
        txWrite(8);
        repeat(8*CLKS_PER_BYTE) begin 
            @(posedge i_clk); 
        end
        rxRead(8);
//
        /*
        Write 20 bytes, don't read, and don't wait for tx to send more than
        one byte.
        -> expect 16 bytes to be sent.
        -> expect 4 overrun errors.
        */
        txWrite(20);

        /*
        Write 5 more bytes.
        -> expect 5 RX FIFO overrun errors.
        */
        txWrite(5);
        repeat(16*CLKS_PER_BYTE) begin 
            @(posedge i_clk); 
        end
//
        ///*
        //Empty the RX FIFO.
        //-> expect 0 errors.
        //*/
        //rxRead(16);
//
        ///*
        //Write 16 bytes and don't read.
        //-> expect 16 bytes to be sent.
        //-> expect 0 overrun errors.
        //*/
        //txWrite(16);
        //repeat(16*CLKS_PER_BYTE) begin
        //    @(posedge i_clk);
        //end
//
        ///*
        //Read 16 bytes and don't read.
        //->
        //*/
        //rxRead(16);
        //#10000;
        //
        ///*
        //Read 5 bytes from an empty RX FIFO.
        //-> This should never happen during normal operation, driver
        //   will block reads from empty.
        //*/
        //rxRead(5);
//
        ///*
        //Reset the error register.
        //*/
        //errorRst();
//
        //#2000;
        $stop;
    end

endmodule