library ieee;
use ieee.std_logic_1164.all;

entity dip_switch is
port(
	clk		: in std_logic;   -- 50MHz
	
	b_switch	: in std_logic_vector(7 downto 0);
	
	seg_com		: out std_logic_vector(7 downto 0);
	seg_data	: out std_logic_vector(7 downto 0));
end dip_switch;

architecture hb of dip_switch is

component diptoseg
port(
	dip_sw	: in std_logic_vector(3 downto 0);
	seg_d	: out std_logic_vector(7 downto 0));
end component;

signal seg_data1 	: std_logic_vector(7 downto 0);
signal seg_data2 	: std_logic_vector(7 downto 0);
signal bus_sw1		: std_logic_vector(3 downto 0);
signal bus_sw2		: std_logic_vector(3 downto 0);
signal seg_cnt		: integer range 0 to 7;

signal clk_100k	: std_logic;
signal cnt_100k	: integer range 0 to 249;

begin

d1 : diptoseg
port map(bus_sw1 , seg_data1);

d2 : diptoseg
port map(bus_sw2 , seg_data2);

bus_sw1 <= b_switch(7 downto 4);
bus_sw2 <= b_switch(3 downto 0);

process(clk)
begin
if clk'event and clk = '1' then
	if cnt_100k = 249 then
		cnt_100k <= 0;
		clk_100k <= not clk_100k;
	else
		cnt_100k <= cnt_100k + 1;
	end if;
end if;
end process;

process(clk_100k)
begin
if clk_100k'event and clk_100k = '1' then
	if seg_cnt = 7 then
		seg_cnt <= 0;
	else
		seg_cnt <= seg_cnt + 1;
	end if;
end if;
end process;

process(clk_100k)
begin
if clk_100k'event and clk_100k = '1' then
	case seg_cnt is
		when 0 =>
			seg_com <= "11111110";
			seg_data <= seg_data1;
		when 1 =>
			seg_com <= "11111101";
			seg_data <= seg_data1;
		when 2 =>
			seg_com <= "11111011";
			seg_data <= seg_data1;
		when 3 =>
			seg_com <= "11110111";
			seg_data <= seg_data1;
		when 4 =>
			seg_com <= "11101111";
			seg_data <= seg_data2;
		when 5 =>
			seg_com <= "11011111";
			seg_data <= seg_data2;
		when 6 =>
			seg_com <= "10111111";
			seg_data <= seg_data2;
		when 7 =>
			seg_com <= "01111111";
			seg_data <= seg_data2;
		when others =>
			seg_com <= "11111111";
	end case;
end if;
end process;

end hb;