library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
----------------------------------------------------------------------------------------------------
--host_interface

entity HOST_ITF is
port(
		CLK 		: in std_logic;
		PCLK		: in std_logic;
		HOST_nOE	: in std_logic;
		HOST_nWE	: in std_logic;
		HOST_nCS	: in std_logic;
		HOST_ADD	: in std_logic_vector(18 downto 0);
		LCD_nOE		: in std_logic;
		SRAM2_DATA	: in std_logic_vector(15 downto 0);
				
		nOE 		: buffer std_logic;
		RD_ADD		: out std_logic_vector(18 downto 0);
		
		HDI			: in std_logic_vector(15 downto 0);
		HDO			: out std_logic_vector(15 downto 0);

		hold_out	: out std_logic;		
		irq_en		: out std_logic;
		LCD_RST		: out std_logic;
		
		SPI_CS1		: out std_logic;
		SPI_CS2		: out std_logic;
		SPI_CLK		: out std_logic;
		SPI_IN		: in std_logic;
		SPI_OUT		: out std_logic;
		
		FPGA_nOE	: in std_logic

	);
	
end HOST_ITF;

architecture a of HOST_ITF is 

signal data_temp 			: std_logic_vector(15 downto 0);
signal host_hold : std_logic;
signal irq_en_sig			: std_logic;
signal LCD_RESET			: std_logic;
signal USER_GPIO_REG_in		: std_logic_vector(7 downto 0);
signal USER_GPIO_REG_out	: std_logic_vector(7 downto 0);

begin

nOE <= HOST_nOE and FPGA_nOE;
RD_ADD	<= HOST_ADD;
irq_en <= irq_en_sig;
hold_out <= host_hold;

LCD_RST <= LCD_RESET;

--------------------------------------
--user_gpio
--------------------------------------

SPI_CS1 <= USER_GPIO_REG_out(0);
SPI_CS2 <= USER_GPIO_REG_out(1);
SPI_CLK <= USER_GPIO_REG_out(2);
SPI_OUT <= USER_GPIO_REG_out(3);

USER_GPIO_REG_in <= "0000000" & SPI_IN;

	process(clk)
	begin
		if clk'event and clk = '1' then
			if HOST_nCS = '0' and HOST_nWE = '0' and HOST_ADD(18) = '1' then
				case HOST_ADD(5 downto 0) is
					when "100000" => host_hold 			<= HDI(0);
					when "110000" => irq_en_sig			<= HDI(0);	 	 		--0x0A98_0060
					when "110001" => LCD_RESET			<= HDI(0);		 		--0x0A98_0062
					when "110010" => USER_GPIO_REG_out 	<= HDI(7 downto 0);		--0x0A98_0064
					when others => null;
				end case;
			end if;
		end if;
	end process;
	
--USER_GPIO_REG_out <= "10100101";
	
--	process(HOST_ADD,host_hold,irq_en_sig,LCD_RESET,data_temp)
	process(clk)
	begin
		if clk'event and clk = '1' then
			if HOST_nCS = '0' and HOST_nOE = '0' and HOST_ADD(18) = '1' then
				case HOST_ADD(5 downto 0) is
					when "100000" => HDO <= "000000000000000" & host_hold;		-- host_hold signal (0x0898_0040)
					when "110000" => HDO <= "000000000000000" & irq_en_sig;		-- Host irq Enable signal
					when "110001" => HDO <= "010100000000000" & LCD_RESET;		--0x0A98_0062
					when "110010" => HDO <= "00000000" & USER_GPIO_REG_out;		--0x0A98_0064
					when "110011" => HDO <= "00000000" & USER_GPIO_REG_in;		--0x0A98_0066
					when others => null;
				end case;
			else
				HDO		<= data_temp;
			end if;
		end if;
	end process;

	process(nOE,SRAM2_DATA)
	begin
		if (nOE = '0')then
			data_temp <= SRAM2_DATA;
		end if;
	end process;
	
end a;