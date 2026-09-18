library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity stop_watch is
	port(
		clk : in std_logic;
		stop : in std_logic;
		lap : in std_logic;
		
		led_data : out std_logic_vector(4 downto 0);
		seg_com : out std_logic_vector(7 downto 0);
		seg_data : out std_logic_vector(7 downto 0)
		);
end stop_watch;

architecture gk of stop_watch is

type watch_state is(
	start,
	count,
	lap_count,
	lap_uncount,
	stop_uncount
	);
signal mode : watch_state;

signal cnt : integer range 0 to 7;
signal num : integer range 0 to 15;
signal hour : integer range 0 to 99;
signal min, sec : integer range 0 to 99;
signal hectosec : integer range 0 to 99;
signal h10, h1, m10, m1, s10, s1, hs10, hs1 : integer range 0 to 9;
signal cnts : integer range 0 to 9999;
signal hs_en, s_en, m_en, h_en : std_logic;
signal reset : std_logic;
signal stop_tmp, lap_tmp : std_logic;
signal count_on, display_on : std_logic;
signal led_signal : std_logic_vector(4 downto 0);
signal dot_ctrl, dot : std_logic;

-- signal for syncronizing to clk
signal reg_hs_en : std_logic;
signal reg_s_en : std_logic;
signal reg_m_en : std_logic;
signal reg_h_en : std_logic;

signal clk_1mhz	: std_logic;
signal cnt_1mhz	: integer range 0 to 24;

--components pin assinge
component sep
port(
	number : in integer range 0 to 127;
	ten, one : out integer range 0 to 15
	);
end component;

component decod
port(
	bcd : in integer range 0 to 15;
	dot : in std_logic;
	seg_data : out std_logic_vector(7 downto 0)
	);
end component;

--architecture body's start
begin

-- components
hs_sep : sep
	port map(hectosec, hs10, hs1);
s_sep : sep
	port map(sec, s10, s1);
m_sep : sep
	port map(min, m10, m1);
h_sep : sep
	port map(hour, h10, h1);
	
s7 : decod
	port map(num, dot_ctrl, seg_data);
	
--clk_div : 50mhz => 1mhz
process(clk)
begin
if clk'event and clk = '1' then
	if cnt_1mhz = 24 then
		cnt_1mhz <= 0;
		clk_1mhz <= not clk_1mhz;
	else
		cnt_1mhz <= cnt_1mhz + 1;
	end if;
end if;
end process;
		
--to state view
process(clk_1mhz)
begin
	if clk_1mhz'event and clk_1mhz = '1' then
		case mode is
			when start =>
				led_signal <= "00001";
			when count =>
				led_signal <= "00010";
			when lap_count =>
				led_signal <= "00100";
			when lap_uncount =>
				led_signal <= "01000";
			when stop_uncount =>
				led_signal <= "10000";
			when others =>
				led_signal <= "00000";
		end case;
		led_data <= led_signal;
	end if;
end process;

-- reset signal ganerater
process(clk_1mhz)
variable rst_cnt : integer range 0 to 127;
begin
	if clk_1mhz'event and clk_1mhz = '1' then
		if rst_cnt >= 64 then
			rst_cnt := rst_cnt;
			reset <= '1';
		else
			rst_cnt := rst_cnt + 1;
			reset <= '0';			
		end if;
	end if;
end process;
			
--state machine
process(clk_1mhz, reset)
begin
	if reset = '0' then
		mode <= start;
	elsif clk_1mhz'event and clk_1mhz = '1' then
		stop_tmp <= stop;
		lap_tmp <= lap;
		case mode is
			--start(s0): initialize and wait
			when start =>
				-- control signal for count and 7-Segmant display
				count_on <= '0';
				display_on <= '1';
				if stop_tmp = '0' and stop = '1' then
					mode <= count;
				else
					mode <= mode;
				end if;
			--count(s1): count and display are startted
			when count =>
				count_on <= '1';
				display_on <= '1';
				if stop_tmp = '0' and stop = '1' then
					mode <= stop_uncount;
				elsif lap_tmp = '0' and lap = '1' then
					mode <= lap_count;
				else
					mode <= mode;
				end if;
			--(s2): count is continued, but display is stopped
			when lap_count =>
				count_on <= '1';
				display_on <= '0';
				if stop_tmp = '0' and stop = '1' then
					mode <= lap_uncount;
				elsif lap_tmp = '0' and lap = '1' then
					mode <= count;
				else
					mode <= mode;
				end if;
			--(s3): count and display are stopped
			when lap_uncount =>
				count_on <= '0';
				display_on <= '0';
				if stop_tmp = '0' and stop = '1' then
					mode <= lap_count;
				elsif lap_tmp = '0' and lap = '1' then
					mode <= stop_uncount;
				else
					mode <= mode;
				end if;
			--(s4): count is stopped, but display is continued
			when stop_uncount =>
				count_on <= '0';
				display_on <= '1';
				if stop_tmp = '0' and stop = '1' then
					mode <= count;
				elsif lap_tmp = '0' and lap = '1' then
					mode <= start;
				else
					mode <= mode;
				end if;
			when others =>
				mode <= start;
		end case;
	end if;
end process;

-- initializing the cnts and running count
process(clk_1mhz, mode)
begin
	if mode = start then
		cnts <= 0;
		hs_en <= '0';
	elsif clk_1mhz'event and clk_1mhz = '1' then
		if count_on = '1' then
			if cnts = 9999 then
				cnts <= 0;
				--enable signal generate for 1/100 second
				hs_en <= '1';
			else
				cnts <= cnts + 1;
				hs_en <= '0';
			end if;
		else
			cnts <= cnts;
		end if;
	end if;
end process;

-- All time events are syncronized by same clock (clk)
--1/100 second value define
process(clk_1mhz, mode)
begin
	if mode = start then
		hectosec <= 0;
		s_en <= '0';
	elsif clk_1mhz'event and clk_1mhz = '1' then
			reg_hs_en <= hs_en;
		if reg_hs_en = '0' and hs_en = '1' then
			if hectosec >= 99 then
				--enable signal for second
				s_en <= '1';
				hectosec <= 0;
			else
				hectosec <= hectosec + 1;
				s_en <= '0';
				-- generates signal for dot blink every second
				if hectosec >= 19 and hectosec < 99 then
					dot <= '1';
				else
					dot <= '0';
				end if;
			end if;
		end if;
	end if;
end process;


process(clk_1mhz, mode)
begin
	if mode = start then
		sec <= 0;
		m_en <= '0';
	elsif clk_1mhz'event and clk_1mhz = '1' then
		reg_s_en <= s_en;
		if reg_s_en = '0' and s_en = '1' then
			if sec >= 59 then
				--enable signal for minute
				m_en <= '1';
				sec <= 0;
			else
				sec <= sec + 1;
				m_en <= '0';
			end if;
		end if;
	end if;
end process;

process(clk_1mhz, mode)
begin
	if mode = start then
		min <= 0;
		h_en <= '0';
	elsif clk_1mhz'event and clk_1mhz = '1' then
		reg_m_en <= m_en;
		if reg_m_en = '0' and m_en = '1' then
			if min >= 59 then
				--enable signal for hour
				h_en <= '1';
				min <= 0;
			else
				min <= min + 1;
				h_en <= '0';
			end if;
		end if;
	end if;
end process;

process(clk_1mhz, mode)
begin
	if mode = start then
		hour <= 0;
	elsif clk_1mhz'event and clk_1mhz = '1' then
		reg_h_en <= h_en;
		if reg_h_en = '0' and h_en = '1' then
			if hour >= 23 then
				hour <= 0;
			else
				hour <= hour + 1;
			end if;
		end if;
	end if;
end process;

--7-Segment display
process(clk_1mhz)
variable reg_h10, reg_h1, reg_m10, reg_m1, reg_s10, reg_s1, reg_hs10, reg_hs1 : integer range 0 to 9;
begin
	if clk_1mhz'event and clk_1mhz = '1' then
		case cnt is
			when 0 =>
				dot_ctrl <= '0';	-- signal for time unit display
				seg_com <= "01111111";
				if display_on = '1' then
					reg_h10 := h10;
					num <= reg_h10;
				else
					num <= reg_h10;
				end if;
			when 1 =>
				dot_ctrl <= '1';
				seg_com <= "10111111";
				if display_on = '1' then
					reg_h1 := h1;
					num <= reg_h1;
				else
					num <= reg_h1;
				end if;
			when 2 =>
				dot_ctrl <= '0';
				seg_com <= "11011111";
				if display_on = '1' then
					reg_m10 := m10;
					num <= reg_m10;
				else
					num <= reg_m10;
				end if;
			when 3 =>
				dot_ctrl <= '1';
				seg_com <= "11101111";
				if display_on = '1' then
					reg_m1 := m1;
					num <= reg_m1;
				else
					num <= reg_m1;
				end if;
			when 4 =>
				dot_ctrl <= '0';
				seg_com <= "11110111";
				if display_on = '1' then
					reg_s10 := s10;
					num <= reg_s10;
				else
					num <= reg_s10;
				end if;
			when 5 =>
				dot_ctrl <= dot;
				seg_com <= "11111011";
				if display_on = '1' then
					reg_s1 := s1;
					num <= reg_s1;
				else
					num <= reg_s1;
				end if;
			when 6 =>
				dot_ctrl <= '0';
				seg_com <= "11111101";
				if display_on = '1' then
					reg_hs10 := hs10;
					num <= reg_hs10;
				else
					num <= reg_hs10;
				end if;
			when 7 =>
				dot_ctrl <= '1';
				seg_com <= "11111110";
				if display_on = '1' then
					reg_hs1 := hs1;
					num <= reg_hs1;
				else
					num <= reg_hs1;
				end if;
			when others =>
				cnt <= 0;
		end case;
		cnt <= cnt + 1;
	end if;
end process;

end gk;