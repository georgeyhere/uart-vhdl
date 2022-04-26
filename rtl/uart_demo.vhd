library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_demo is
port(
    i_clk  : in  std_logic;
    i_rstn : in  std_logic;

    -- UART interface
    i_RX   : in  std_logic;
    o_TX   : out std_logic;

    -- LEDs
    o_LED  : out std_logic_vector (7 downto 0)
);
end uart_demo;

architecture Behavioral of uart_demo is
    signal uart_tx_fifo_rst  : std_logic;
    signal uart_rx_fifo_rst  : std_logic;

    signal uart_tx_wr    : std_logic;
    signal uart_tx_din   : std_logic_vector (7 downto 0);
    signal uart_tx_full  : std_logic;
    signal uart_tx_almost_full : std_logic;

    signal rxState       : std_logic;
    signal uart_rx_rd    : std_logic;
    signal uart_rx_dout  : std_logic_vector (7 downto 0);
    signal uart_rx_empty : std_logic;
    signal rxData        : std_logic_vector (7 downto 0);

    signal romIndex   : integer range 0 to 31;
    signal romData    : std_logic_vector (7 downto 0);

    signal LED : std_logic_vector(7 downto 0);

begin

    uart_tx_fifo_rst <= not(i_rstn);
    uart_rx_fifo_rst <= not(i_rstn);

    SEND_DATA: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if(i_rstn = '0') then
                uart_tx_wr <= '0';
                romIndex  <= 0;
            else
                if(uart_tx_almost_full = '0') then
                    uart_tx_wr  <= '1';
                    uart_tx_din <= romData;
                    --
                    if(romIndex = 31) then
                        romIndex <= 0;
                    else 
                        romIndex <= romIndex + 1;
                    end if;
                else
                    uart_tx_wr  <= '0';
                end if;
            end if;
        end if;
    end process;

    RECEIVE_DATA: process(i_clk) 
    begin
        if rising_edge(i_clk) then
            if(i_rstn = '0') then
                rxState    <= '0';
                rxData     <= (others => '0');
                uart_rx_rd <= '0';
            else
                case rxState is
                    when '0' =>
                        if(uart_rx_empty = '0') then
                            uart_rx_rd <= '1';
                            rxData     <= uart_rx_dout;
                            rxState    <= '1';
                        end if;

                    when '1' =>
                        uart_rx_rd <= '0';
                        rxState    <= '0';

                    when others =>
                        uart_rx_rd <= '0';
                        rxState    <= '0';
                end case;
            end if;
        end if;
    end process;
    

    SET_LEDS: process(i_clk) 
    begin
        if rising_edge (i_clk) then
            if(i_rstn = '0') then
                LED <= (others => '0');
            else
                case rxData is
                    when "00110000" =>
                        LED(0) <= not(LED(0));
                    when "00110001" =>
                        LED(1) <= not(LED(1));
                    when "00110010" =>
                        LED(2) <= not(LED(2));
                    when "00110011" =>
                        LED(3) <= not(LED(3));
                    when "00110100" =>
                        LED(4) <= not(LED(4));
                    when "00110101" =>
                        LED(5) <= not(LED(5));
                    when "00110110" =>
                        LED(6) <= not(LED(6));
                    when "00110111" =>
                        LED(7) <= not(LED(7));
                    when others =>
                        LED <= (others => '0');
                end case;
            end if;
        end if;
    end process;
    o_LED <= LED;


    charRom_i : entity work.charRom (Behavioral)
    GENERIC MAP (
    ROM_ADDR_WIDTH => 5
    )
    PORT MAP (
    i_clk  => i_clk,
    i_addr => romIndex,
    o_dout => romData
    );

    uart_i : entity work.uart (Behavioral)
    GENERIC MAP (
    DATA_WIDTH            => 8,
    TX_PARITY_EN          => 0,
    RX_PARITY_EN          => 0,
    BAUDGEN_COUNTER_WIDTH => 20,
    FIFO_ADDR_WIDTH       => 4
    )
    PORT MAP (
    i_clk  => i_clk,
    i_rstn => i_rstn,
    --
    i_divisor_x16     => 54,
    i_fra_adj_x16     => 5,
    --    
    i_tx_wr           => uart_tx_wr,
    i_tx_data         => romData,
    o_tx_full         => uart_tx_full,
    o_tx_almost_full  => uart_tx_almost_full,
    o_tx_fill         => open,
    i_tx_fifo_rst     => uart_tx_fifo_rst,
    --    
    i_rx_rd           => uart_rx_rd,
    o_rx_data         => uart_rx_dout,
    o_rx_empty        => uart_rx_empty,
    o_rx_fill         => open,
    i_rx_fifo_rst     => uart_rx_fifo_rst,
    --
    i_error_rst       => '0',
    o_uart_rx_error   => open,
    o_fifo_tx_overrun => open,
    o_fifo_rx_overrun => open,
    --
    i_RX => i_RX,
    o_TX => o_TX
    );


end Behavioral;