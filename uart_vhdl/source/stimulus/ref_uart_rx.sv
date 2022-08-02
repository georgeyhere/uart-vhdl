// UART RX module
//
// Receives 8-bit data
// - 1 start bit
// - 1 stop bit
// - no parity bit
//
// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 10 MHz Clock, 115200 baud UART
// (10000000)/(115200) = 87

module ref_uart_rx 
    #(parameter CLKS_PER_BAUD = 868)
    (
    input  wire       i_clk,
    input  wire       i_rstn,
    input  wire       i_rx,
    
    output reg  [7:0] o_rx_data,
    output reg        o_rx_dvalid
    );

    
    // FSM 
    localparam IDLE      = 4'h0;
    localparam RX_BIT_0  = 4'h1;
    localparam RX_BIT_1  = 4'h2;
    localparam RX_BIT_2  = 4'h3;
    localparam RX_BIT_3  = 4'h4;
    localparam RX_BIT_4  = 4'h5;
    localparam RX_BIT_5  = 4'h6;
    localparam RX_BIT_6  = 4'h7;
    localparam RX_BIT_7  = 4'h8;
    localparam STOP_BIT  = 4'h9;
    reg [3:0]  STATE, NEXT_STATE;

    // double flop rx bit
    reg        rx_data_r;
    reg        rx_data;

    reg [$clog2(CLKS_PER_BAUD):0] baudCounter;

    initial begin
        STATE           = IDLE;
        NEXT_STATE      = IDLE;
        rx_data_r       = 1;
        rx_data         = 1;
        baudCounter     = 0;
        baudCounter     = 0;
    end

// Double flop rx bit
    always@(posedge i_clk) begin
        if(!i_rstn) begin
            rx_data_r <= 0;
            rx_data   <= 0;
        end
        else begin
            rx_data_r <= i_rx;
            rx_data   <= rx_data_r;
        end
    end

// FSM
    always@* begin
        case(STATE)
            IDLE: begin
                NEXT_STATE = (!rx_data) ? RX_BIT_0 : IDLE;
            end

            STOP_BIT: begin
                NEXT_STATE = (baudCounter==0) ? IDLE : STOP_BIT;
            end

            default: begin
                NEXT_STATE = (baudCounter==0) ? (STATE + 1) : STATE;
            end
        endcase
    end

    always@(posedge i_clk) begin
        if(!i_rstn) STATE <= IDLE;
        else STATE <= NEXT_STATE;
    end

// Baud Generator
    always@(posedge i_clk) begin
        if(!i_rstn) begin
            baudCounter <= 0;
        end
        else begin
        // load counter for 1.5 bauds on start bit
            if(STATE == IDLE) begin
                if(!rx_data) begin
                    baudCounter <= CLKS_PER_BAUD+CLKS_PER_BAUD/2-1'b1;
                end
            end 
    
        // when counter hits 0, either load or reset it
            else if(baudCounter==0) begin
                if(STATE == STOP_BIT) begin
                    baudCounter <= 0; 
                end
                else begin 
                    baudCounter <= CLKS_PER_BAUD-1; 
                end
            end
        
        // decrement counter in all other situations
            else begin
                baudCounter <= baudCounter-1;
            end
        end
    end

// Input Data Shift Register
    always@(posedge i_clk) begin
        if(!i_rstn) o_rx_data <= 0;
        else begin
            if((baudCounter == 0) && (STATE != STOP_BIT)) begin
                o_rx_data <= {rx_data, o_rx_data[7:1]};
            end 
            else begin
                o_rx_data <= o_rx_data;
            end
        end
    end

    always@(posedge i_clk) begin
        o_rx_dvalid <= ((baudCounter == 0) && (STATE == STOP_BIT));
    end

endmodule