
-------------------------------------------------------------------------------
-- Title      : interface VGA
-- Project    : 
-------------------------------------------------------------------------------
-- File       : interface_vga.vhd
-- Author     :   <nouel@SARE>
-- Company    : 
-- Last update: 2003/10/01
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: Utilise le mat‰riel lancelot
--            : http://wwww.fpga.nl
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2003/09/17  1.0      nouel	Created
-------------------------------------------------------------------------------



LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY interface_vga IS
  PORT(
    reset      	: IN  std_ulogic;         -- reset de l'interface
    clk		   	: IN  std_ulogic;         -- horloge pixel
    rgb        	: IN  std_logic_vector(23 DOWNTO 0);  -- 3 couleurs 
    red	     	: OUT std_logic_vector(7 DOWNTO 0);  -- entree 1er dac
    green	    : OUT std_logic_vector(7 DOWNTO 0);  -- entree 2eme dac
    blue	    : OUT std_logic_vector(7 DOWNTO 0);  -- entree 3eme dac
    line_pix   : OUT std_logic_vector(9 DOWNTO 0);  -- compteur lignes pixels
    colum_pix : OUT std_logic_vector(9 DOWNTO 0);  -- compteur colonnes pixels
    m1, m2      : OUT std_ulogic;         -- mode select dac
    blank_n     : OUT std_ulogic;          -- commande DAC
    sync_n      : OUT std_ulogic;         -- commande DAC
    sync_t      : OUT std_ulogic;         -- commande DAC
    video_clk   : OUT std_ulogic;         -- commande DAC
    vga_vs      : OUT std_ulogic;         -- sur connecteur VGA
    vga_hs      : OUT std_ulogic         -- sur connecteur VGA
    );
END interface_vga;


ARCHITECTURE hb OF interface_vga IS
  SIGNAL video_on_v, video_on_h : std_ulogic;
BEGIN  -- pour_lancelot
  -- signaux fixes
  m1 <= '0';
  m2 <= '0';
  sync_n <= '1';
  sync_t <= '0';
  video_clk <= clk;

  -- transmission immediate
  red <= rgb(23 DOWNTO 16);
  green <= rgb(15 DOWNTO 8);
  blue <= rgb(7 DOWNTO 0);
  
  timing: PROCESS
    VARIABLE c_v, c_h : natural RANGE 0 TO 1023;
    -- en horizontal, on doit compter de 0 € 
  BEGIN  -- PROCESS timing
    WAIT UNTIL rising_edge(clk);
    IF reset = '1'  THEN
      c_v := 0;
      c_h := 0;
    ELSE
      -- en horizontal, on doit compter 794 lignes
      IF c_h = 794 THEN
        c_h := 0;
        -- en vertical , on doit compter 525 lignes
        IF c_v = 525 THEN
          c_v := 0;
        ELSE
          c_v := c_v + 1;    
        END IF;
      ELSE
        c_h := c_h + 1;
      END IF;
      -- synchro horizontale
      IF c_h < 751 AND c_h >= 655 THEN
        vga_hs <= '0';
      ELSE
        vga_hs <= '1';                   
      END IF;
      -- synchro verticale
      IF c_v = 490 OR c_v = 489 THEN
        vga_vs <= '0';
      ELSE
        vga_vs <= '1';
      END IF;
      -- signal de blank
      IF c_h < 640 THEN
        video_on_h <= '1';
        colum_pix <= std_logic_vector(to_unsigned(c_h,10));
      ELSE
        video_on_h <= '0';
      END IF;
      IF c_v <  480 THEN
        video_on_v <= '1';
        line_pix <= std_logic_vector(to_unsigned(c_v, 10));
      ELSE
        video_on_v <= '0'; 
      END IF;
    END IF;
  END PROCESS timing;

  blank_n <= video_on_h AND video_on_v;
END hb;
