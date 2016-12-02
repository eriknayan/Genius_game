-- Package global que implementa os tipos necessários no projeto, bem como procedures e constantes

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.rom_characters.all;

package global_pack is

	type states is (idle, print, dly, waiting, upack, dbc, downack, nextlvl, gg, ff); -- Estados da máquina
	type pa_ed is array (22 downto 0) of std_logic_vector (6 downto 0); -- Arranjo da mensagem inicial
	type score is array (3 downto 0) of std_logic_vector (6 downto 0); -- Arranjo da pontuação
	type enable is array (3 downto 0) of std_logic_vector (3 downto 0); -- Arranjo dos estados dos anodos
	type sequence is array (14 downto 0) of std_logic_vector (3 downto 0); -- Arranjo de uma sequência
	
	-- Constantes que definem as sequências possiveis de 14 cores para o jogo
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
	
	type mult_seq is array (9 downto 0) of sequence; -- Arranjo das 10 sequências pré-definidas
	
	constant sequences: mult_seq := (seq9, seq8, seq7, seq6, seq5, seq4, seq3, seq2, seq1, seq0); -- Constante com as 10 sequências criadas
	
	-- Declaração da procedure que imprime os caracteres na região superior do monitor
	procedure characters (h_count, v_count: in integer; 
								 first_char, secon_char: in char_data; 
								 red: out std_logic_vector (2 downto 0);
								 green: out std_logic_vector (2 downto 0);
								 blue: out std_logic_vector (1 downto 0));
	
	
end global_pack;

package body global_pack is

	-- Procedure que recebe os valores de caracteres e estabelece a lógica para impressão na tela
	procedure characters (h_count, v_count: in integer; 
								 first_char, secon_char: in char_data; 
								 red: out std_logic_vector (2 downto 0);
								 green: out std_logic_vector (2 downto 0);
								 blue: out std_logic_vector (1 downto 0)) is
								 
	begin
	
		if (h_count>250 and h_count<400 and v_count>50 and v_count<250) then
			if (first_char(v_count-50)(h_count-225)='1') then
				red := (others => '1');
				green := (others => '1');
				blue := (others => '1');
			else
				red := (others => '0');
				green := (others => '0');
				blue := (others => '0');
			end if;
		elsif (h_count>400 and h_count<550 and v_count>50 and v_count<250) then
			if (secon_char(v_count-50)(h_count-375)='1') then
				red := (others => '1');
				green := (others => '1');
				blue := (others => '1');
			else
				red := (others => '0');
				green := (others => '0');
				blue := (others => '0');
			end if;
		end if;
						
	end characters;
	
end package body;