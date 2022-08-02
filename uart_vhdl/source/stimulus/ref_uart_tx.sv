module ref_uart_tx 
    #(parameter CLKS_PER_BAUD = 24'd868)
    (
    input  wire       i_clk,
    input  wire       i_rstn,

    input  wire       i_wr,
    input  wire [7:0] i_data,
    
    output wire       o_uart_tx,
    output reg        o_busy
    );

// 
    reg [3:0]  STATE, NEXT_STATE;
    localparam START = 4'h0;
    localparam BIT_0 = 4'h1;
    localparam BIT_1 = 4'h2;
    localparam BIT_2 = 4'h3;
    localparam BIT_3 = 4'h4;
    localparam BIT_4 = 4'h5;
    localparam BIT_5 = 4'h6;
    localparam BIT_6 = 4'h7;
    localparam BIT_7 = 4'h8;
    localparam LAST  = 4'h8;
    localparam IDLE  = 4'hf;

    reg [8:0]                     tx_queue;
    reg [$clog2(CLKS_PER_BAUD):0] baudCounter;
    reg                           baud;

    initial begin
        o_busy     = 0;
        tx_queue   = 9'h1ff;  // all 1s
        STATE      = IDLE;
        NEXT_STATE = IDLE;
    end

// Baud Counter
    always@(posedge i_clk) begin
        if(!i_rstn) begin
            baudCounter <= 0;
            baud        <= 0;
        end
        else begin
            if(i_wr && !o_busy) begin
                baudCounter <= CLKS_PER_BAUD-1;
                baud        <= 0;
            end
            else if(!baud) begin
                baudCounter <= baudCounter-1;
                baud        <= (baudCounter == 1);
            end
            else if(STATE != IDLE) begin
                baudCounter <= CLKS_PER_BAUD-1;
                baud        <= 0;
            end
        end
    end

// FSM 
    always@* begin
        case(STATE)
            IDLE:    NEXT_STATE = ((i_wr)&&(!o_busy)) ? START:IDLE;
            LAST:    NEXT_STATE = (baud) ? IDLE:STATE;
            default: NEXT_STATE = (baud) ? (STATE+1):STATE;
        endcase
    end

    always@(posedge i_clk) begin
        if(!i_rstn) STATE <= IDLE;
        else        STATE <= NEXT_STATE;
    end

// TX Shift Register
    assign o_uart_tx = tx_queue[0];
    always@(posedge i_clk) begin
        if(!i_rstn) begin
            tx_queue <= 9'h1ff;
        end
        else begin
            if(i_wr && !o_busy) tx_queue <= {i_data, 1'b0}; 
            else if(baud)     tx_queue <= {1'b1, tx_queue[8:1]};
        end
    end


// Busy Flag
    always@(posedge i_clk) begin
        if(!i_rstn) begin
            o_busy <= 0;
        end
        else if(i_wr && !o_busy) begin
            o_busy <= 1;
        end
        else if(baud) begin
            case(STATE)
                IDLE:    o_busy <= 0;
                default: o_busy <= 1; 
            endcase
        end
    end

endmodule