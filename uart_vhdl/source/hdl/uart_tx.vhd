-- uart_tx.vhd
--
-- UART TX w/ parameterizable data width and optional parity bit. Only supports one stop bit.	
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.math_real.ALL;
use IEEE.std_logic_unsigned.all;
--use IEEE.NO_ERRORS.ALL;
--
entity uart_tx is 
generic (
	DATA_WIDTH : integer := 8; -- # of data bits in frame
	PARITY_EN  : integer := 0  -- '1' to enable parity bit, else '0'
);
port ( 
	i_clk         : in  std_logic; -- input clock
	i_rstn        : in  std_logic; -- active-low reset

    -- parity bit config
    i_parity_cfg  : in  std_logic; -- '1' for odd parity, '0' for even

    -- baud gen interface
	i_baud_x16    : in  std_logic; -- 16x baud tick

	-- TX data and valid
	i_din         : in  std_logic_vector (DATA_WIDTH-1 downto 0);  
	i_valid       : in  std_logic;

	-- Status 
	o_busy        : out std_logic; -- '1' when transaction in progress, '0' at idle

	-- UART TX pin
	o_TX          : out std_logic
);

end uart_tx;

--
architecture Behavioral of uart_tx is
	--
	constant FRAME_WIDTH     : integer := DATA_WIDTH + 2 + PARITY_EN;
	constant log_FRAME_WIDTH : integer := integer(ceil(log2(real(FRAME_WIDTH-1))));

	-- FSM state enumeration w/ one-hot encoding
	type t_fsm_state is (STATE_IDLE, STATE_ACTIVE);
	attribute syn_enum_encoding : string;
	attribute syn_enum_encoding of t_fsm_state : type is "onehot, safe";

	-- FSM register
	signal STATE : t_fsm_state;
    signal fsm_busy : std_logic;
	
	-- Counter to count number of 16x baud ticks 
	signal tick_count : integer range 0 to 16;
	
	-- Bit counter; used to keep track of # of bits to send in frame
	signal tx_count : integer range 0 to FRAME_WIDTH-1;

	-- TX output shift register
	signal tx_queue : std_logic_vector (FRAME_WIDTH-1 downto 0);
	
	-- parity bit 
    signal parity_calc : std_logic_vector (DATA_WIDTH downto 0);
	signal parity : std_logic;
begin

-- Combinatorial parity bit generator 
	--PARITY_GEN: process(i_din) 
    parity_calc(0) <= i_parity_cfg;
    PARITY_GEN: for i in 0 to (DATA_WIDTH-1) generate
        parity_calc(i+1) <= parity_calc(i) xor i_din(i);
    end generate;
    parity <= parity_calc(DATA_WIDTH);

-- Sync FSM process
	FSM_SYNC: process(i_clk) begin
		if rising_edge(i_clk) then
			if(i_rstn = '0') then
				STATE      <= STATE_IDLE;
				fsm_busy   <= '0';
				tx_queue   <= (others => '1');
				tx_count   <= 0;
				tick_count <= 0;
			else
				case STATE is
				
				-- STATE_IDLE:
				-- When i_valid is asserted, start a transmission.
				--  > load tx_queue with start, data, parity, and stop bits (LSB first)
				--  > set status flags
				--  > set tx_count to number of bits to send
				--  > reset the tick counter 
				--  > goto STATE_ACTIVE
					when STATE_IDLE =>
						if (i_valid = '1') then
							if (PARITY_EN = 1) then
                                tx_queue <= '1' & parity & i_din & '0';
							else
                            tx_queue   <= '1' & i_din & '0';
							end if;
							fsm_busy   <= '1';
							tx_count   <= FRAME_WIDTH-1;
							tick_count <= 0;
							STATE      <= STATE_ACTIVE;
						else
                            fsm_busy  <= '0';
						end if;

				-- STATE_ACTIVE:
				-- > Right shift out tx_queue one bit at a time until tx_count hits 0.
				-- > When tx_count hits 0, goto STATE_IDLE.
					when STATE_ACTIVE =>
						if (tick_count = 16) then
							if (tx_count = 0) then
								tx_queue <= (others => '1');
								STATE    <= STATE_IDLE;
							else
								tx_queue <= '1' & tx_queue(FRAME_WIDTH-1 downto 1);
                                tx_count <= tx_count - 1;
 							end if;
							tick_count <= 0;
						else 
							if(i_baud_x16 = '1') then 
								tick_count <= tick_count + 1;
							end if;
 						end if;
				end case;
			end if;
		end if;
	end process;

    -- busy flag is set whenever valid data is received or transmission in progress
    o_busy <= i_valid or fsm_busy;

	-- TX is always the LSB of the shift register
	o_TX <= tx_queue(0);

end Behavioral;