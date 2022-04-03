-- uart_baudgen.vhd
--
-- A configurable UART baud rate generator.
-- Supports standard baud rates from 110 to 256,000 bps.
-- Expected F_CLK of i_clk should be <= 100MHz.
--
---------------------------- How to calculate DIVISOR --------------------------
-- Given system clock frequency is 50MHz and desired Baud Rate is 115,200 bps.
-- -> Set T_CLK = 25 ns
--
-- -> Set i_divisor for 16x Baud Rate:
--     DIVISOR_x16 = (50MHz / (115,200 * 16)) - 1 = 27.126736 rounded to 26.125
--     i_divisor   = 8'd27   
--
-- -> Set i_fra_adj to adjust for fractional part of DIVISOR_x16 (0.125 here)
--     0.125 = 1/8 <- Adjustment is made once every 8th o_baud_x16
--     i_fra_adj = 4'd8
--
--  A tick of o_baud on the 16th o_baud_x16 tick. Since o_baud_x16 has already
--  been adjusted for the fractional part of its divisor, no separate adjustment
--  is required for o_baud.
---------------------------------------------------------------------------------
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.math_real.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.ALL;
--
entity uart_baudgen is
generic(
	COUNTER_WIDTH : integer := 20 -- adjust accordingly for system clock 
);
port (
	i_clk      : in std_logic; -- system clock
	i_rstn     : in std_logic; -- synchronous active-low reset 
	--
	i_divisor  : in std_logic_vector (15 downto 0); -- integer part of DIVISOR_x16 (F_CLK / (Baud Rate * 16)) 
	i_fra_adj  : in std_logic_vector (3  downto 0); -- fractional adjustment for DIVISOR_x16
	--
	o_baud     : out std_logic; -- Baud Tick (TX)
	o_baud_x16 : out std_logic  -- 16x Baud Tick (RX)
);
end uart_baudgen;

--
architecture Behavioral of uart_baudgen is 
	-- counter for 16x baud rate tick gen 
	signal count_baudx16 : std_logic_vector (COUNTER_WIDTH-1 downto 0);
	signal baud_x16      : std_logic;

	-- 4-bit counter for 16x baud rate tick fractional adjustment
	signal count_fra_adj : std_logic_vector (3 downto 0);

	-- 4-bit counter for baud rate tick gen
	signal count_baud : std_logic_vector (3 downto 0);
begin

-- Process to generate 16x Baud Rate ticks w/ fractional adjustment
	BAUD_X16_GEN: process(i_clk) 
	begin
		if rising_edge(i_clk) then
			if (i_rstn = '0') then
				baud_x16      <= '0';
				count_baudx16 <= (others => '0');
				count_fra_adj <= (others => '0');
			else
				-- Count # of o_baud_x16 periods
				if (baud_x16 = '1') then
					if (count_fra_adj = i_fra_adj) then
						count_fra_adj <= (others => '0');
					else 
						count_fra_adj <= count_fra_adj + "1";
					end if;
				end if;

				-- Adjust for fractional part of DIVISOR_x16 by reducing the
				-- error through averaging of o_baud_x16 periods
				if (count_baudx16 = "0") then
					if (count_fra_adj = i_fra_adj) then -- adjustment made once every i_fra_adj clock periods
						count_baudx16 <= std_logic_vector(resize(unsigned(i_divisor), count_baudx16'length)) + "1";
					else 
						count_baudx16 <= std_logic_vector(resize(unsigned(i_divisor), count_baudx16'length));
					end if;
					baud_x16 <= '1';
				else 
					count_baudx16 <= count_baudx16 - "1";
					baud_x16 <= '0';
				end if;
				
			end if;
		end if;
	end process;
	o_baud_x16 <= baud_x16;

-- Process to generate a Baud Rate tick every 16 16x Baud Rate ticks
	BAUD_GEN: process(i_clk)
	begin
		if rising_edge(i_clk) then
			if (i_rstn = '0') then
				o_baud     <= '0';
				count_baud <= (others => '0');
			else 
				if (count_baudx16 = "0") then
					if(count_baud = 15) then -- assert a tick of o_baud every 16 o_baud_x16 periods
						count_baud <= (others => '0');
						o_baud     <= '1';
					else
						count_baud <= count_baud + "1";
						o_baud     <= '0';
					end if;	
				else 
					o_baud <= '0';
				end if;
			end if;
		end if;
	end process;

end Behavioral;