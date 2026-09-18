library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity rs232_demo is
	port (
		reset : in std_logic;
		clk : in std_logic;			-- 50MHz input clock
		
		parity_en : in std_logic;	-- bus switch
		parity_mode : in std_logic;  -- odd : 1, even : 0, bus switch
		
		rxd : in std_logic;
		txd : out std_logic
	);
end rs232_demo;

architecture a of rs232_demo is

component rs_232 is
	port (
		reset : in std_logic;
		clk : in std_logic;
		
		parity_en : in std_logic;
		parity_mode : in std_logic;

		rxd : in std_logic;
		txd : out std_logic;
		
		rxd_en : out std_logic;
		txd_en : in std_logic;
		uart_data_in : out std_logic_vector(7 downto 0);
		uart_data_out : in std_logic_vector(7 downto 0)
	);
end component;

signal resetn : std_logic;

signal rxd_en : std_logic;
signal txd_en : std_logic;
signal uart_data_in : std_logic_vector(7 downto 0);
signal uart_data_out : std_logic_vector(7 downto 0);

signal reg_rxd_en : std_logic_vector(7 downto 0);
signal reg_data_in0 : std_logic_vector(7 downto 0);
signal reg_data_in1 : std_logic_vector(7 downto 0);
signal reg_data_in2 : std_logic_vector(7 downto 0);
signal reg_data_in3 : std_logic_vector(7 downto 0);
signal reg_data_in4 : std_logic_vector(7 downto 0);
signal reg_data_in5 : std_logic_vector(7 downto 0);
signal reg_data_in6 : std_logic_vector(7 downto 0);
signal reg_data_in7 : std_logic_vector(7 downto 0);

signal clk_25m	: std_logic;

begin

resetn <= not reset;

process(clk)
begin
if clk'event and clk = '1' then
	clk_25m <= not clk_25m;
end if;
end process;

u_rs_232 : rs_232
	port map (
		reset => reset,
		clk => clk_25m,

		parity_en => parity_en,
		parity_mode => parity_mode,		
		rxd => rxd,
		txd => txd,
		
		rxd_en => rxd_en,
		txd_en => txd_en,
		
		uart_data_in => uart_data_in,
		uart_data_out => uart_data_out
	);
	
process (resetn, clk_25m)
begin
	if resetn = '0' then
		reg_rxd_en <= (others => '0');
	elsif clk_25m'event and clk_25m = '1' then
		reg_rxd_en <= reg_rxd_en(6 downto 0) & rxd_en;
	end if;
end process;

txd_en <= reg_rxd_en(7);

process (resetn, clk_25m)
begin
	if resetn = '0' then
		reg_data_in0 <= (others => '0');
		reg_data_in1 <= (others => '0');
		reg_data_in2 <= (others => '0');
		reg_data_in3 <= (others => '0');
		reg_data_in4 <= (others => '0');
		reg_data_in5 <= (others => '0');
		reg_data_in6 <= (others => '0');
		reg_data_in7 <= (others => '0');
	elsif clk_25m'event and clk_25m = '1' then
		reg_data_in0 <= uart_data_in;
		reg_data_in1 <= reg_data_in0;
		reg_data_in2 <= reg_data_in1;
		reg_data_in3 <= reg_data_in2;
		reg_data_in4 <= reg_data_in3;
		reg_data_in5 <= reg_data_in4;
		reg_data_in6 <= reg_data_in5;
		reg_data_in7 <= reg_data_in6;
	end if;
end process;

uart_data_out <= reg_data_in7;


end a;	