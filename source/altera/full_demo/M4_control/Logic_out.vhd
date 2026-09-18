LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY Logic_out IS
  PORT(
		HIGH : out std_logic;
		LOW	 : out std_logic;
		Z	 : out std_logic
    );
END Logic_out;


ARCHITECTURE hb OF Logic_out IS

BEGIN

HIGH	<= '1';
LOW		<= '0';
Z		<= 'Z';

end hb;	