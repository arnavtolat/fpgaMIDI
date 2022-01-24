----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/15/2021 08:04:10 PM
-- Design Name: 
-- Module Name: dds - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dds is
    Generic (STEP_SIZE : integer);
    Port ( clk_iport : in STD_LOGIC;
           count_en : in STD_LOGIC;
           count_oport : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) );
end dds;

architecture Behavioral of dds is
signal count : unsigned(14 downto 0) := (others => '0');

begin
increment: process(clk_iport, count)
begin
    if rising_edge(clk_iport) then
        if count_en = '1' then
            count <= count + STEP_SIZE;
        else
            count <= "110000000000000";
        end if;
    end if;
    count_oport <= '0' & std_logic_vector(count);
end process increment;

end Behavioral;
