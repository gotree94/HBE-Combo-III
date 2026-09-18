library ieee;
use ieee.std_logic_1164.all;

entity segment_demo is
port(
	clk		: in std_logic;
	
	s10, s1	: out integer range 0 to 9;
	m10, m1	: out integer range 0 to 9;
	h10, h1	: out integer range 0 to 9); 
end segment_demo;

architecture hb of segment_demo is

component sep
port(
	a		: in integer range 0 to 59;
	ten, one: out integer range 0 to 9);
end component;

signal clk_1hz	: std_logic;
signal min, sec	: integer range 0 to 59;
signal hour		: integer range 0 to 23;
signal m_clk	: std_logic;
signal h_clk	: std_logic;

begin

s_s : sep
port map(sec, s10, s1);

s_m : sep
port map(min, m10, m1);

s_h : sep
port map(hour, h10, h1);

process(clk)
variable s_cnt	: integer range 0 to 499;
variable s_clk	: std_logic;
begin
if clk'event and clk = '1' then
	if s_cnt = 499 then
		s_cnt := 0;
		s_clk := not s_clk;
	else
		s_cnt := s_cnt + 1;
		s_clk := s_clk;
	end if;
	clk_1hz <= s_clk;
end if;
end process;

process(clk_1hz)
begin
if clk_1hz'event and clk_1hz = '1' then
	if sec >= 59 then
		m_clk <= '1';
		sec <= 0;
	else
		sec <= sec + 1;
		m_clk <= '0';
	end if;
end if;
end process;

process(m_clk)
begin
if m_clk'event and m_clk = '1' then
	if min >= 59 then
		min <= 0;
		h_clk <= '1';
	else
		min <= min + 1;
		h_clk <= '0';
	end if;
end if;
end process;

process(h_clk)
begin
if h_clk'event and h_clk = '1' then
	if hour >= 23 then
		hour <= 0;
	else
		hour <= hour + 1;
	end if;
end if;
end process;

end hb;