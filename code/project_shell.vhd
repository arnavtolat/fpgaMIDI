----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/17/2021 03:19:18 PM
-- Design Name: 
-- Module Name: project_shell - Behavioral
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

entity project_shell is
port (
    clk_iport_100MHz 	: in  std_logic;
    midi_iport : in std_logic;
    spi_cs_oport		: out std_logic;
    spi_sclk_oport		: out std_logic;
    spi_data_oport : out std_logic;
    seg_oport			: out std_logic_vector(0 to 6);			--segment control
	dp_oport			: out std_logic;						--decimal point control
	an_oport			: out std_logic_vector(3 downto 0)  	--digit control
);
end project_shell;

architecture Behavioral of project_shell is
component clk_wiz_0 is
  Port ( 
    clk_out1 : out STD_LOGIC;
    reset : in STD_LOGIC;
    locked : out STD_LOGIC;
    clk_in1 : in STD_LOGIC
  );
end component;

component midi_keyboard is
    Generic (max_notes : integer);
    Port ( data_iport : in STD_LOGIC;
           clk_24mHz : in STD_LOGIC;
           notes_oport : out STD_LOGIC_VECTOR(0 to max_notes) := (others => '0'));
end component;

component tick_generator is
	generic (
	   FREQUENCY_DIVIDER_RATIO : integer);
	port (
		system_clk_iport : in  std_logic;
		tick_oport		 : out std_logic);
end component;

component d_to_a is
	generic(
		N_SHIFTS 			: integer);
	port(											--that can be treated as constants in this level.
		clk_iport				: in  std_logic;	--1 MHz serial clock
    	dac_data_iport			: in std_logic_vector(15 downto 0);
		
		take_sample_iport 		: in  std_logic;	--controller signals
		spi_cs_oport			: out std_logic;

		dac_data_oport			: out std_logic);
end component;

component synthesizer is
    Generic ( max_notes : integer);
    Port ( take_sample : in STD_LOGIC;
           notes_on: in STD_LOGIC_VECTOR(0 to max_notes);
           note_out : out STD_LOGIC_VECTOR(15 DOWNTO 0);
           clk_24mHz : in STD_LOGIC
           );
end component;

component mux7seg is
    Port ( clk_iport 	: in  std_logic;						-- runs on a fast (1 MHz or so) clock
	       y3_iport 	: in  std_logic_vector (3 downto 0);	-- digits
		   y2_iport 	: in  std_logic_vector (3 downto 0);	-- digits
		   y1_iport		: in  std_logic_vector (3 downto 0);	-- digits
           y0_iport 	: in  std_logic_vector (3 downto 0);	-- digits
           dp_set_iport : in  std_logic_vector(3 downto 0);     -- decimal points
		   
           seg_oport 	: out std_logic_vector(0 to 6);			-- segments (a...g)
           dp_oport 	: out std_logic;						-- decimal point
           an_oport 	: out std_logic_vector (3 downto 0) );	-- anodes
end component;

constant max_notes : integer := 87;
signal clk_24mHz : std_logic := '0';
signal take_sample : std_logic := '0';
signal note : std_logic_vector(15 downto 0) := (others => '0'); -- synthesizer output, overall note being played   
signal locked : std_logic := '0'; -- timing
signal switches_actual, switches_filtered, switches_old : std_logic_vector(0 to max_notes) := (others => '0');

signal y3: std_logic_vector(3 downto 0) := (others => '0');
signal y2: std_logic_vector(3 downto 0) := (others => '0');
signal y1: std_logic_vector(3 downto 0) := (others => '0');
signal y0: std_logic_vector(3 downto 0) := (others => '0');
signal note_out_code : std_logic_vector(15 downto 0) := (others => '0'); 

begin

clocking: clk_wiz_0
port map(
	clk_in1 => clk_iport_100MHz,
	reset => '0',
	clk_out1 => clk_24mHz,
	locked => locked
);

tick_generation: tick_generator
generic map(
	FREQUENCY_DIVIDER_RATIO => 500)
port map( 
	system_clk_iport 	=> clk_24mHz,
	tick_oport			=> take_sample);

converter: d_to_a
generic map ( N_SHIFTS => 16 )
port map (
    clk_iport => clk_24mHz,
    dac_data_iport => note,
    take_sample_iport => take_sample,
    spi_cs_oport => spi_cs_oport,
    dac_data_oport => spi_data_oport
);

 
spi_sclk_oport <= clk_24mHz;

synth: synthesizer
generic map (max_notes => max_notes)
port map (
    take_sample => take_sample,
    notes_on => switches_filtered,
    note_out => note,
    clk_24mHz => clk_24mHz
);

midi: midi_keyboard
generic map (max_notes => max_notes)
port map (
    data_iport => midi_iport,
    notes_oport => switches_actual,
    clk_24mHz => clk_24mHz
);

note_off_clock: process(clk_24mHz)
begin
    if rising_edge(clk_24mHz) then
        switches_old <= switches_filtered;
    end if;
end process note_off_clock;

-- only stop playing the notes when the overall amplitude < 128
-- gets rid of the clicking sound when the note terminates
note_off_filter: process(switches_actual, note, switches_old)
begin
    switches_filtered <= switches_old;
    
    if unsigned(switches_actual) = 0 then
        if unsigned(note(15 downto 8)) = 0 then
            switches_filtered <= switches_actual;
        end if;
    else
        switches_filtered <= switches_actual;
    end if;
end process note_off_filter;

-- correlates keys being pressed with the code on the display
set_note_out: process (switches_actual)
begin
    note_out_code <= (others => '0');
    note_loop: for i in 0 to max_notes loop -- go through all the notes
        if switches_actual(i) = '1' then
            note_out_code <= std_logic_vector(to_unsigned(i + 21, 16)); -- set the code to the highest depressed note
        end if;
   end loop note_loop;
end process set_note_out;

set_digits: process (note_out_code)
begin
    y3 <= note_out_code(15 downto 12);
    y2 <= note_out_code(11 downto 8);
    y1 <= note_out_code(7 downto 4);
    y0 <= note_out_code(3 downto 0);
end process set_digits;

display: mux7seg port map( 
    clk_iport 		=> clk_24mHz,
    y3_iport 		=> y3, 		        
    y2_iport 		=> y2, 	
    y1_iport 		=> y1, 		
    y0_iport 		=> y0,		
    dp_set_iport	=> "0000",   
    seg_oport 		=> seg_oport,
    dp_oport 		=> dp_oport,
    an_oport 		=> an_oport );	

end Behavioral;
