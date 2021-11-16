--=============================================================
--Ben Dobbins
--ES31/CS56
--Final 
--Your name goes here: Arnav Tolat & Tyler Vergho 
--=============================================================

--=============================================================
--Library Declarations
--=============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;			-- needed for arithmetic
use ieee.math_real.all;				-- needed for automatic register sizing
library UNISIM;						-- needed for the BUFG component
use UNISIM.Vcomponents.ALL;

--=============================================================
--Shell Entitity Declarations
--=============================================================
entity d_to_a is
	generic(
		N_SHIFTS 				: integer);			--Generics are parameters that can be set in the top level
	port(											--that can be treated as constants in this level.
		clk_iport				: in  std_logic;	--1 MHz serial clock
    	dac_data_iport			: in std_logic_vector(15 downto 0);
		
		take_sample_iport 		: in  std_logic;	--controller signals
		spi_cs_oport			: out std_logic;

		dac_data_oport			: out std_logic);
end d_to_a; 

--=============================================================
--Architecture Declaration
--=============================================================
architecture Behavioral of d_to_a is
--=============================================================
--Local Signal Declaration
--=============================================================
--Your controller signal declarations go here:

signal count: unsigned(5 downto 0) := (others => '0');
signal tc: std_logic := '0';
signal shift_enable: std_logic := '0';

type state_type is (idle, shift);
signal curr_state, next_state: state_type;
signal filtered : std_logic_vector(15 downto 0) := (others => '0');

begin
--=============================================================
--Controller:
--=============================================================
--Your controller goes here
timer: process(clk_iport,count) 
begin
	if rising_edge(clk_iport) then
		if (shift_enable='1') then
			count <= count+1;
		else
		    count <= (others => '0');
		end if;
		
		if tc = '1' then
		  count <= (others => '0');
		end if;
	end if;
			
	if (count >= N_SHIFTS) then 
        tc <= '1';
    else
        tc <= '0';
    end if;
end process timer;
		
FSM_comb: process(curr_state, tc, take_sample_iport) 
begin 
    next_state <= curr_state;
    spi_cs_oport <= '1';
    shift_enable <= '0';
          
    -- states and transitions, as reflected in state diagram
    case curr_state is
        when idle => -- idle starting state, which remains until take sample is high
            if take_sample_iport = '1' then -- when take sample is high transition to shift state
                shift_enable <= '1';
                next_state <= shift;
            end if;

        when shift => -- shifting state, remains until timeout occurs
            shift_enable <= '1';
            spi_cs_oport <= '0'; --goes low for shift, but returns high for other states since its default value is 1
            if tc = '1' then  
                next_state <= idle; -- transition to idle after TC
            end if;
    end case;
end process FSM_comb;
    
FSM_update: process(clk_iport) -- clocked update process 
begin
    if rising_edge(clk_iport) then
        curr_state <= next_state; -- rising edge of clock, current state updates
    end if;
end process FSM_update;	
--=============================================================
--Datapath:
--=============================================================
shift_register: process(clk_iport) 
begin
	if rising_edge(clk_iport) then
	   if to_integer(N_SHIFTS-1-count) >= 0 and to_integer(N_SHIFTS-1-count) <= 15 then
	       dac_data_oport <= filtered(to_integer(N_SHIFTS-1-count));
	   else
	       dac_data_oport <= '0';
	   end if;
    end if;
end process shift_register;

filter: process (dac_data_iport)
begin
    filtered <= '0' & dac_data_iport(15 downto 1);
end process filter;

end Behavioral; 