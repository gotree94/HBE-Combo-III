LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all;

ENTITY cs_sel IS
  PORT(
		add25		: in std_logic;
		EXB_REG_nCS	: in std_logic;
		nCS2		: out std_logic
	  
    );
END cs_sel;


ARCHITECTURE hb OF cs_sel IS

BEGIN

nCS2 <= EXB_REG_nCS when add25 = '1' else '1';

END hb;
