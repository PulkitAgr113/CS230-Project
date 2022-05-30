library work;
use work.all;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity controller is
	port 
		(
			clk, rst : in std_logic;
			
			upd_ir, upd_pc, trc, pc_c, upd_c, upd_z : out std_logic;

			m_we, m_rac, m_wac : out std_logic;

			rf_we : out std_logic;
			rf_rc : out std_logic;
			rf_wc, rf_dc : out std_logic_vector(1 downto 0);
			rf_master : buffer std_logic_vector(2 downto 0) := "000";
			
			alu_cin : out std_logic;
			alu_ac, alu_bc : out std_logic_vector(1 downto 0);
			alu_op : out std_logic_vector(1 downto 0);
			
			zc : out std_logic;
			
			ir : in std_logic_vector(15 downto 0);
			c,z : in std_logic;
			z_imm : in std_logic;
			first: buffer std_logic := '1';
			PEinput: buffer std_logic_vector(7 downto 0) := "00000000";
			next_input: buffer std_logic_vector(7 downto 0) := "00000000";
			prev_next_input: buffer std_logic_vector(7 downto 0)
		);
end entity;

architecture controller_arch of controller is

	component PriorityEncoder is
	port
		(
			input: in std_logic_vector(7 downto 0);
			empty: out std_logic;
			output: out std_logic_vector(7 downto 0);
			reg: out std_logic_vector(2 downto 0)
		);
	end component;


	subtype states is natural range 0 to 10;
	signal state : states := 0;
	signal next_state : states;
	signal lol: std_logic_vector(2 downto 0) := "000";
	signal empty: std_logic := '0';
	
begin

	PE: PriorityEncoder
	port map(input => PEinput, empty => empty, output => next_input, reg => rf_master);

	PEinput <= ir(7 downto 0) when (first = '1') else prev_next_input;
	init : process(state, ir)
	begin

		m_we <= '0';
		alu_op <= "01";
		alu_cin <= '0';
		alu_ac <= "00";
		alu_bc <= "00";
		m_rac <= '0';
		m_wac <= '0';
		upd_ir <= '0';
		upd_pc <= '0';
		trc <= '0';
		pc_c <= '0';
		upd_c <= '0';
		upd_z <= '0';
		rf_we <= '0';
		rf_rc <= '0';
		rf_wc <= "00";
		rf_dc <= "00";
		zc <= '0';
		
		case state is 
			when 0 =>
				next_state <= 1; 
				
			when 1 =>
				upd_ir <= '1';		
				next_state <= 2;
				
			when 2 =>
				if 
				((ir(15 downto 12) = "0001" or ir(15 downto 12) = "0010") and
				(ir(1 downto 0) = "00" or (ir(1 downto 0) = "10" and c = '1') or 
				(ir(1 downto 0) = "01" and z = '1') or (ir(1 downto 0) = "11"))) then
					upd_c <= ir(13);
					upd_z <= '1';
					rf_wc <= "10";
					rf_dc <= "01";
					rf_we <= '1';

					if(ir(13) = '1') then
						alu_op <= "00";
					elsif(ir(1 downto 0) = "11") then
						alu_op <= "10";
					else
						alu_op <= "01";
					end if;

					next_state <= 3;
				
				-- for ADI
				elsif (ir(15 downto 12) = "0000") then
					upd_c <= '1';
					upd_z <= '1';
					rf_wc <= "01";
					rf_dc <= "01";
					rf_we <= '1';
					alu_bc <= "10";
					next_state <= 3;
				
				-- for LHI
				elsif (ir(15 downto 12) = "1111") then
					rf_dc <= "11";
					alu_ac <= "10";
					alu_bc <= "01";
					rf_we <= '1';
					upd_pc <= '1';
					next_state <= 0;
				-- LM

				elsif (ir(15 downto 12) = "1101") then
					trc <= '1'; -- trc decides whether tr_combine is alu_o or rf_out1
					next_state <= 8;

				-- SM
				elsif (ir(15 downto 12) = "1100") then
					trc <= '1';
					next_state <= 7;
					
				elsif (ir(15 downto 12) = "0101") then
					alu_ac <= "01";
					next_state <= 4;
				
				elsif (ir(15 downto 12) = "0111") then
					alu_ac <= "01";
					m_wac <= '1';
					m_we <= '1';
					next_state <= 3;
				
				elsif (ir(15 downto 12) = "1000") then
					alu_cin <= '1';
					next_state <= 6;

				elsif (ir(15 downto 12) = "1011") then
					alu_bc <= "10";
					pc_c <= '0';
					upd_pc <= '1';
					next_state <= 0;

				elsif (ir(15 downto 12) = "1001") then
					rf_dc <= "10";
					rf_we <= '1';
					alu_ac <= "10";
					alu_bc <= "11";
					upd_pc <= '1';
					next_state <= 0;
				
				elsif (ir(15 downto 12) = "1010") then
					rf_dc <= "10";
					rf_we <= '1';
					pc_c <= '1';
					upd_pc <= '1';
					next_state <= 0;
				
				else
					next_state <= 0;
				end if;
			
			when 3 =>
				
					alu_ac <= "10";
					alu_bc <= "01";
					upd_pc <= '1';
					next_state <= 0;
			
			when 4 =>
				m_rac <= '1';
				next_state <= 5;
			
			when 5 =>
				rf_we <= '1';
				zc <= '1';
				upd_pc <= '1';
				alu_ac <= "10";
				alu_bc <= "01";
				next_state <= 0;
			

			when 6 =>
				alu_ac <= "10";
				upd_pc <= '1';
					
				if (z_imm = '1') then
					alu_bc <= "10";
				else 
					alu_bc <= "01";
				end if;
				next_state <= 0;
				
			when 7 =>
				rf_rc <= '1';
				m_we <= '1';
				alu_ac <= "11";
				alu_bc <= "01";
			
			when 8 =>
			-- Sets memory address for reading as trc, which is register value initially, later its alu output
				m_rac <= '1';
				alu_ac <= "11";
				alu_bc <= "01";
				next_state <= 9;
				
			when 9 =>
				m_rac <= '1';
				alu_ac <= "11";
				alu_bc <= "01";
				rf_we <= '1';
				rf_wc <= "11";
		
			when 10 =>
				rf_we <= not empty;
				rf_wc <= "11";
				next_state <= 3;
				
			when others => null;
		end case;
	end process;

	fin : process(clk)
	begin
		if rising_edge(clk) then
			if (rst = '1') then
				state <= 0;
			else
				case state is
					when 9 =>

						first <= '0';
						if( next_input = "00000000") then
							state <= 3;
							first <= '1';
						end if;


						
					when 7 =>
						
						first <= '0';
						
						if(next_input = "00000000") then
							state <= 3;
							first <= '1';
						
						end if;		

					when others => 
						state <= next_state;
				end case;
				
				prev_next_input <= next_input;
			end if;
		end if;
	end process;
end architecture;