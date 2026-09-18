library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity voice_record is
port(
	sw_reset : in std_logic;
	-- 50MHz Main Clock
	clk : in std_logic;  
--	clk_12m : in std_logic;
	
	-- 0:2wire, 1:SPI  
	codec_mode : out std_logic;
	-- control port serial data clock
	codec_sclk : out std_logic;
	-- control port input latch/address select
	codec_csn :	out std_logic;
	-- control port serial data input
	codec_sdin : out std_logic;

	-- I2S format serial data input
	codec_din :	out std_logic;
	-- I2S format serial data output
	codec_dout : in std_logic;
	-- I2S DAC-word clock signal
	codec_lrcin	: in	std_logic;
	-- I2S ADC-word clock signal
	codec_lrcout :	in std_logic;
	-- I2S serial-bit clock
	codec_bclk : in std_logic;
	codec_mclk : out std_logic;
	
	sw_record : in std_logic;
	sw_play : in std_logic;
	sw_stop : in std_logic;
	
	sram_add : out std_logic_vector(17 downto 0);
	sram_data : inout std_logic_vector(15 downto 0);
	sram_cs : out std_logic;
	sram_we : out std_logic;
	sram_oe : out std_logic;
	sram_lb	: out std_logic_vector(1 downto 0);
	sram_ub	: out std_logic_vector(1 downto 0);
	
	led_record : out std_logic;
	led_play : out std_logic	
);
end entity voice_record;

architecture a of voice_record is

component audio_interface	is
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
	codec_sdin : out std_logic;

	-- I2S format serial data input
	codec_din :	out std_logic;
	-- I2S format serial data output
	codec_dout : in std_logic;
	-- I2S DAC-word clock signal
	codec_lrcin	: in	std_logic;
	-- I2S ADC-word clock signal
	codec_lrcout :	in std_logic;
	-- I2S serial-bit clock
	codec_bclk : in std_logic;
	
	audio_din : out std_logic_vector(31 downto 0);
	audio_din_en : out std_logic;
	audio_dout_en : out std_logic;
	audio_dout : in std_logic_vector(31 downto 0)
);
end component;

component audio_clk
port(
	inclk0	: in std_logic;
	c0		: out std_logic);
end component;

signal resetn : std_logic;

type record_state is (idle, recording, play);
signal record_routine : record_state;

signal cnt_rec_data : std_logic_vector(17 downto 0);
signal cnt_record_max : std_logic_vector(17 downto 0);
signal cnt_play_data : std_logic_vector(17 downto 0);

signal audio_din : std_logic_vector(31 downto 0);
signal audio_dout : std_logic_vector(31 downto 0);
signal reg_audio_dout : std_logic_vector(31 downto 0);
signal audio_din_en : std_logic;
signal audio_dout_en : std_logic;

signal reg_audio_din_en : std_logic_vector(1 downto 0);
signal reg_audio_dout_en : std_logic_vector(1 downto 0);

signal reg_sram_add : std_logic_vector(17 downto 0);

signal clk_12m		: std_logic;

begin

u_audio_clk : audio_clk
port map(
	inclk0 => clk,
	c0 => clk_12m);

codec_mclk <= clk_12m;

resetn <= not sw_reset;

sram_lb <= "00";
sram_ub <= "00";

u_audio_interface : audio_interface
port map(
	resetn => resetn,
	clk => clk,

	codec_mode => codec_mode,
	codec_sclk => codec_sclk,
	codec_csn => codec_csn,
	codec_sdin => codec_sdin,

	codec_din => codec_din,
	codec_dout => codec_dout,
	codec_lrcin	=> codec_lrcin,
	codec_lrcout => codec_lrcout,
	codec_bclk => codec_bclk,
	
	audio_din => audio_din,
	audio_din_en => audio_din_en,
	audio_dout_en => audio_dout_en,
	audio_dout => audio_dout
);


process (resetn, clk)
begin
	if resetn = '0' then
		record_routine <= idle;
	elsif clk'event and clk = '1' then
		case record_routine is
			when idle =>
				if sw_record = '1' then
					record_routine <= recording;
				elsif sw_play = '1' then
					record_routine <= play;
				end if;
			when recording =>
				if cnt_rec_data = x"3FFFF" then
					record_routine <= idle;
				elsif sw_stop = '1' then
					record_routine <= idle;
				end if;
			when play =>
				if cnt_play_data = cnt_record_max then
					record_routine <= idle;
				elsif sw_stop = '1' then
					record_routine <= idle;
				end if;
		end case;
	end if;
end process;

process(resetn, clk)
begin
	if resetn = '0' then
		cnt_record_max <= (others => '0');
	elsif clk'event and clk = '1' then
		if record_routine = recording then
			if cnt_rec_data = x"3FFFF" then
				cnt_record_max <= cnt_rec_data;
			elsif sw_stop = '1' then
				cnt_record_max <= cnt_rec_data;
			end if;
		end if;
	end if;
end process;

process (resetn, clk)
begin
	if resetn = '0' then
		reg_audio_din_en <= "00";
	elsif clk'event and clk = '1' then
		if record_routine = recording then
			reg_audio_din_en <= reg_audio_din_en(0) & audio_din_en;
		else
			reg_audio_din_en <= "00";
		end if;
	end if;
end process;

process (resetn, clk)
begin
	if resetn = '0' then
		reg_audio_dout_en <= "00";
	elsif clk'event and clk = '1' then
		if record_routine = play then
			reg_audio_dout_en <= reg_audio_dout_en(0) & audio_dout_en;
		else
			reg_audio_dout_en <= "00";
		end if;
	end if;
end process;

process (resetn, clk)
begin
	if resetn = '0' then
		cnt_rec_data <= (others => '0');
	elsif clk'event and clk = '1' then
		if record_routine = recording then
			if reg_audio_din_en = "01" then
				if cnt_rec_data = x"3FFFF" then
					cnt_rec_data <= (others => '0');
				else
					cnt_rec_data <= cnt_rec_data + 1;
				end if;
			end if;
		else
			cnt_rec_data <= (others => '0');
		end if;
	end if;
end process;

process (resetn, clk)
begin
	if resetn = '0' then
		cnt_play_data <= (others => '0');
	elsif clk'event and clk = '1' then
		if record_routine = play then
			if reg_audio_dout_en = "01" then
				if cnt_play_data = cnt_record_max then
					cnt_play_data <= (others => '0');
				else
					cnt_play_data <= cnt_play_data + 1;
				end if;
			end if;
		else
			cnt_play_data <= (others => '0');
		end if;
	end if;
end process;

process (resetn, clk)
begin
	if resetn = '0' then
		reg_audio_dout <= (others => '0');
	elsif clk'event and clk = '1' then
		if record_routine = play then
			reg_audio_dout <= sram_data & sram_data;
		else
			reg_audio_dout <= (others => '0');
		end if;
	end if;
end process;

audio_dout <= reg_audio_dout;

sram_add <= cnt_rec_data when record_routine = recording else
            cnt_play_data when record_routine = play else
            (others => '0');

sram_data <= audio_din(15 downto 0) when audio_din_en = '1' else (others => 'Z');

sram_cs <= '0';
sram_we <= not audio_din_en when record_routine = recording else '1';
sram_oe <= '0' when record_routine = play else '1';


led_record <= '1' when record_routine = recording else '0';
led_play <= '1' when record_routine = play else '0';

end architecture a;