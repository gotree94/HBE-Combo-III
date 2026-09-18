library ieee;
use ieee.std_logic_1164.all;

entity sep is
	port(
		number : in integer range 0 to 99;
		ten, one : out integer range 0 to 9
		);
	end sep;
	
architecture gk of sep is
begin

process(number)
begin
	if number <= 9 then
		ten <= 0;
		one <= number;
	elsif number <= 19 then
		ten <= 1;
		one <= number - 10;
	elsif number <= 29 then
		ten <= 2;
		one <= number - 20;
	elsif number <= 39 then
		ten <= 3;
		one <= number - 30;
	elsif number <= 49 then
		ten <= 4;
		one <= number - 40;
	elsif number <= 59 then
		ten <= 5;
		one <= number - 50;
	elsif number <= 69 then
		ten <= 6;
		one <= number - 60;
	elsif number <= 79 then
		ten <= 7;
		one <= number - 70;
	elsif number <= 89 then
		ten <= 8;
		one <= number - 80;
	elsif number <= 99 then
		ten <= 9;
		one <= number - 90;
	else
		ten <= 0;
		one <= 0;
	end if;
end process;
end gk;

	