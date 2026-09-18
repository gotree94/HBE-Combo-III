library ieee;
use ieee.std_logic_1164.all;

entity motor_demo is
port(
	clk		: in std_logic;
	sensor	: in std_logic;
	
	motor_data : out std_logic_vector(3 downto 0));
end motor_demo;

architecture hb of motor_demo is

signal mode			: integer range 0 to 1;
signal m_cnt 		: integer range 0 to 3;
signal s_cnt		: integer range 0 to 9;
signal mode_cnt	: integer range 0 to 2;
signal clk_div		: std_logic;

begin


process(clk)
variable cnt : integer range 0 to 999999;
variable clk_d : std_logic;
begin
if clk'event and clk = '1' then
	if cnt = 999999 then
		cnt := 0;
		clk_d := not clk_d;
	else
		cnt := cnt + 1;
		clk_d := clk_d;
	end if;
	clk_div <= clk_d;
end if;
end process;


process(clk_div)
begin
if clk_div'event and clk_div = '1' then
	if mode = 0 then
		case m_cnt is
			when 0 => motor_data <= "0011";
			when 1 => motor_data <= "1001";
			when 2 => motor_data <= "1100";
			when 3 => motor_data <= "0110";
			when others => motor_data <= "0011";
		end case;
	elsif mode = 1 then
		case m_cnt is
			when 0 => motor_data <= "0011";
			when 1 => motor_data <= "0110";
			when 2 => motor_data <= "1100";
			when 3 => motor_data <= "1001";
			when others => motor_data <= "0011";
		end case;
	end if;
	m_cnt <= m_cnt + 1;
end if;
end process;

process(clk_div)
begin
if clk_div'event and clk_div = '1' then
	if sensor = '1' then
		if mode_cnt = 2 then
			if s_cnt = 9 then
				mode <= mode + 1;
				s_cnt <= 0;
				mode_cnt <= 0;
			else
				s_cnt <= s_cnt + 1;
				mode_cnt <= 0;
			end if;
		else
			mode_cnt <= mode_cnt + 1;
		end if;
	else
		mode_cnt <= 0;
		s_cnt <= s_cnt;
	end if;
end if;
end process;
		

end hb;