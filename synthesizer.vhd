----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/18/2021 03:47:41 PM
-- Design Name: 
-- Module Name: synthesizer - Behavioral
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

entity synthesizer is
    Generic ( max_notes : integer);
    Port ( take_sample : in STD_LOGIC;
           notes_on: in STD_LOGIC_VECTOR(0 to max_notes);
           note_out : out STD_LOGIC_VECTOR(15 DOWNTO 0);
           clk_24mHz : in STD_LOGIC);
end synthesizer;

architecture Behavioral of synthesizer is
component dds is
    Generic (STEP_SIZE : integer);
    Port ( clk_iport : in STD_LOGIC;
           count_en : in STD_LOGIC;
           count_oport : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) );
end component;

COMPONENT dds_compiler_0
  PORT (
    aclk : IN STD_LOGIC;
    aresetn: IN STD_LOGIC;
    s_axis_phase_tvalid : IN STD_LOGIC;
    s_axis_phase_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    m_axis_data_tvalid : OUT STD_LOGIC;
    m_axis_data_tdata : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
END COMPONENT;

type steps_t is array (0 to max_notes) of integer;
type notes_t is array (0 to max_notes) of STD_LOGIC_VECTOR(15 DOWNTO 0);
constant steps : steps_t := (
    0 => 19, -- 27.5
    1 => 20, -- 29.135
    2 => 21, -- 30.868
    3 => 22, -- 32.703
    4 => 24, -- 34.648
    5 => 25,  -- 36.708
    6 => 27, -- 38.891
    7 => 28, -- 41.203
    8 => 30, -- 43.654
    9 => 32, -- 46.249
    10 => 33, -- 48.999
    11 => 35, -- 51.913
    12 => 38, -- 55.000
    13 => 40, -- 58.270
    14 => 42, -- 61.735
    15 => 45, -- 65.406
    16 => 47, -- 69.296
    17 => 50, -- 73.416
    18 => 53, -- 77.782
    19 => 56, -- 82.407
    20 => 60, -- 87.307
    21 => 63, -- 92.499
    22 => 67, -- 97.999
    23 => 71, -- 103.83
    24 => 75, -- 110
    25 => 80, -- 116.54
    26 => 84, --123.47
    27 => 89,-- 130.81
    28 => 95, -- 138.59
    29 => 100, -- 146.83
    30 => 106, -- 155.56
    31 => 113, -- 164.81
    32 => 119, -- 174.61
    33 => 126, -- 185
    34 => 134, -- 196
    35 => 142, -- 207.65
    36 => 150, -- 220
    37 => 159, -- 233.08
    38 => 169, -- 246.94
    39 => 179, -- 261.63
    40 => 189, -- 277.18
    41 => 201, -- 293.67
    42 => 212, -- 311.13
    43 => 225, -- 329.63
    44 => 238, -- 349.23
    45 => 253, -- 369.99
    46 => 268, -- 392.00
    47 => 284, -- 415.30
    48 => 300, -- 440.00
    49 => 318, -- 466.16
    50 => 337, -- 493.88
    51 => 357, -- 523.25
    52 => 378, -- 554.37
    53 => 401, -- 587.33
    54 => 425, -- 622.25
    55 => 450, -- 659.26
    56 => 477, -- 698.46
    57 => 505, -- 739.99
    58 => 535, -- 783.99
    59 => 567, -- 830.61
    60 => 601, -- 880.00
    61 => 636, -- 932.33
    62 => 674, -- 987.77
    63 => 714, -- 1046.5
    64 => 756, -- 1108.7
    65 => 802, -- 1174.7
    66 => 850, -- 1244.5
    67 => 900, --1318.5
    68 => 954, -- 1396.9
    69 => 1010, -- 1480
    70 => 1070, -- 1568
    71 => 1134, -- 1661.2
    72 => 1201, -- 1760
    73 => 1273, -- 1864.7
    74 => 1349, -- 1975.5
    75 => 1429, -- 2093
    76 => 1514, -- 2217.5
    77 => 1604, -- 2349.3
    78 => 1699, -- 2489
    79 => 1800, -- 2637
    80 => 1907,  -- 2793
    81 => 2021, -- 2960
    82 => 2141, -- 3136
    83 => 2268, -- 3322.4
    84 => 2403, --3520
    85 => 2546, -- 3729.3
    86 => 2697, -- 3951.1
    87 => 2858 -- 4186
);
signal counts, notes : notes_t := (others => (others => '0'));
signal count, note : STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => '0');
signal data_in, data_out : std_logic_vector(15 downto 0) := (others => '0'); 
signal valid_in, valid_out : std_logic := '0';
signal reset : std_logic := '1';

signal count_en, notes_en, wait_en, accumulate_en : std_logic := '0';
signal count_i, notes_i, wait_i : integer := 0;

type state_type is (SAMPLE, WAITING, COUNTING, NOTING, ACCUMULATE);
signal curr_state, next_state: state_type;

signal numnotes_sig : unsigned(5 downto 0) := (others => '0'); 
signal notes_accumulated_sig : unsigned(17 downto 0) := (others => '0'); 

begin
gen_sine:
for I in 0 to max_notes generate
    sine_I: dds
    generic map ( STEP_SIZE => steps(I) )
    port map ( clk_iport => take_sample,
           count_en => notes_on(i),
           count_oport => counts(i)
    );
end generate gen_sine;

count_to_sin: process (count, data_out)
begin
    data_in <= std_logic_vector('0' & count(14 downto 0));
    note <= "0000" & not(data_out(11)) & data_out(10 downto 0);
end process count_to_sin;

sin_lut : dds_compiler_0
  PORT MAP (
    aclk => clk_24mHz,
    aresetn => reset,
    s_axis_phase_tvalid => valid_in,
    s_axis_phase_tdata => data_in,
    m_axis_data_tvalid => valid_out,
    m_axis_data_tdata => data_out
);

FSMupdate: process(clk_24mHz)
begin
    if rising_edge(clk_24mHz) then
       curr_state <= next_state;
    end if;
end process FSMupdate;

FSM_count: process (clk_24mHz)
begin
    if rising_edge(clk_24mHz) then
        if notes_en = '1' then
            if notes_i <= max_notes then
                notes(notes_i) <= note;
            end if;
            notes_i <= notes_i + 1;
        else
            notes_i <= 0;
        end if;
        
        if count_en = '1' then
            if count_i <= max_notes then
                count <= counts(count_i);
            end if;
            count_i <= count_i + 1;
        else
            count_i <= 0;
        end if;
        
        if wait_en = '1' then
            wait_i <= wait_i + 1;
        else
            wait_i <= 0;
        end if;
    end if;
end process FSM_count;

accumulator: process (curr_state, wait_i, notes, count_i, valid_out, notes_i, take_sample, counts, note)
begin
    next_state <= curr_state;
    valid_in <= '0';
    reset <= '0';
    wait_en <= '0';
    count_en <= '0';
    notes_en <= '0'; 
    accumulate_en <= '0';

    case curr_state is
        when SAMPLE =>
            if take_sample = '1' then
                next_state <= WAITING;
            end if;
        when WAITING => reset <= '1';
            wait_en <= '1';
            if wait_i >= 4 then
                next_state <= COUNTING;
            end if;
        when COUNTING => valid_in <= '1';
            reset <= '1';
            count_en <= '1';
            
            if valid_out = '1' then
                next_state <= NOTING;
            end if;
         when NOTING => valid_in <= '1';
            reset <= '1';
            notes_en <= '1';
            count_en <= '1';
            
            if notes_i > max_notes then
                next_state <= ACCUMULATE;
            end if;
         
          when ACCUMULATE => accumulate_en <= '1';
                next_state <= SAMPLE;
    end case;      
end process accumulator;

proc_notes: process(clk_24mHz)
variable notes_accumulated : unsigned(17 downto 0) := (others => '0'); 
variable numnotes : unsigned(5 downto 0) := (others => '0'); 

begin
    if rising_edge(clk_24mHz) then
        if accumulate_en = '1' then 
            notes_accumulated := (others => '0'); 
            numnotes := (others => '0'); 
            note_loop: for i in 0 to max_notes loop
                if notes_on(i) = '1' then
                    notes_accumulated := notes_accumulated + unsigned(notes(i));
                    numnotes := numnotes + 1;
                end if;
            end loop note_loop;
            
            numnotes_sig <= numnotes;
            notes_accumulated_sig <= notes_accumulated;
        end if;
    end if;
end process proc_notes;

arithmetic: process(numnotes_sig, notes_accumulated_sig)
begin
    note_out <= (others => '0');
    if numnotes_sig > 0 then
        note_out <= STD_LOGIC_VECTOR(resize(notes_accumulated_sig/numnotes_sig, 16));
    end if;
end process arithmetic;

end Behavioral;
