---------------TESTBENCH for MAIN entity--------------

library work;
use work.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use std.textio.all;

entity cputest is 
end entity;

architecture behv of cputest is
	component IITB_RISC is
	port
		(
			clk, rst, mem_write : in std_logic; 
			writing_addr, instruction : in std_logic_vector(15 downto 0);
			r0 : out std_logic_vector(15 downto 0);
			r1 : out std_logic_vector(15 downto 0);
			r2 : out std_logic_vector(15 downto 0);
			r3 : out std_logic_vector(15 downto 0);
			r4 : out std_logic_vector(15 downto 0);
			r5 : out std_logic_vector(15 downto 0);
			r6 : out std_logic_vector(15 downto 0);
			r7 : out std_logic_vector(15 downto 0)

		);
	end component;
	
	signal writing_addr, instruction, r0,r1,r2,r3,r4,r5,r6,r7 : std_logic_vector(15 downto 0);
	signal clk : std_logic := '1';
	signal rst, mem_write : std_logic;
	
begin
	dut_instance: IITB_RISC
		port map (writing_addr => writing_addr, instruction => instruction, clk => clk, rst => rst, mem_write => mem_write, r0 => r0, r1 => r1, r2 => r2, r3 => r3, r4 => r4, r5 => r5, r6 => r6, r7=> r7);
	
	
	process 
		file in_file : text open read_mode is "C:\Users\Dell\Downloads\Final Project\Code\bin.txt";
--		file_open(in_file, "E:\Quartus_files\RLEencoder\input.txt", read_mode);
		file out_file : text open write_mode is "C:\Users\Dell\Downloads\Final Project\Code\out.txt";
		variable in_line, out_line : line;
		variable in_var, out_var : std_logic_vector(15 downto 0) := "0000000000000000";
		variable count : integer range 0 to 32;
		variable curr : integer range 0 to 32;
		
		begin
			count := 0;
			curr := 0;
			writing_addr <= "0000000000000000"; --initialize writing address
			
			-- load instructions in memory
			while not endfile(in_file) loop
				readline (in_file, in_line);
				read (in_line, in_var);
				rst <= '1';
				clk <= '1';
				instruction <= in_var;
				mem_write <= '1';
				wait for 100 ns;
				clk <= '0';
				wait for 100 ns;
				writing_addr <= std_logic_vector ( unsigned(writing_addr) + 1);
				count := count + 1;
			end loop;
			
			-- execute instructions
			rst <= '1';
			mem_write <= '0';
			clk <= '1';
			wait for 100 ns;
			clk <= '0';
			wait for 100 ns;
	
			rst <= '0';
			for i in 1 to 1000 loop
				clk <= '1';
				wait for 100 ns;
				clk <= '0';
				wait for 100 ns;
				if ( r0 /= out_var) then
					out_var := r0;
					write(out_line, out_var);
					writeline(out_file, out_line);
				end if;
			end loop;
	wait;
	end process;
end architecture;