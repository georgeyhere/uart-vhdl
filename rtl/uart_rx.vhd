-- uart_rx.vhd
--
-- UART RX w/ parameterizable data width and optional parity bit. Only supports one stop bit.
--
-- When a byte is received, o_valid is asserted for one cycle. o_valid is asserted EVEN IF
-- the parity check fails!
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
	i_clk         : in  std_logic; -- input clock
	i_rstn        : in  std_logic; -- active-low reset

    -- parity bit config
    i_parity_cfg  : in  std_logic; -- '1' for odd parity, '0' for even

    -- baud gen interface
	i_baud_x16    : in  std_logic; -- 16x baud tick for RX sampling
    o_baud_x16_en : out std_logic; -- baud tick enable
	
	-- RX data and valid
	o_dout        : out std_logic_vector (DATA_WIDTH-1 downto 0); -- data out
	o_valid       : out std_logic; -- data out valid, asserted for one cycle after transaction

	-- Status
	o_error       : out std_logic_vector (1 downto 0); 

	-- UART RX pin
	i_RX          : in  std_logic
);
end uart_rx;

--
architecture Behavioral of uart_rx is
	--  
    constant FRAME_WIDTH : integer := DATA_WIDTH + PARITY_EN;

	-- FSM state enumeration w/ one-hot encoding
	type t_fsm_state is (STATE_IDLE, STATE_START, STATE_ACTIVE, STATE_PARITY, STATE_STOP);
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
    signal parity_calc : std_logic_vector (FRAME_WIDTH downto 0);
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
	parity_calc(0) <= i_parity_cfg;
    PARITY_GEN: for i in 0 to (FRAME_WIDTH-1) generate
        parity_calc(i+1) <= parity_calc(i) xor rx_data(i);
    end generate;
    parity <= parity_calc(FRAME_WIDTH);

-- Sync FSM process
	FSM_SYNC: process(i_clk) 
	begin
		if rising_edge(i_clk) then
			if(i_rstn = '0') then
				STATE         <= STATE_IDLE;
                o_baud_x16_en <= '0';
				o_valid       <= '0';
				o_error       <= (others => '0');
				o_dout        <= (others => '0');
				rx_data       <= (others => '0');
				rx_count      <= 0;
				baud_count    <= 0;
			else 
				case STATE is 

				-- STATE_IDLE:
				--> When q2_RX goes low, go to STATE_START.
					when STATE_IDLE =>
                        o_baud_x16_en <= '0';
						baud_count    <=  0;
						rx_count      <=  0;
						o_valid       <= '0';
						rx_data       <= (others => '0');
						if (q2_RX = '0') then
                            o_baud_x16_en <= '1';
							STATE         <= STATE_START;
						end if;

				-- STATE_START:
				--> Check that q2_RX remains low for at 8 sampling baud ticks.
				--> If q2_RX does not remain low for 8 ticks, the start condition is rejected
				--  and the FSM returns to STATE_IDLE.
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
				--> Sample and shift in q2_RX once every 16 sampling baud ticks.
				--> If parity bit is enabled, goto STATE_PARITY after all data bits are sampled.
                --> Else, goto STATE_STOP.
					when STATE_ACTIVE =>
						if(i_baud_x16 = '1') then
							if(baud_count = 15) then
								baud_count <= 0;
								rx_data    <= q2_RX & rx_data(FRAME_WIDTH-1 downto 1);
								--
								if(rx_count = FRAME_WIDTH-1-PARITY_EN) then
                                    if(PARITY_EN = 1) then
                                        STATE <= STATE_PARITY;
                                    else
									    STATE <= STATE_STOP;
                                    end if;
								else 
									rx_count <= rx_count + 1;
								end if;
							else
								baud_count <= baud_count + 1;
							end if;
						end if;
                    
                    -- STATE_PARITY:
                    --> Sample parity bit and compare against locally generated parity bit.
                    --> If parity bits do not match, set o_error(1).
                    --> After doing parity check, goto STATE_STOP.
                    when STATE_PARITY =>
                    if(i_baud_x16 = '1') then
                        if(baud_count = 15) then
                            baud_count <= 0;
                            rx_data    <= q2_RX & rx_data(FRAME_WIDTH-1 downto 1);
                            STATE      <= STATE_STOP;
                            if(parity /= q2_RX) then
                                o_error(1) <= '1';
                            end if;
                        else
                            baud_count <= baud_count + 1;
                        end if;
                    end if;

				-- STATE_STOP:
				--> Look for stop bit, return to STATE_IDLE regardless of result.
                --> A stop bit is only valid if it is held for 8 sampling baud ticks.
				--> If stop bit is invalid, set o_error(0) and return to STATE_IDLE.
				--> If stop bit is valid, set output data and valid and return to STATE_IDLE.
					when STATE_STOP =>
						if(i_baud_x16 = '1') then

							if(baud_count = 15) then
								baud_count <= 0;
								STATE <= STATE_IDLE;
								if(q2_RX = '1') then
									o_valid <= '1';
                                    if(PARITY_EN=1) then
										o_dout <= rx_data(FRAME_WIDTH-2 downto 0);
									else
										o_dout <= rx_data(FRAME_WIDTH-1 downto 0);
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