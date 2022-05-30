library work;
use work.all;

library ieee;
use ieee.std_logic_1164.all;

entity IITB_RISC is
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
end entity;

architecture RISC_arch of IITB_RISC is
	signal upd_ir, upd_pc, trc, pc_c, upd_c, upd_z : std_logic;	
	signal m_we, m_rac, m_wac : std_logic;
	signal rf_we : std_logic;
	signal rf_rc : std_logic;
	signal rf_wc, rf_dc : std_logic_vector(1 downto 0);
	signal rf_master : std_logic_vector(2 downto 0);
	signal alu_cin : std_logic;
	signal alu_op : std_logic_vector(1 downto 0);
	signal alu_ac, alu_bc : std_logic_vector(1 downto 0);
	signal zc : std_logic;
	signal ir : std_logic_vector(15 downto 0);
	signal c,z : std_logic;
	signal z_imm : std_logic;
	
	signal first: std_logic;
	signal PEinput: std_logic_vector(7 downto 0);
	signal next_input: std_logic_vector(7 downto 0);
	signal prev_next_input: std_logic_vector(7 downto 0);


	component controller
		port 
			(
				clk, rst : in std_logic;
				
				m_we, m_rac, m_wac : out std_logic;
				
				upd_ir, upd_pc, trc, pc_c, upd_c, upd_z : out std_logic;
				
				alu_op: out std_logic_vector(1 downto 0);
				alu_cin : out std_logic;
				alu_ac, alu_bc : out std_logic_vector(1 downto 0);
				
				rf_we : out std_logic;
				rf_rc : out std_logic;
				rf_wc, rf_dc : out std_logic_vector(1 downto 0);
				rf_master : buffer std_logic_vector(2 downto 0) := "000";
				
				zc : out std_logic;
				
				ir : in std_logic_vector(15 downto 0);
				c,z : in std_logic;
				z_imm : in std_logic;
				first: buffer std_logic := '1';
				PEinput: buffer std_logic_vector(7 downto 0) := "00000000";
				next_input: buffer std_logic_vector(7 downto 0) := "00000000";
				prev_next_input: buffer std_logic_vector(7 downto 0) := "00000000"
			);
	end component;

	component datapath
		port
			(
				clk : in std_logic;
				master_data, master_wa : in std_logic_vector (15 downto 0);
				master_wc : in std_logic;
				
				m_we, m_rac, m_wac : in std_logic;
				
				upd_ir, upd_pc, trc, pc_c, upd_c, upd_z : in std_logic;
				
				alu_op : in std_logic_vector(1 downto 0);
				alu_cin : in std_logic;
				alu_ac, alu_bc : in std_logic_vector(1 downto 0);
				
				rf_we : in std_logic;
				rf_rc : in std_logic;
				rf_wc, rf_dc : in std_logic_vector(1 downto 0);
				rf_master : in std_logic_vector(2 downto 0);
				
				zc : in std_logic;
				ir : buffer std_logic_vector(15 downto 0);
				c,z : buffer std_logic;
				z_imm : out std_logic;
				
				r0,r1,r2,r3,r4,r5,r6,r7 : out std_logic_vector(15 downto 0)
			);
	end component;

begin
	dp : datapath
		port map (clk => clk, master_data => instruction, master_wa => writing_addr, master_wc => mem_write, m_we => m_we, m_rac => m_rac, m_wac => m_wac, upd_ir => upd_ir, upd_pc => upd_pc, trc => trc, pc_c => pc_c, upd_c => upd_c, upd_z => upd_z, alu_op => alu_op, alu_cin => alu_cin, alu_ac => alu_ac, alu_bc => alu_bc, rf_we => rf_we, rf_rc => rf_rc, rf_wc => rf_wc, rf_dc => rf_dc, rf_master => rf_master, zc => zc, ir => ir, c => c, z => z, z_imm => z_imm, r0 => r0, r1 => r1, r2 => r2, r3 => r3, r4 => r4, r5 => r5, r6 => r6, r7 => r7);
	con : controller
		port map (clk => clk, rst => rst, m_we => m_we, m_rac => m_rac, m_wac => m_wac, upd_ir => upd_ir, upd_pc => upd_pc, trc => trc, pc_c => pc_c, upd_c => upd_c, upd_z => upd_z, alu_op => alu_op, alu_cin => alu_cin, alu_ac => alu_ac, alu_bc => alu_bc, rf_we => rf_we, rf_rc => rf_rc, rf_wc => rf_wc, rf_dc => rf_dc, rf_master => rf_master, zc => zc, ir => ir, c => c, z => z, z_imm => z_imm, PEinput => PEinput, first => first, next_input => next_input, prev_next_input => prev_next_input);
end architecture;