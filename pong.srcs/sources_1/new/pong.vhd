----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.11.2021 12:38:53
-- Design Name: 
-- Module Name: pong - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pong is
  generic (H: integer:= 640;
           HFP: integer:= 16;
           HS: integer:= 96;
           HBP: integer:=48;
           V: integer:= 480;
           VFP: integer:= 10;
           VS: integer:= 2;
           VBP: integer:= 33;
           BALL_SIZE: integer:= 16;
           BALL_SPEED: integer:=4;
           BORDER: integer:=8;
           PADDLE_WIDTH: integer:= 16;
           PADDLE_HEIGHT: integer:= 64;
           PADDLE_SPEED: integer:=4
           );
  
  
  Port ( 
    clk: in std_logic:='0';
    vgaRed, vgaBlue, vgaGreen : out std_logic_vector(3 downto 0):=(others => '0');
    Hsync, Vsync: out std_logic;
    btnC, btnU, btnD, btnL, btnR: in std_logic;
    led: out std_logic_vector(15 downto 0):=(others => '0')
  );
end pong;

architecture Behavioral of pong is

component clk_wiz_0 is port(
	clk_in1 : in std_logic;
	clk_out1 : out std_logic
	);
end component;

signal clk25: std_logic:='0';
signal VsyncSignal: std_logic:='0';

signal ball: std_logic:='0';
signal borderSignal: std_logic:='0';
signal pixel: std_logic:='0';

signal h_cnt: std_logic_vector(9 downto 0):=(others => '0');
signal v_cnt: std_logic_vector(9 downto 0):=(others => '0');

signal ball_x: std_logic_vector(9 downto 0):=std_logic_vector(to_unsigned((HS + HBP + (H - BALL_SIZE)/2),10));
signal ball_y: std_logic_vector(9 downto 0):=std_logic_vector(to_unsigned((VS + VBP + (V - BALL_SIZE)/2),10));
signal ball_move_x: std_logic:='0';
signal ball_move_y: std_logic:='0';

signal paddle_0_y: std_logic_vector(9 downto 0):=std_logic_vector(to_unsigned((VS + VBP + (V - PADDLE_HEIGHT)/2),10));
signal paddle_1_y: std_logic_vector(9 downto 0):=std_logic_vector(to_unsigned((VS + VBP + (V - PADDLE_HEIGHT)/2),10));
signal paddle_0: std_logic:='0';
signal paddle_1: std_logic:='0';
signal ball_hits_paddle_0: std_logic:='0';
signal ball_hits_paddle_1: std_logic:='0';
signal ball_exits_right: std_logic:='0';
signal ball_exits_left: std_logic:='0';
signal game_running: std_logic:='1';

begin

pll0: clk_wiz_0 port map(
	clk_in1 => clk,
	clk_out1 => clk25
);

process(h_cnt, v_cnt, paddle_0_y, paddle_1_y, ball_x, ball_y)

begin

if (h_cnt >= ball_x) AND (unsigned(h_cnt) < unsigned(ball_x) + BALL_SIZE) AND (v_cnt >= ball_y) AND (unsigned(v_cnt) < unsigned(ball_y) + BALL_SIZE) 
then
    ball <= '1';
else
    ball <= '0';
end if;

if (unsigned(h_cnt) >= HS+HBP) AND (unsigned(h_cnt) < HS+HBP+H) AND (((unsigned(v_cnt) >= VS+VBP) AND (unsigned(v_cnt) < VS+VBP+BORDER)) OR ((unsigned(v_cnt) >= VS+VBP+V-BORDER) AND (unsigned(v_cnt) < VS+VBP+V)))
then
    borderSignal <= '1';
else
    borderSignal <= '0';
end if;

if (unsigned(h_cnt) >= HS+HBP) AND (unsigned(h_cnt) < HS+HBP+PADDLE_WIDTH) AND (unsigned(v_cnt) >= unsigned(paddle_0_y)) AND (unsigned(v_cnt) < (unsigned(paddle_0_y) + PADDLE_HEIGHT))
then
    paddle_0 <= '1';
else
    paddle_0 <= '0';
end if;

if (unsigned(h_cnt) >= HS+HBP+H-PADDLE_WIDTH) AND (unsigned(h_cnt) < HS+HBP+H) AND (unsigned(v_cnt) >= unsigned(paddle_1_y)) AND (unsigned(v_cnt) < (unsigned(paddle_1_y) + PADDLE_HEIGHT))
then
    paddle_1 <= '1';
else
    paddle_1 <= '0';
end if;

if (unsigned(ball_x) < HS+HBP+PADDLE_WIDTH) AND (unsigned(ball_y) > unsigned(paddle_0_y) - BALL_SIZE) AND (unsigned(ball_y) < unsigned(paddle_0_y) + PADDLE_HEIGHT) then
    ball_hits_paddle_0 <= '1';
else
    ball_hits_paddle_0 <= '0';
end if;

if (unsigned(ball_x) > HS+HBP+H-PADDLE_WIDTH-BALL_SIZE) AND (unsigned(ball_y) > unsigned(paddle_1_y) - BALL_SIZE) AND (unsigned(ball_y) < unsigned(paddle_1_y) + PADDLE_HEIGHT) then
    ball_hits_paddle_1 <= '1';
else
    ball_hits_paddle_1 <= '0';
end if;

if (unsigned(ball_x) <= HS+HBP) then
    ball_exits_left <= '1';
else
    ball_exits_left <= '0';
end if;

if (unsigned(ball_x) >= HS+HBP+H-BALL_SIZE) then
    ball_exits_right <= '1';
else
    ball_exits_right <= '0';
end if;

pixel <= ball OR borderSignal OR paddle_0 OR paddle_1;

led(0) <= btnL;
led(1) <= btnR;
led(2) <= btnD;
led(3) <= btnU;

if (pixel = '1') then
    vgaRed <= (others => '1');
    vgaBlue <= (others => '1');
    vgaGreen <= (others => '1');
else
    vgaRed <= (others => '0');
    vgaBlue <= (others => '0');
    vgaGreen <= (others => '0');
end if;

end process;

process begin

wait until rising_edge(VsyncSignal);
    if (ball_exits_left = '1') OR (ball_exits_right = '1') then
        game_running <= '0';
    else
    end if;
    
    if (btnC = '1') then
        game_running <= '1';
    else
    end if;

end process;

process begin

wait until rising_edge(clk25);

    if (unsigned(h_cnt) =  HS+HBP+H+HFP-1) then
        h_cnt <= (others => '0');
    else
        h_cnt <= std_logic_vector(unsigned(h_cnt) + 1);
    end if;
    
    if (unsigned(h_cnt) >= HS) then
        Hsync <= '1';
    else
        Hsync <= '0';
    end if;
 
end process;

process begin

wait until rising_edge(clk25);
if (unsigned(h_cnt) = 0) then
    if (unsigned(v_cnt) =  VS+VBP+V+VFP-1) then
        v_cnt <= (others => '0');
    else
        v_cnt <= std_logic_vector(unsigned(v_cnt) + 1);
    end if;
    
    if (unsigned(v_cnt) >= VS) then
        Vsync <= '1';
        VsyncSignal <= '1';
    else
        Vsync <= '0';
        VsyncSignal <= '0';
    end if;
else
end if;
end process;

process begin

wait until rising_edge(VsyncSignal);
    if (btnL = '1' AND (unsigned(paddle_0_y) > VS + VBP + BORDER)) then
        paddle_0_y <= std_logic_vector(unsigned(paddle_0_y) - PADDLE_SPEED);
    else 
    end if;
    if (btnR = '1' AND (unsigned(paddle_0_y) < VS + VBP + V - BORDER - PADDLE_HEIGHT)) then
        paddle_0_y <= std_logic_vector(unsigned(paddle_0_y) + PADDLE_SPEED);
    else 
    end if;
    if (btnU = '1' AND (unsigned(paddle_1_y) > VS + VBP + BORDER)) then
        paddle_1_y <= std_logic_vector(unsigned(paddle_1_y) - PADDLE_SPEED);
    else 
    end if;
    if (btnD = '1' AND (unsigned(paddle_1_y) < VS + VBP + V - BORDER - PADDLE_HEIGHT)) then
        paddle_1_y <= std_logic_vector(unsigned(paddle_1_y) + PADDLE_SPEED);
    else 
    end if;    
end process;

process begin

wait until rising_edge(VsyncSignal);
    if (ball_hits_paddle_0 = '1' OR ball_exits_left = '1') then
        ball_move_x <= '1';
    else
    end if;
    
    if (ball_hits_paddle_1 = '1' OR ball_exits_right = '1') then
        ball_move_x <= '0';
    else
    end if;
    
    if (unsigned(ball_y) < VS+VBP+BORDER) then
        ball_move_y <= '1';
    else
    end if;
    
    if (unsigned(ball_y) >= VS+VBP+V-BORDER-BALL_SIZE) then
        ball_move_y <= '0';
    else
    end if;
    
    if (game_running = '1') then
        if (ball_move_x = '1') then
            ball_x <= std_logic_vector(unsigned(ball_x) + BALL_SPEED);
        else
            ball_x <= std_logic_vector(unsigned(ball_x) - BALL_SPEED);
        end if;
    
        if (ball_move_y = '1') then
            ball_y <= std_logic_vector(unsigned(ball_y) + BALL_SPEED);
        else
            ball_y <= std_logic_vector(unsigned(ball_y) - BALL_SPEED);
        end if;
    else
        ball_x <= std_logic_vector(TO_UNSIGNED(HS + HBP + (H - BALL_SIZE)/2, ball_x'length));
        ball_y <= std_logic_vector(TO_UNSIGNED(VS + VBP + (V - BALL_SIZE)/2, ball_y'length));
    end if;
end process;

end Behavioral;
