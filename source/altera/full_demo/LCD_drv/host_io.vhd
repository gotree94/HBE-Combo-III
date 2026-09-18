library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
entity host_io is
	port(
		mclk, mcs, mhre, mhwe : in std_logic;
		mhdo: in unsigned(15 downto 0);
		mhdi: out unsigned(15 downto 0);
		hd: inout unsigned(15 downto 0)
	);
end host_io;


architecture behav of host_io is

signal we_dly, re_dly : std_logic;
 
begin


a: process(mcs, mhwe, we_dly, hd)
	begin
		if(mcs='0') then
			if(mhwe='0' or we_dly='0') then mhdi<=hd;
			else null;
			end if;
		else null;
		end if;
	end process a;

cdly: process(mclk)
	begin
	if mclk'event and mclk = '1' then
		re_dly <= mhre;
		we_dly <= mhwe;
	end if;
	end process cdly;


b: process(mcs, mhre, re_dly, mhdo)
	begin
		if(mcs='0') then hd<=mhdo;
			if(mhre='0' or re_dly='0') then hd<=mhdo;
			else hd<=(others=>'Z');
			end if;            
		else hd<=(others=>'Z');
		end if;
	end process b;


end behav;
