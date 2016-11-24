library IEEE;
use IEEE.STD_LOGIC_1164.all;

package global_pack is

	type states is (idle, print, dly, waiting, upack, dbc, downack, nextlvl, gg, ff);
	type pa_ed is array (22 downto 0) of std_logic_vector (6 downto 0);
	type score is array (3 downto 0) of std_logic_vector (6 downto 0);
	type enable is array (3 downto 0) of std_logic_vector (3 downto 0);
	type sequence is array (14 downto 0) of std_logic_vector (3 downto 0);
	
	constant seq0: sequence := ("0001","1000","0001","0010","0100","1000","1000",
	"0100","0010","0001","0001","0010","0100","1000", "0000");
	
	constant seq1: sequence := ("0001","1000","0001","0010","0100","0010","0100",
	"1000","0001","1000","0001","0100","0010","1000", "0000");
	
	constant seq2: sequence := ("0010","1000","0001","0010","0100","0010","1000",
	"0100","1000","0001","0001","0010","0100","0001", "0000");
	
	constant seq3: sequence := ("0100","0010","0001","0010","1000","1000","0100",
	"0001","0010","1000","0001","0010","0100","0100", "0000");
	
	constant seq4: sequence := ("0001","0001","1000","0010","0100","1000","1000",
	"1000","0010","0100","0001","0010","0100","0010", "0000");
	
	constant seq5: sequence := ("0100","1000","0010","0010","0100","1000","1000",
	"0100","0010","0001","1000","0010","0001","0001", "0000");
	
	constant seq6: sequence := ("1000","0010","0010","0010","0100","1000","0001",
	"0100","1000","0100","0001","0010","0100","0100", "0000");
	
	constant seq7: sequence := ("0001","1000","0010","0010","0100","1000","1000",
	"0100","0001","0010","0001","0001","1000","1000", "0000");
	
	constant seq8: sequence := ("0010","0001","0100","0001","0010","1000","0100",
	"0100","1000","0001","1000","0010","0100","0010", "0000");
	
	constant seq9: sequence := ("0100","1000","0001","0010","0010","1000","0001",
	"0100","1000","0001","0010","0001","0100","0001", "0000");
	
	type mult_seq is array (9 downto 0) of sequence;
	constant sequences: mult_seq :=(seq9, seq8, seq7, seq6, seq5, seq4, seq3, seq2, seq1, seq0);
	
end global_pack;