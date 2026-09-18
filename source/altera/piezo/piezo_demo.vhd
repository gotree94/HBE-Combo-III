library ieee;
use ieee.std_logic_1164.all;

entity piezo_demo is
port(
	clk		: in std_logic;
	key		: in std_logic_vector(5 downto 0);
	
	piezo	: out std_logic);
end piezo_demo;

architecture hb of piezo_demo is

constant ra_low 	: integer range 0 to 2047 := 1135;
constant si_low 	: integer range 0 to 2047 := 1011;
constant do 		: integer range 0 to 2047 := 955;
constant rae 		: integer range 0 to 2047 := 850;
constant mi 		: integer range 0 to 2047 := 757;
constant fa 		: integer range 0 to 2047 := 715;

signal cnt 		: integer range 0 to 2047;

signal p_clk	: std_logic;

signal clk_1m		: std_logic;
signal cnt_1m		: integer range 0 to 24;


begin

piezo <= p_clk;

process(clk)
begin
if clk'event and clk = '1' then
	if cnt_1m = 24 then
		cnt_1m <= 0;
		clk_1m <= not clk_1m;
	else
		cnt_1m <= cnt_1m + 1;
	end if;
end if;
end process;


process (clk_1m)
begin
	if clk_1m'event and clk_1m = '1' then
		if key = "000001" then		-- key 1
			if cnt = ra_low then
				cnt <= 0;
			else
				cnt <= cnt + 1;
			end if;
		elsif key = "000010" then	-- key 2
			if cnt = si_low then
				cnt <= 0;
			else
				cnt <= cnt + 1;
			end if;
		elsif key = "000100" then	-- key 3
			if cnt = do then
				cnt <= 0;
			else
				cnt <= cnt + 1;
			end if;
		elsif key = "001000" then	-- key 4
			if cnt = rae then
				cnt <= 0;
			else
				cnt <= cnt + 1;
			end if;
		elsif key = "010000" then	-- key 5
			if cnt = mi then
				cnt <= 0;
			else
				cnt <= cnt + 1;
			end if;
		elsif key = "100000" then	-- key 6
			if cnt = fa then
				cnt <= 0;
			else
				cnt <= cnt + 1;
			end if;
		else
			cnt <= 0;
		end if;
	end if;
end process;

process (clk_1m)
begin
if clk_1m'event and clk_1m = '1' then
	if cnt = 1 then
		p_clk <= not p_clk;
	end if;
end if;
end process;

end hb;	