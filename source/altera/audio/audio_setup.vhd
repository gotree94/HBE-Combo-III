library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity audio_setup is
port (
	resetn :	in	std_logic;
	clk :	in	std_logic;

	-- 0:2wire, 1:SPI  
	codec_mode : out std_logic;
	-- control port serial data clock
	codec_sclk : out std_logic;
	-- control port input latch/address select
	codec_csn :	out std_logic;
	-- control port serial data input
	codec_sdin : out std_logic

);
end audio_setup;

architecture a of audio_setup is
   
constant	ad_left_lin_vol :	std_logic_vector (6 downto	0)	:=	"0000000";
constant	ad_right_lin_vol : std_logic_vector	(6	downto 0) := "0000001";
constant	ad_left_head_vol:	std_logic_vector (6 downto	0)	:=	"0000010";
constant	ad_right_head_vol	: std_logic_vector (6 downto 0) := "0000011";
constant	ad_analog_path	: std_logic_vector (6 downto 0) := "0000100";
constant	ad_digital_path :	std_logic_vector (6 downto	0)	:=	"0000101";
constant	ad_power_down : std_logic_vector	(6	downto 0) := "0000110";
constant	ad_digital_interface_format :	std_logic_vector (6 downto	0)	:=	"0000111";
constant	ad_sample_rate	: std_logic_vector (6 downto 0) := "0001000";
constant	ad_digital_interface_act :	std_logic_vector (6 downto	0)	:=	"0001001";
constant	ad_reset_reg :	std_logic_vector (6 downto	0)	:=	"0001111";

signal reg_left_lin_vol	: std_logic_vector (15 downto 0);
signal reg_right_lin_vol :	std_logic_vector (15 downto	0);
signal reg_left_head_vol: std_logic_vector (15 downto 0);
signal reg_right_head_vol : std_logic_vector	(15 downto 0);
signal reg_analog_path : std_logic_vector	(15 downto 0);
signal reg_digital_path	: std_logic_vector (15 downto 0);
signal reg_power_down :	std_logic_vector (15 downto 0);
signal reg_digital_interface_format	: std_logic_vector (15 downto 0);
signal reg_sample_rate : std_logic_vector	(15 downto 0);
signal reg_digital_interface_act	: std_logic_vector (15 downto 0);
signal reg_reset_reg	: std_logic_vector (15 downto 0);

signal line_in_mute : std_logic;
signal line_in_volume : std_logic_vector(4 downto 0);
signal headphone_volume : std_logic_vector(6 downto 0);
signal audio_in_sel : std_logic;
signal microphone_mute : std_logic;
signal microphone_boost : std_logic;
signal sample_rate : std_logic_vector(4 downto 0);
signal line_in_power_down : std_logic;
signal mic_in_power_down : std_logic;

signal cnt_clk : std_logic_vector (12 downto 0);
signal shft_reg : std_logic_vector (15 downto 0);

begin

-- 0 : 2wire, 1 : SPI
codec_mode <= '1';

-- nomal : 0, mute : 1
line_in_mute <= '0'; 

-- default : 10111 (0dB) , 1.5dB steps 
line_in_volume <= "10111"; 

-- default : 1111001 (0dB), 6dB step , mute : 0110000 (-73dB)
headphone_volume <= "1111001";

-- 0 : line, 1 : microphone
audio_in_sel <= '1';

-- 0 : nomal, 1 : mute
microphone_mute <= '0';

-- 0 : 0dB, 1 : 20dB
microphone_boost <= '0';

-- "00110" : ADC(8kHz)  DAC(8kHz),
-- "01100" : ADC(32kHz) DAC(32kHz),
-- "10001" : ADC(44.1kHz) DAC(44.1kHz)

sample_rate <= "00110";

-- line input power down (0:power on, 1:power down)
line_in_power_down <= '1';

-- mic input power down (0:power on, 1:power down)
mic_in_power_down <= '0';

reg_left_lin_vol(15 downto 9) <= ad_left_lin_vol;
reg_right_lin_vol(15 downto 9) <= ad_right_lin_vol;
reg_left_head_vol(15 downto 9) <= ad_left_head_vol;
reg_right_head_vol(15 downto 9) <= ad_right_head_vol;
reg_analog_path(15 downto 9) <= ad_analog_path;
reg_digital_path(15 downto 9) <= ad_digital_path;
reg_power_down(15 downto 9) <= ad_power_down;
reg_digital_interface_format(15 downto 9) <= ad_digital_interface_format;
reg_sample_rate(15 downto 9) <= ad_sample_rate;
reg_digital_interface_act(15 downto 9) <= ad_digital_interface_act;
reg_reset_reg(15 downto 9) <= ad_reset_reg;

reg_left_lin_vol(8 downto 0) <= '0' & line_in_mute & "00" & line_in_volume;
reg_right_lin_vol(8 downto 0) <= '0' & line_in_mute & "00" & line_in_volume;
reg_left_head_vol(8 downto 0) <= '0' & '1' & headphone_volume;
reg_right_head_vol(8 downto 0) <= '0' & '1' & headphone_volume;
reg_analog_path(8 downto 0) <= "0000" & "10" & audio_in_sel & microphone_mute & microphone_boost;
reg_digital_path(8 downto 0) <= "00000" & "0000";
reg_power_down(8 downto 0) <= '0' & "000000" & mic_in_power_down & line_in_power_down;
reg_digital_interface_format(8 downto 0) <= "00" & "1010011";
reg_sample_rate(8 downto 0) <= '0' & "00" & sample_rate & "1";
reg_digital_interface_act(8 downto 0) <= "011000001";
reg_reset_reg(8 downto 0) <= "000000000";

process (resetn, clk)
begin 
if resetn = '0' then
	cnt_clk <= (others => '0');
elsif clk'event and clk = '1' then
	if cnt_clk = "1010111111111" then
		cnt_clk <= cnt_clk;
	else
		cnt_clk <= cnt_clk + 1;
	end if;
end if;
end process;

process (resetn, clk)
begin
if resetn = '0' then
	codec_csn <= '1';
elsif clk'event and clk = '1' then
	if cnt_clk = "1010111111111" then
		codec_csn <= '1';
	elsif cnt_clk(8 downto 0) > "111111000" then
		codec_csn <= '1';
	else
		codec_csn <= '0';
	end if;
end if;
end process;

process (resetn, clk)
begin
if resetn = '0' then
	codec_sclk <= '0';
elsif clk'event and clk = '1' then
	if cnt_clk(4 downto 0) < "10000" then
		codec_sclk <= '0';
	else
		codec_sclk <= '1';
	end if;
end if;
end process;

process(resetn, clk)
begin
if resetn = '0' then
	shft_reg <= (others => '0');
elsif clk'event and clk = '1' then
	if cnt_clk(4 downto 0) = "11111" then
		shft_reg(15 downto 1) <= shft_reg(14 downto 0);
	elsif cnt_clk(8 downto 0) = "000000000" then
		case cnt_clk(12 downto 9) is
			when "0000" =>
				shft_reg <= reg_reset_reg;
			when "0001" =>
				shft_reg <= reg_left_lin_vol;
			when "0010" =>
				shft_reg <= reg_right_lin_vol;
			when "0011" =>
				shft_reg <= reg_left_head_vol;
			when "0100" =>
				shft_reg <= reg_right_head_vol;
			when "0101" =>
				shft_reg <= reg_analog_path;
			when "0110" =>
				shft_reg <= reg_digital_path;
			when "0111" =>
				shft_reg <= reg_power_down;
			when "1000" =>
				shft_reg <= reg_digital_interface_format;
			when "1001" =>
				shft_reg <= reg_sample_rate;
			when "1010" =>
				shft_reg <= reg_digital_interface_act;
			when others =>
				shft_reg <= (others => '1');				
		end case;
	end if;
end if;
end process;

codec_sdin <= shft_reg(15);

end a;