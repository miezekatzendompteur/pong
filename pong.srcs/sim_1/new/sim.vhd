----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.11.2021 14:16:31
-- Design Name: 
-- Module Name: sim - Behavioral
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

entity sim is
--  Port ( );
end sim;

architecture Behavioral of sim is

signal clk: std_logic:='0';
signal vgaRed, vgaBlue, vgaGreen : std_logic_vector(3 downto 0):=(others => '0');
signal Hsync, Vsync: std_logic:= '0';
signal btnC, btnU, btnD, btnL, btnR: std_logic:= '0';
signal led: std_logic_vector(15 downto 0):=(others => '0');

constant clk_in_half_period : time := 5 ns;


begin

uut: entity work.pong port map(
    clk,
    vgaRed,
    vgaBlue,
    vgaGreen,
    Hsync,
    Vsync,
    btnC,
    btnU,
    btnD,
    btnL,
    btnR,
    led
);

tb:process
begin
    clk <= '0';
    wait for clk_in_half_period;
    clk <= '1';
    wait for clk_in_half_period;
end process tb;

sim:process
begin
    btnD <= '0';
    
    wait for clk_in_half_period * 10;
    
    btnD <= '1';
    
    wait for clk_in_half_period * 10;
    
    btnR <= '1';
    
    wait for clk_in_half_period * 10;
    
    btnR <= '1';
    
    wait for clk_in_half_period * 10;
end process sim;


end Behavioral;
