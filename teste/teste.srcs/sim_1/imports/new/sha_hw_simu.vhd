----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/25/2018 09:51:40 PM
-- Design Name: 
-- Module Name: frequency_divider_sim - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sha_hw_simu is
end sha_hw_simu;

architecture Stimulus of sha_hw_simu is
    signal s_clkIn, s_reset, s_start, s_done: STD_LOGIC;
    signal s_data_in2: STD_LOGIC_VECTOR(607 downto 0);
    signal s_data_out: STD_LOGIC_VECTOR(255 downto 0);
    signal s_i: STD_LOGIC_VECTOR(5 downto 0);

begin

    uut : entity work.sha_hw(Behavioral)
          port map(
                i_out => s_i,
                clk     => s_clkIn,
                rst     => s_reset,
                din => s_data_in2,
                data_out => s_data_out,
                start => s_start,
                done => s_done
                
          );
          
    clock_proc : process
    begin
        s_clkIn <= '0'; wait for 100 ns;
        s_clkIn <= '1'; wait for 100 ns;
    end process;
    
    sim_proc : process
    begin

        s_reset <= '1';
        
--        s_data_in <= x"746961676fffffff8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000028";
        s_data_in2 <= x"746961676f746961676f746961676f746961676f746961676f746961676f746961676f746961676f746961676f746961676f746961676f746961676f746961676f746961676f746961676f74";
        wait for 100 ns;
        
        s_reset <= '1';
        wait for 100 ns;
        s_reset <= '0';
        wait for 50ns;
        s_start <= '1';
        wait for 200 ns;
        s_start <= '0';
        wait for 100000 ns;
    
    end process;
end Stimulus;