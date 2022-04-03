library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity uart is
generic (
	DATA_WIDTH            : integer := 8;
	PARITY_EN             : integer := 0;
	BAUDGEN_COUNTER_WIDTH : integer := 20
);
port (
	-- SYSTEM
	i_clk       : in  std_logic;
	i_rstn      : in  std_logic;
	
	-- BAUD GEN CONFIG
	i_divisor   : in  std_logic_vector (15 downto 0);
	i_fra_adj   : in  std_logic_vector (3  downto 0);
	
	-- TX DATA INTERFACE
	i_din       : in  std_logic_vector (DATA_WIDTH-1 downto 0);
	i_valid     : in  std_logic;

	-- RX DATA INTERFACE
	--o_dout      : out std_logic_vector (DATA_WIDTH-1 downto 0);
	--o_valid     : out std_logic;

	-- CONTROL AND STATUS
	i_parity_en : in  std_logic;
	o_busy      : out std_logic;

	-- UART INTERFACE
	--i_RX        : in  std_logic;
	o_TX        : out std_logic
);

end uart;

architecture Behavioral of uart is 
	-- Baud Ticks
	signal baud_tick     : std_logic; -- TX
	signal baud_tick_x16 : std_logic; -- RX sampling (16x)

begin

-- ENTITY INSTANTIATION
	baudGen : entity work.uart_baudgen (Behavioral)
	GENERIC MAP (
	COUNTER_WIDTH => BAUDGEN_COUNTER_WIDTH
	)
	PORT MAP (
	i_clk      => i_clk,
	i_rstn     => i_rstn,
	--
	i_divisor  => i_divisor,
	i_fra_adj  => i_fra_adj,
	--
	o_baud     => baud_tick,
	o_baud_x16 => baud_tick_x16
	);

	uart_tx : entity work.uart_tx (Behavioral)
	PORT MAP (
	i_clk    => i_clk,
	i_rstn   => i_rstn,
	i_baud   => baud_tick,
	--
	i_din    => i_din,
	i_valid  => i_valid,
	--
	i_parity => i_parity_en,
	o_busy   => o_busy
	);

end Behavioral;