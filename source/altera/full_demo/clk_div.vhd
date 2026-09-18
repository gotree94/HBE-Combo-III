library ieee;
use ieee.std_logic_1164.all;

entity clk_div is
port(
	clk		: in std_logic;
	clk_25M	: out std_logic);
end clk_div;

architecture hb of clk_div is

signal clk_d	: std_logic;

begin

process(clk)
begin
if clk'event and clk = '0' then
	clk_d <= not clk_d;
end if;
end process;

clk_25M <= clk_d;

end hb;