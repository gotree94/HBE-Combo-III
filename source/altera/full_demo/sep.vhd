library ieee;
use ieee.std_logic_1164.all;

entity sep is
port(
	a		: in integer range 0 to 59;
	ten, one: out integer range 0 to 9);
end sep;

architecture a of sep is
begin

process(a)
begin
	if a <= 9 then
		ten <= 0;
		one <= a;
	elsif a <= 19 then
		ten <= 1;
		one <= a - 10;
	elsif a <= 29 then
		ten <= 2;
		one <= a - 20;
	elsif a <= 39 then
		ten <= 3;
		one <= a - 30;
	elsif a <= 49 then
		ten <= 4;
		one <= a - 40;
	elsif a <= 59 then
		ten <= 5;
		one <= a - 50;
	else
		ten <= 0;
		one <= 0;
	end if;
end process;
end a;