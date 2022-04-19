-- uart_rx.vhd
--
-- UART RX w/ parameterizable data width and optional parity bit. Only supports one stop bit.
--
-- o_error:
--    [0] -> '1' when a stop bit was missed. Held until return to STATE_IDLE.
--    [1] -> '1' when a parity check is failed, else '0'.
--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.ALL;
use IEEE.math_real.ALL;
--
entity uart_rx is
generic (
    DATA_WIDTH : integer := 8;  -- # of data bits in frame
    PARITY_EN  : integer := 0   -- '1' to enable parity bit, else '0'
);
port (
    i_clk      : in  std_logic; -- input clock
    i_rstn     : in  std_logic; -- active-low reset
    i_baud_x16 : in  std_logic; -- 16x baud tick for RX sampling
    
    -- RX data and valid
    o_dout     : out std_logic_vector (DATA_WIDTH-1 downto 0); 
    o_valid    : out std_logic;

    -- Status
    o_error    : out std_logic_vector (1 downto 0); 

    -- UART RX pin
    i_RX       : in  std_logic
);
end uart_rx;

--
architecture Behavioral of uart_rx is
    -- 
    constant FRAME_WIDTH     : integer := DATA_WIDTH + 2 + PARITY_EN; 

    -- FSM state enumeration w/ one-hot encoding
    type t_fsm_state is (STATE_IDLE, STATE_START, STATE_ACTIVE, STATE_STOP);
    attribute syn_encoding : string;
    attribute syn_encoding of t_fsm_state : type is "onehot, safe";
    signal STATE : t_fsm_state;

    -- 2FF synchronizer for i_RX
    signal q1_RX, q2_RX : std_logic;

    -- Baud counter
    signal baud_count : integer range 0 to 16 := 0;

    -- Bit counter; used to keep track of # of bits left to receive in frame
    signal rx_count : integer range 0 to FRAME_WIDTH-1 := 0;

    -- Shift register for captured RX data
    signal rx_data : std_logic_vector (FRAME_WIDTH-1 downto 0);

    -- parity bit check: '1' for odd # of 1s, else '0'
    signal parity : std_logic;
begin

-- Double flop i_RX to prevent metastability
    RX_SYNC: process(i_clk) 
    begin
        if rising_edge(i_clk) then
            q1_RX <= i_RX;
            q2_RX <= q1_RX;
        end if;
    end process;

-- Combinatorial parity bit checker
    PARITY_CHK: process(rx_data)
    variable v_parity : std_logic;
    begin
        for i in rx_data'range loop
            v_parity := v_parity xor rx_data(i);
        end loop;
        parity <= v_parity;
    end process;

-- Sync FSM process
    FSM_SYNC: process(i_clk) 
    begin
        if rising_edge(i_clk) then
            if(i_rstn = '0') then
                STATE      <= STATE_IDLE;
                o_valid    <= '0';
                o_error    <= (others => '0');
                o_dout     <= (others => '0');
                rx_data    <= (others => '0');
                rx_count   <= 0;
                baud_count <= 0;
            else 
                case STATE is 

                -- STATE_IDLE:
                -- When q2_RX goes low, go to STATE_START.
                    when STATE_IDLE =>
                        baud_count <= 0;
                        rx_count   <= 0;
                        rx_data    <= (others => '0');
                        if (q2_RX = '0') then
                            o_valid <= '0';
                            STATE   <= STATE_START;
                        end if;

                -- STATE_START:
                -- Check that q2_RX remains low for at 8 sampling baud ticks.
                    when STATE_START =>
                        if(i_baud_x16 = '1') then
                            if(baud_count = 7) then
                                baud_count <= 0;
                                STATE      <= STATE_ACTIVE;
                            else
                                baud_count <= baud_count + 1;
                                if(q2_RX = '1') then
                                    STATE <= STATE_IDLE;
                                end if;
                            end if;
                        end if;

                -- STATE_ACTIVE:
                -- Sample and shift in q2_RX once every 16 sampling baud ticks.
                    when STATE_ACTIVE =>
                        if(i_baud_x16 = '1') then
                            if(baud_count = 15) then
                                baud_count <= 0;
                                rx_data    <= rx_data(FRAME_WIDTH-2 downto 0) & q2_RX;
                                --
                                if(rx_count = FRAME_WIDTH-2-PARITY_EN-1) then
                                    STATE <= STATE_STOP;
                                    if((PARITY_EN=1) and (parity /= q2_RX)) then
                                        o_error(1) <= '1';
                                    end if;
                                else 
                                    rx_count <= rx_count + 1;
                                end if;
                            else
                                baud_count <= baud_count + 1;
                            end if;
                        end if;

                -- STATE_STOP:
                -- Look for stop bit. 
                    when STATE_STOP =>
                        if(i_baud_x16 = '1') then
                            if(baud_count = 15) then
                                baud_count <= 0;
                                STATE <= STATE_IDLE;
                                if(q2_RX = '1') then
                                    o_valid <= '1';
                                    if(PARITY_EN=1) then
                                        o_dout <= rx_data(DATA_WIDTH downto 1);
                                    else
                                        o_dout <= rx_data(DATA_WIDTH-1 downto 0);
                                    end if;
                                else 
                                    o_valid    <= '0';
                                    o_error(0) <= '1';
                                end if;
                            else 
                                baud_count <= baud_count + 1;
                            end if;
                        end if;
                end case;
                
            end if;
        end if;
    end process;

end Behavioral;