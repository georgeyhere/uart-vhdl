library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart is 
generic (
    DATA_WIDTH            : integer := 8;  -- UART data width
    TX_PARITY_EN          : integer := 0;  -- '1' enables odd parity bit gen 
    RX_PARITY_EN          : integer := 0;  -- '1' enables odd parity bit checking
    BAUDGEN_COUNTER_WIDTH : integer := 20; -- counter width for baud gen clock divider; adjust based on i_clk
    FIFO_ADDR_WIDTH       : integer := 8   -- TX and RX FIFO address width; determines FIFO depths
);
port (
    -- SYSTEM
    i_clk             : in  std_logic;                                -- system clock
    i_rstn            : in  std_logic;                                -- synchronous active-low reset
    
    -- BAUD GEN CONFIG
    i_divisor         : in  std_logic_vector (15 downto 0);           -- 16x f clock divider divisor
    i_fra_adj         : in  std_logic_vector (3  downto 0);           -- fractional adjustment bits
    
    -- TX FIFO INTERFACE
    i_tx_wr           : in  std_logic;                                -- tx fifo write enable
    i_tx_data         : in  std_logic_vector (DATA_WIDTH-1 downto 0); -- tx fifo data in 
    o_tx_full         : out std_logic;                                -- tx fifo full flag
    o_tx_fill         : out integer range 0 to FIFO_ADDR_WIDTH**2;    -- tx fifo fill level
    i_tx_fifo_rst     : in  std_logic;                                -- tx fifo reset, active high

    -- RX FIFO INTERFACE
    i_rx_rd           : in  std_logic;                                -- rx fifo read enable
    o_rx_data         : out std_logic_vector (DATA_WIDTH-1 downto 0); -- rx data out
    o_rx_empty        : out std_logic;                                -- rx fifo empty flag
    o_rx_fill         : out unsigned (FIFO_ADDR_WIDTH downto 0);      -- rx fifo fill level
    i_rx_fifo_rst     : in  std_logic;                                -- rx fifo reset, active high

    -- STATUS 
    i_error_rst       : in  std_logic;                                -- resets all error registers, active high
    o_uart_rx_error   : out std_logic_vector (1 downto 0);            -- (0): missed stop bit; (1) parity failed
    o_fifo_tx_overrun : out unsigned (3 downto 0);                    -- counts # of TX FIFO overruns
    o_fifo_rx_overrun : out unsigned (3 downto 0);                    -- counts # of RX FIFO overruns

    -- UART INTERFACE
    i_RX              : in  std_logic; 
    o_TX              : out std_logic
);

end uart;

architecture Behavioral of uart is 
    -- Constants
    constant FIFO_DEPTH : integer := 2**FIFO_ADDR_WIDTH;

    -- Baud Ticks
    signal baud_tick            : std_logic; 
    signal baud_tick_x16        : std_logic; 

    -- TX UART
    signal uart_tx_busy         : std_logic;                               

    -- RX UART
    signal uart_rx_error        : std_logic_vector (1 downto 0);            

    -- TX FIFO to TX UART
    signal fifo_tx_rstn         : std_logic;
    signal fifo_tx_dout         : std_logic_vector (DATA_WIDTH-1 downto 0); 
    signal fifo_tx_rd           : std_logic := '0';                         
    signal fifo_tx_almost_empty : std_logic;                                
    signal fifo_tx_overrun      : unsigned (3 downto 0);                    
    signal fifo_tx_error        : std_logic;                                

    -- RX UART to RX FIFO
    signal fifo_rx_rstn         : std_logic;
    signal fifo_rx_din          : std_logic_vector (DATA_WIDTH-1 downto 0);  
    signal fifo_rx_wr           : std_logic := '0';                            
    signal fifo_rx_overrun      : unsigned (3 downto 0);                     
    signal fifo_rx_error        : std_logic;                                 
begin

    -- FIFO ACTIVE LOW RESETS
    fifo_tx_rstn <= i_rstn and not(i_tx_fifo_rst);
    fifo_rx_rstn <= i_rstn and not(i_rx_fifo_rst);

    -- TX FIFO to TX UART
    --> Whenever there is data present in the TX FIFO, read from it.
    --> fifo_tx_rd also serves as the input valid for the TX UART so a 
    --  transaction will also be started.
    TX_FIFO_TO_UART: process(i_clk) 
    begin
        if rising_edge(i_clk) then
            if(i_rstn = '0') then
                fifo_tx_rd <= '0';
            else 
                if(fifo_tx_almost_empty = '0' and uart_tx_busy = '0') then
                    fifo_tx_rd <= '1';
                else
                    fifo_tx_rd <= '0';
                end if;
            end if;
        end if;
    end process;

    -- TX and RX FIFO Overrun Counter
    --> Count number of TX and RX FIFO overruns.
    OVERRUN_GEN: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if(i_rstn = '0' or i_error_rst = '1') then
                fifo_rx_overrun <= (others => '0');
                fifo_tx_overrun <= (others => '0'); 
            else
                if(fifo_tx_error = '1' and fifo_tx_overrun < 16) then
                    fifo_tx_overrun <= fifo_tx_overrun + 1;
                end if;
                if(fifo_rx_error = '1' and fifo_rx_overrun < 16) then
                    fifo_rx_overrun <= fifo_rx_overrun + 1;
                end if;
            end if;
        end if;
    end process;
    o_fifo_tx_overrun <= fifo_tx_overrun;
    o_fifo_rx_overrun <= fifo_rx_overrun;
    o_uart_rx_error   <= uart_rx_error;

-- ENTITY INSTANTIATION

    -- Baud Generator
    --> Generates baud and 16x baud ticks for TX and RX UARTs.
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

    -- TX FIFO
    --> Serves as an input buffer for TX UART
    --> Writes are driven by top level inputs.
    --> Reads are asserted whenever not empty and TX UART is not busy.
    fifo_tx : entity work.fifo_sync (Behavioral)
    GENERIC MAP (
    FIFO_DATA_WIDTH => DATA_WIDTH,
    FIFO_ADDR_WIDTH => FIFO_ADDR_WIDTH
    )
    PORT MAP (
    i_clk          => i_clk,
    i_rstn         => fifo_tx_rstn,
    --     
    i_wr           => i_tx_wr,              -- FIFO write enable, driven by top level input
    i_din          => i_tx_data,            -- FIFO write data from top level input
    --            
    i_rd           => fifo_tx_rd,           -- FIFO read enable
    o_dout         => fifo_tx_dout,         -- FIFO read data out, goes directly to UART TX
    --            
    o_empty        => open,                 -- empty flag
    o_full         => o_tx_full,            -- full flag
    o_almost_empty => fifo_tx_almost_empty, -- almost empty flag 
    o_almost_full  => open,                 -- unused
    o_fill         => o_tx_fill,            -- fill level
    o_overrun      => fifo_tx_error         -- '1' indicates overrun error
    );

    -- UART TX Module
    --> TX data provided by TX UART whenever data is present and UART TX is not busy.
    uart_tx : entity work.uart_tx (Behavioral)
    GENERIC MAP (
    DATA_WIDTH => DATA_WIDTH,
    PARITY_EN  => TX_PARITY_EN
    )
    PORT MAP (
    i_clk    => i_clk,
    i_rstn   => i_rstn,
    i_baud   => baud_tick,    -- Baud tick
    --
    i_din    => fifo_tx_dout, -- TX data in from TX FIFO
    i_valid  => fifo_tx_rd,   -- Valid on TX FIFO read
    --
    o_busy   => uart_tx_busy  -- asserted when a transaction is in progress
    );

    -- RX FIFO
    --> Writes driven directly by UART RX whenever it has valid data out.
    --> Overruns are counted in process OVERRUN_GEN.
    fifo_rx : entity work.fifo_sync (Behavioral)
    GENERIC MAP (
    FIFO_DATA_WIDTH => DATA_WIDTH,
    FIFO_ADDR_WIDTH => FIFO_ADDR_WIDTH
    )
    PORT MAP (
    i_clk          => i_clk,
    i_rstn         => fifo_rx_rstn,
    --       
    i_wr           => fifo_rx_wr,   -- UART RX data out valid
    i_din          => fifo_rx_din,  -- UART RX data out
    --       
    i_rd           => i_rx_rd,      -- driven by top level inputs
    o_dout         => o_rx_data,    -- top level RX data out
    --
    o_empty        => o_rx_empty,   -- empty flag
    o_full         => open,         -- unused 
    o_almost_empty => open,         -- unused
    o_almost_full  => open,         -- unused
    o_fill         => open,         -- unused
    o_overrun      => fifo_rx_error -- '1' indiciates overrun error
    );

    -- UART RX Module
    --> Writes data out directly to RX FIFO regardless of its fill level.
    --> Overruns are counted in process OVERRUN_GEN.
    uart_rx : entity work.uart_rx (Behavioral)
    GENERIC MAP (
    DATA_WIDTH => DATA_WIDTH,
    PARITY_EN  => RX_PARITY_EN
    )
    PORT MAP (
    i_clk      => i_clk,         
    i_rstn     => i_rstn,        
    i_baud_x16 => baud_tick_x16, -- 16x frequency baud tick for sampling
    --
    o_dout     => fifo_rx_din,   -- RX data out, written directly to RX FIFO
    o_valid    => fifo_rx_wr,    -- RX FIFO write enable
    --
    o_error    => uart_rx_error, -- (0): missing stop bit | (1): odd parity fail
    i_RX       => i_RX
    );
    

end Behavioral;