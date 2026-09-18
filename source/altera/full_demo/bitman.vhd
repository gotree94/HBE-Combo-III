
-- Dot_matirx animation : Bit man
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

-- input, output port
entity bitman is
port(
	clk_1MHz : in std_logic;			-- 1MHz
	reset : in std_logic;
	dot_d : out std_logic_vector(13 downto 0);
	dot_scan : out std_logic_vector(9 downto 0));
--	stand : in std_logic;
--	jump : in std_logic;
--	move_left : in std_logic;
--	move_right : in std_logic;
--	use_one : in std_logic;
--	use_two : in std_logic
end bitman;

architecture mush of bitman is

-- connect rom file
signal address : std_logic_vector(9 downto 0);
signal data : std_logic_vector(13 downto 0);

-- address control signal
signal cnt_a : integer range 9 downto 0;
signal cnt_b : integer range 9 downto 0;
signal cnt_c : integer range 9 downto 0;
signal cnt_sum : integer range 599 downto 0;
signal cnt_rem : integer range 9 downto 0;

-- state enable signal
signal stand_en : std_logic;
signal jump_en : std_logic;
signal move_left_en : std_logic;
signal move_right_en : std_logic;
signal use_one_en : std_logic;
signal use_two_en : std_logic;

signal clk_cnt 	: integer range 0 to 499;
signal clk		: std_logic;


signal delay_cnt	: integer range 0 to 2999;

type en_state1 is(stand, jump, move_left, move_right);
signal en_state : en_state1;

-- component rom file
component lpm_rom1
port(
	address : in std_logic_vector(9 downto 0);
	clock : in std_logic;
	q : out std_logic_vector(13 downto 0)
);
end component;

begin

-- port map rom file
u0 : lpm_rom1
port map(
	address => address,
	clock => clk,
	q => data
);

process(clk_1MHz)
begin
if clk_1MHz'event and clk_1MHz = '1' then
	if clk_cnt = 499 then
		clk <= not clk;
		clk_cnt <= 0;
	else
		clk <= clk;
		clk_cnt <= clk_cnt + 1;
	end if;
end if;
end process;

process(clk)
begin
if reset = '1' then
	en_state <= stand;
elsif clk'event and clk = '1' then
	if delay_cnt = 2999 then
		case en_state is
			when stand => en_state <= jump;
			when jump => en_state <= move_left;
			when move_left => en_state <= move_right;
			when move_right => en_state <= stand;
			when others => en_state <= stand;
		end case;
		delay_cnt <= 0;
	else
		delay_cnt <= delay_cnt + 1;
	end if;
end if;
end process;

process(clk)
begin
if reset = '1' then
	stand_en <= '0';
	jump_en <= '0';
	move_left_en <= '0';
	move_right_en <= '0';
	use_one_en <= '0';
	use_two_en <= '0';
elsif clk'event and clk = '1' then
	case en_state is
		when stand => 
			stand_en <= '1';
			jump_en <= '0';
			move_left_en <= '0';
			move_right_en <= '0';
			use_one_en <= '0';
			use_two_en <= '0';
		when jump =>
			stand_en <= '0';
			jump_en <= '1';
			move_left_en <= '0';
			move_right_en <= '0';
			use_one_en <= '0';
			use_two_en <= '0';
		when move_left =>
			stand_en <= '0';
			jump_en <= '0';
			move_left_en <= '1';
			move_right_en <= '0';
			use_one_en <= '0';
			use_two_en <= '0';
		when move_right =>
			stand_en <= '0';
			jump_en <= '0';
			move_left_en <= '0';
			move_right_en <= '1';
			use_one_en <= '0';
			use_two_en <= '0';
	end case;
end if;
end process;

		
-- count one
process(clk)
begin
	if reset = '1' then
		cnt_a <= 0;
	elsif clk'event and clk = '1' then
		if cnt_a = 9 then
			cnt_a <= 0;
		else
			cnt_a <= cnt_a + 1;
		end if;
	end if;
end process;


-- count ten
process(clk)
begin
	if reset = '1' then
		cnt_b <= 0;
	elsif clk'event and clk = '1' then
		if cnt_a = 9 then
			if cnt_b = 9 then
				cnt_b <= 0;
			else
				cnt_b <= cnt_b + 1;
			end if;
		else
			cnt_b <= cnt_b;
		end if;
	end if;
end process;


-- count hundred
process(clk)
begin
	if reset = '1' then
		cnt_c <= 0;
	elsif clk'event and clk = '1' then
		if cnt_a = 9 and cnt_b = 9 then
			if cnt_c = 9 then
				cnt_c <= 0;
			else
				cnt_c <= cnt_c + 1;
			end if;
		else
			cnt_c <= cnt_c;
		end if;
	end if;
end process;

-- address control
process(clk)
begin
	if reset = '1' then
		cnt_sum <= 0;
	elsif clk'event and clk = '1' then
		if stand_en = '1' then
			cnt_sum <= cnt_c * 10 + cnt_a;
		elsif jump_en = '1' then
			cnt_sum <= cnt_c * 10 + cnt_a + 100;
		elsif move_left_en = '1' then
			cnt_sum <= cnt_c * 10 + cnt_a + 200;
		elsif move_right_en = '1' then
			cnt_sum <= cnt_c * 10 + cnt_a + 300;
		elsif use_one_en = '1' then
			cnt_sum <= cnt_c * 10 + cnt_a + 400;	-- User can application.
		elsif use_two_en = '1' then
			cnt_sum <= cnt_c * 10 + cnt_a + 500;	-- User can application.
		else
			cnt_sum <= cnt_c * 10 + cnt_a;
		end if;
	end if;
end process;

-- disply, conversion
process(clk)
begin
	if clk'event and clk = '1' then
		address <= conv_std_logic_vector(cnt_sum, 10);
		cnt_rem <= (cnt_sum rem 10) - 2;
		
		if cnt_rem = 0 then
			cnt_rem <= 9;
		end if;

		case cnt_rem is
			when 0 =>
				dot_d <= data;
				dot_scan <= "0000000001";
			when 1 =>
				dot_d <= data;
				dot_scan <= "0000000010";
			when 2 =>
				dot_d <= data;
				dot_scan <= "0000000100";
			when 3 =>
				dot_d <= data;
				dot_scan <= "0000001000";
			when 4 =>
				dot_d <= data;
				dot_scan <= "0000010000";
			when 5 =>
				dot_d <= data;
				dot_scan <= "0000100000";
			when 6 =>
				dot_d <= data;
				dot_scan <= "0001000000";
			when 7 =>
				dot_d <= data;
				dot_scan <= "0010000000";
			when 8 =>
				dot_d <= data;
				dot_scan <= "0100000000";
			when 9 =>
				dot_d <= data;
				dot_scan <= "1000000000";
		end case;
	end if;
end process;

end mush;