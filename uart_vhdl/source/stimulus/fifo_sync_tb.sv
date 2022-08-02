module fifo_sync_tb();

// TEST PARAMETERS
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 3;
    parameter T_CLK = 10;
    //

// TEST VARS
    logic                  i_clk;
    logic                  i_rstn;
    logic                  fifo_wr; 
    logic                  fifo_rd;
    logic [DATA_WIDTH-1:0] fifo_din; 
    logic [DATA_WIDTH-1:0] fifo_dout;
    logic                  status_almost_empty;
    logic                  status_empty;
    logic                  status_almost_full;
    logic                  status_full;
    logic [ADDR_WIDTH:0]   status_fill;
    logic                  status_overrun;
    //
    logic                  test_overrun;
    logic                  test_read_from_empty;
    integer                test_fill = 0;
    logic [DATA_WIDTH-1:0] test_queue [$];
    

// DUT INSTANTIATION
    fifo_sync 
    #(.FIFO_DATA_WIDTH(DATA_WIDTH),
      .FIFO_ADDR_WIDTH(ADDR_WIDTH))
    DUT (
    .i_clk          (i_clk),
    .i_rstn         (i_rstn),
    //        
    .i_wr           (fifo_wr),
    .i_din          (fifo_din),
    .i_rd           (fifo_rd),
    .o_dout         (fifo_dout),
    //
    .o_almost_empty (status_almost_empty),
    .o_empty        (status_empty),
    .o_almost_full  (status_almost_full),
    .o_full         (status_full),
    .o_fill         (status_fill),
    .o_overrun      (status_overrun)
    );

// CLOCK GEN
    initial i_clk = 0;
    always#(T_CLK/2) i_clk = !i_clk;

// SIM TASK

    /* Task to write byteCount # of random bytes to the DUT regardless of status.
        -> The random bytes are pushed to the front of the test_queue queue.
        -> Status flags are displayed if any are asserted.
    */
    task writeToFifo;
        input logic [ADDR_WIDTH:0] byteCount;
        //
        logic [DATA_WIDTH-1:0] test_byte;
        begin
            for(int i=0; i<byteCount; i++) begin
                test_byte = $urandom;
                test_queue.push_front(test_byte);
                @(posedge i_clk) begin
                    fifo_wr  <= 1;
                    fifo_din <= test_byte;
                    test_fill++;
                    //if(status_empty) $display("Written %d bytes; FIFO empty asserted.", i);
                    //if(status_full)  $display("Written %d bytes; FIFO full asserted.",  i);
                    //if(status_error) $display("Written %d bytes; FIFO error asserted.", i);
                    //$display("Test Fill Count: %d | Actual Fill Count: %d", test_fill, status_fill);
                end
            end
            @(posedge i_clk) begin
                fifo_wr <= 0;
            end
        end
    endtask;

    /* Task to read byteCount # of bytes from the DUT regardless of status. The read
       bytes are compared against test_queue values.
        -> Byte comparison is only done on valid reads.
    */
    task readFromFifo;
        input logic [ADDR_WIDTH:0] byteCount;
        //
        logic [DATA_WIDTH-1:0] test_byte;
        logic [DATA_WIDTH-1:0] test_expected;
        begin
            for(int i=0; i<byteCount; i++) begin
                @(posedge i_clk) begin
                    fifo_rd   <= 1;
                    //if(status_empty) $display("Written %d bytes; FIFO empty asserted.", i);
                    //if(status_full)  $display("Written %d bytes; FIFO full asserted.",  i);
                    //if(status_error) $display("Written %d bytes; FIFO error asserted.", i);
                    //$display("Test Fill Count: %d | Actual Fill Count: %d", test_fill, status_fill);
                    //if(test_fill > 0) begin
                    //    test_expected = test_queue.pop_back();
                    //    $display("FIFO Read: Expected: %b | Actual: %b", fifo_dout, test_expected);
                    //end
                    test_fill = (test_fill > 0) ? test_fill-1 : 0;
                end
                
            end
            @(posedge i_clk) fifo_rd <= 0;
        end
    endtask;

    always@(posedge i_clk) begin
        if(fifo_rd)
            $display("FIFO read data:  %b", fifo_dout);
    end
    //always@(posedge fifo_rd) $display("");
    //always@(negedge fifo_rd) $display("");

    always@(posedge i_clk) begin
        if(fifo_wr)
            $display("FIFO write data: %b", fifo_din);
    end
    //always@(posedge fifo_wr) $display("");
    //always@(negedge fifo_wr) $display("");

    always@(posedge i_clk) begin
        if(status_empty & fifo_rd) test_read_from_empty <= 1;
        else test_read_from_empty <= 0;
    end

    always@(posedge i_clk) begin
        if(status_fill == 7 & fifo_wr == 1) test_overrun <= 1;
        else test_overrun <= 0;
    end

    always@(posedge i_clk) begin
        if(status_overrun) $display("OVERRUN");
    end


// MAIN SIM
    initial begin
        i_rstn    = 0;
        fifo_wr   = 0;
        fifo_din  = 0;
        fifo_rd   = 0;
        #100;
        i_rstn = 1;
		
		$display("\nFilling and then emptying the FIFO. Expect data to match.");
        for(int i=0; i<30; i++) begin
            @(posedge i_clk) begin
                if(!status_almost_full) begin
                    fifo_wr  <= 1;
                    fifo_din <= $urandom;
                end
                else begin
                    fifo_wr  <= 0;
                    fifo_din <= 0;
                    break;
                end
            end
        end
        #100;
		$display("");
        for(int i=0; i<30; i++) begin
            @(posedge i_clk) begin
                if(!status_almost_empty) begin
                    fifo_rd <= 1;
                end
                else begin
                    fifo_rd <= 0;
                    break;
                end
            end
        end

        // Write a byte and then read it back
		$display("\nWriting and reading a single word. Expect data to match.");
        writeToFifo(1);
        readFromFifo(1);
        
        // Fill the FIFO and then empty it
		$display("\nFilling and then emptying the FIFO. Expect data to match.");
        writeToFifo (2**ADDR_WIDTH);
		$display("");
        readFromFifo(2**ADDR_WIDTH);
        
        // Underfill the FIFO, empty it, and try to read from empty
		$display("\nUnderfilling the FIFO.");
        writeToFifo (2**ADDR_WIDTH-3);
		$display("\nEmptying, then reading from empty FIFO. Expect data mismatch.");
        readFromFifo(2**ADDR_WIDTH);

        // Overfill the FIFO and empty it
		$display("\nOverfilling the FIFO.");
        writeToFifo (9);
		$display("\nEmptying the FIFO. Expect first few words from overfill to be lost.");
        readFromFifo(2**ADDR_WIDTH);

        //
        #100;
        $stop();
    end

endmodule