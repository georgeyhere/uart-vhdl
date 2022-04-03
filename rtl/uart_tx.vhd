-- uart_tx.vhd
--
-- UART TX w/ parameterizable data width and optional parity bit.
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.math_real.ALL;
use IEEE.std_logic_unsigned.all;
--
entity uart_tx is 
generic (
	DATA_WIDTH : integer := 8;
	PARITY_EN  : integer := 0
);
port ( 
	i_clk    : in  std_logic; -- input clock
	i_rstn   : in  std_logic; -- active-low reset
	i_baud   : in  std_logic; -- baud tick
	
	-- TX data and valid
	i_din    : in  std_logic_vector (DATA_WIDTH-1 downto 0);  
	i_valid  : in  std_logic;

	-- Status and Config
	i_parity : in  std_logic; -- '1' for parity bit, '0' for no parity bit
	o_busy   : out std_logic; -- '1' when transaction in progress, '0' at idle

	-- UART pins
	o_TX     : out std_logic
);

end uart_tx;

--
architecture Behavioral of uart_tx is
	--
	constant FRAME_WIDTH     : integer := DATA_WIDTH + 1 + PARITY_EN;
	constant log_FRAME_WIDTH : integer := integer(ceil(log2(real(FRAME_WIDTH-1))));

	-- FSM state enumeration w/ one-hot encoding
	type t_fsm_state is (STATE_IDLE, STATE_ACTIVE);
	attribute syn_encoding : string;
	attribute syn_encoding of t_fsm_state : type is "onehot, safe";

	-- FSM register
	signal STATE : t_fsm_state;
	
	-- Bit counter; used to keep track of # of bits to send in frame
	signal tx_count : std_logic_vector (log_FRAME_WIDTH-1 downto 0);
	
	-- TX output shift register
	signal tx_queue : std_logic_vector (FRAME_WIDTH-1 downto 0);
	
	-- parity bit 
	signal parity : std_logic;
begin

-- Combinatorial parity bit generator 
	PARITY_GEN: process(i_din) 
	variable v_parity : std_logic;
	begin
		for i in i_din'range loop
			v_parity := v_parity xor i_din(i);
		end loop;
		parity <= v_parity;
	end process;

-- Sync FSM process
	FSM_SYNC: process(i_clk) 
	begin
		if rising_edge(i_clk) then
			if(i_rstn = '0') then
				STATE    <= STATE_IDLE;
				o_busy   <= '0';
				tx_queue <= (others => '1');
				tx_count <= (others => '0');
			else
				case STATE is
				
				-- STATE_IDLE:
				-- When i_valid is asserted, start a transmission.
				--  > load tx_queue with start, data, parity, and stop bits (MSB first)
				--  > set status flags
				--  > set tx_count to number of bits to send
				--  > goto STATE_ACTIVE
					when STATE_IDLE =>
						if (i_valid = '1') then
							if (i_parity = '1') then
								tx_queue <= '0' & i_din & parity & '1';
							else
								tx_queue <= '0' & i_din & '1';
							end if;
							o_busy   <= '1';
							tx_count <= std_logic_vector(to_unsigned(FRAME_WIDTH-1, tx_count'length));
							STATE    <= STATE_ACTIVE;
						else
							o_busy <= '0';
						end if;

				-- STATE_ACTIVE:
				-- Shift out tx_queue one bit at a time until tx_count hits 0.
				-- When tx_count hits 0, goto STATE_IDLE.
					when STATE_ACTIVE =>
						if (i_baud = '1') then
							if (tx_count = "0") then
								tx_queue <= (others => '1');
								STATE    <= STATE_IDLE;
							else
								tx_queue <= tx_queue(FRAME_WIDTH-2 downto 0) & '1';
								tx_count <= tx_count - "1";
 							end if;
 						end if;

				end case;
			end if;
		end if;
	end process;

	-- TX is always the MSB of the shift register
	o_TX <= tx_queue(FRAME_WIDTH-1);

end Behavioral;