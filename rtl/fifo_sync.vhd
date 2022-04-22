library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
--
entity fifo_sync is
generic (
	FIFO_DATA_WIDTH : integer := 8;
	FIFO_ADDR_WIDTH : integer := 8
);
port (
	i_clk          : in  std_logic;
	i_rstn         : in  std_logic;
	
    -- Write Interface
    i_wr           : in  std_logic;
    i_din          : in  std_logic_vector (FIFO_DATA_WIDTH-1  downto 0);
    
    -- Read Interface
    i_rd           : in  std_logic;
    o_dout         : out std_logic_vector (FIFO_DATA_WIDTH-1 downto 0);

    -- Status Flags
    o_almost_empty : out std_logic;
    o_empty        : out std_logic;
    o_almost_full  : out std_logic;
    o_full         : out std_logic;
    o_fill         : out integer range 0 to 2**FIFO_ADDR_WIDTH;
    o_overrun      : out std_logic
);
end fifo_sync;

architecture Behavioral of fifo_sync is
    constant FIFO_DEPTH : integer := 2**FIFO_ADDR_WIDTH;

    -- infer block memory
    type t_FIFO_MEM is array(0 to FIFO_DEPTH-1) of std_logic_vector(FIFO_DATA_WIDTH-1 downto 0);
    signal FIFO_MEM : t_FIFO_MEM := (others => (others => '0'));

    -- read and write pointers
    signal wrPtr : integer range 0 to FIFO_DEPTH-1 := 0;
    signal rdPtr : integer range 0 to FIFO_DEPTH-1 := 0;

    -- local fill count
    signal fillCount : integer range 0 to FIFO_DEPTH := 0;

    -- local full and empty flags
    signal full  : std_logic := '0';
    signal empty : std_logic := '1';

    --
    signal overrun_next_wr : std_logic := '0';

begin

    -- Read and Write pointer sync logic
    -- -> increment pointers on read or write
    -- -> reset pointers when they hit depth
    PTR_GEN: process (i_clk) 
    begin
        if rising_edge(i_clk) then
            if(i_rstn = '0') then
                wrPtr   <= 0;
                rdPtr   <= 0;
            else 
            --> Write Logic
                if(i_wr = '1') then
                    -- write pointer
                    if(wrPtr < FIFO_DEPTH-1) then
                        wrPtr <= wrPtr + 1;
                    else  
                        wrPtr <= 0;
                    end if;
                end if;
            
            --> Read Logic
                if(i_rd = '1') then
                    -- read pointer
                    if(rdPtr < FIFO_DEPTH-1) then
                        rdPtr <= rdPtr + 1;
                    else
                        rdPtr <= 0;
                    end if;
                end if;

            end if;
        end if;
    end process;

    -- FIFO write sync logic
    -- -> write to memory pointed to by wrPtr when i_wr is asserted
    MEM_WRITE: process (i_clk) 
    begin
        if rising_edge(i_clk) then
            if(i_wr = '1') then
                FIFO_MEM(wrPtr) <= i_din;
            end if;
        end if;
    end process;

    -- FIFO fill level sync logic
    -- -> decrement when there is a read but no write
    -- -> increment when there is a write but no read
    FILL_COUNT: process (i_clk, i_wr, i_rd) 
        variable v_status : std_logic_vector (1 downto 0);
    begin
        v_status := i_wr & i_rd;
        if rising_edge(i_clk) then
            if(i_rstn = '0') then
                fillCount <= 0;
            else 
                case(v_status) is
                    
                    -- read but no write
                    when "01" =>
                        if(fillCount > 0) then
                            fillCount <= fillCount-1;
                        else
                            fillCount <= 0;
                        end if;

                    -- write but no read 
                    when "10" =>
                        if(fillCount < FIFO_DEPTH-1) then
                            fillCount <= fillCount+1;
                        else
                            fillCount <= FIFO_DEPTH-1;
                        end if;

                    when others =>
                        fillCount <= fillCount;

                end case;
            end if;
        end if;
    end process;

    OVERRUN: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if(i_rstn = '0') then
                overrun_next_wr <= '0';
            else    
                if(i_rd = '1') then
                    overrun_next_wr <= overrun_next_wr and i_wr;
                elsif(fillCount = FIFO_DEPTH-1) then
                    overrun_next_wr <= '1';
                end if;
            end if;
        end if;
    end process;

    -- combinatorial logic for data out
    o_dout  <= FIFO_MEM(rdPtr);

    -- combinatorial logic for status flags
    o_fill         <= fillCount;
    o_full         <= '1' when (fillCount = FIFO_DEPTH-1) else '0';
    o_empty        <= '1' when (fillCount = 0) else '0';
    o_almost_full  <= '1' when (fillCount >= FIFO_DEPTH-2) else '0';
    o_almost_empty <= '1' when (fillCount <= 1) else '0';
    o_overrun      <= '1' when (overrun_next_wr = '1' and i_wr = '1') else '0';

end Behavioral;
