----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/20/2021 07:18:59 PM
-- Design Name: 
-- Module Name: midi_keyboard - Behavioral
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

entity midi_keyboard is
    Generic (max_notes : integer);
    Port ( data_iport : in STD_LOGIC;
           clk_24mHz : in STD_LOGIC;
           notes_oport : out STD_LOGIC_VECTOR(0 to max_notes) := (others => '0'));
end midi_keyboard;

architecture Behavioral of midi_keyboard is
constant TBIT_MAX : integer := 768;
constant N_SHIFTS : integer := 10;
constant NOTE_ON : STD_LOGIC_VECTOR(3 downto 0) := "1001";
constant NOTE_OFF : STD_LOGIC_VECTOR(3 downto 0) := "1000";
type state_type is (IDLE, WAITING, LOAD, SHIFT, INTERPRET);
signal curr_state, next_state : state_type;

signal shift_en, load_en, interpret_en, shift_tc, tbit_tc, tbit_reset, tbit_wait_tc, tbit_wait_reset : STD_LOGIC := '0';
signal tbit_count : unsigned(7 downto 0) := (others => '0');
signal shift_count : unsigned(4 downto 0) := (others => '0');

type messages_t is array(0 to 2) of std_logic_vector(7 downto 0);
signal messages : messages_t := (others => (others => '0'));
signal cur_message : std_logic_vector(9 downto 0) := (others => '0');
signal message_count : unsigned(1 downto 0) := (others => '0');
signal dsync, dout : std_logic := '1';

component tick_generator is
	generic (
	   FREQUENCY_DIVIDER_RATIO : integer);
	port (
		system_clk_iport : in  std_logic;
		reset_iport : in std_logic;
		tick_oport		 : out std_logic);
end component;

begin
sync: process (clk_24mHz)
begin
    if rising_edge(clk_24mHz) then
        dsync <= data_iport;
        dout <= dsync;
    end if;
end process sync;

shift_counter: process(clk_24mHz, shift_count)
begin
    if rising_edge(clk_24mHz) then
        if tbit_tc = '1' then
            if shift_en = '1' then
                shift_count <= shift_count + 1;
            end if;
        end if;
        if shift_en = '0' then
            shift_count <= (others => '0');
        end if;
    end if;
    
    shift_tc <= '0';
    if shift_count >= N_SHIFTS - 1 then
        shift_tc <= '1';
    end if;
end process shift_counter;


FSMupdate: process(clk_24mHz)
begin
    if rising_edge(clk_24mHz) then
       curr_state <= next_state;
    end if;
end process FSMupdate;

set_notes: process(clk_24mHz)
begin
    if rising_edge(clk_24mHz) then
        if interpret_en = '1' then
            if messages(0)(7 downto 4) = NOTE_ON then
                if (unsigned(messages(1)) - 21) <= max_notes then
                    notes_oport(to_integer(unsigned(messages(1)) - 21)) <= '1';
                end if;
            elsif messages(0)(7 downto 4) = NOTE_OFF then
                if (unsigned(messages(1)) - 21) <= max_notes then
                    notes_oport(to_integer(unsigned(messages(1)) - 21)) <= '0';
                end if;
            end if;
        end if;
    end if;
end process set_notes;


FSMcomb: process(curr_state, dout, tbit_tc, tbit_wait_tc, shift_tc, message_count)
begin
    next_state <= curr_state;
    shift_en <= '0';
    tbit_reset <= '0';
    tbit_wait_reset <= '0';
    load_en <= '0';
    interpret_en <= '0';
    
    case curr_state is
        when IDLE => 
            if dout = '0' then
                tbit_wait_reset <= '1';
                next_state <= WAITING;
            end if;
       when WAITING => tbit_reset <= '1';
            if tbit_wait_tc = '1' then
                next_state <= SHIFT;
            end if;
       when SHIFT => shift_en <= '1';
            if shift_tc = '1' then
                next_state <= LOAD;
            end if;
       when LOAD => load_en <= '1';
            if message_count < 2 then
                next_state <= IDLE;
            else
                next_state <= INTERPRET;
            end if;
       when INTERPRET => interpret_en <= '1';
            next_state <= IDLE;
    end case;
end process FSMcomb;

shift_register: process(clk_24mHz) 
begin
    if rising_edge(clk_24mHz) then
	   if tbit_tc = '1' then
		  if shift_en = '1' then cur_message <= dout & cur_message(9 downto 1);
		  end if;
        end if;
    end if;
end process;

shift_load: process(clk_24mHz)
begin
    if rising_edge(clk_24mHz) then
        if load_en = '1' then
		  messages(to_integer(message_count)) <= cur_message(8 downto 1);
		  if message_count < 2 then
            message_count <= message_count + 1;
          else
            message_count <= (others => '0');
          end if;
		end if;
    end if;
end process shift_load;

tick_generation: tick_generator
generic map(
	FREQUENCY_DIVIDER_RATIO => TBIT_MAX)
port map( 
	system_clk_iport 	=> clk_24mHz,
	reset_iport => tbit_reset,
	tick_oport			=> tbit_tc);

tick_generation_2: tick_generator
generic map(
	FREQUENCY_DIVIDER_RATIO => TBIT_MAX/2)
port map( 
	system_clk_iport 	=> clk_24mHz,
	reset_iport => tbit_wait_reset,
	tick_oport			=> tbit_wait_tc);

end Behavioral;
