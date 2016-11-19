library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.global_pack.all;

entity Decoder is

	generic ( f: integer := 4000;
				 l: integer := 25000000);
	port ( clk, reset: in std_logic;
	       display: out std_logic_vector (6 downto 0);
			 anode: out std_logic_vector (3 downto 0);
			 pr_state: in states;
			 lvl: in integer range 1 to 14);

end Decoder;

architecture Behavioral of Decoder is

	signal i: integer range 0 to 3 := 3;
	signal j: integer range 0 to 19 := 19;
	signal count_f: integer range 0 to f := f;
	signal count_l: integer range 0 to l := l;
	signal pont: score := ("1111111","1111111","1111111","1111111");
	constant anodos: enable := ("0111","1011","1101","1110");
	constant gameover: score := ("0111000","0001000","1001111","1110001");
	constant win: score := ("1111111","0100000","0100000","1111111"); 
	constant projeto_aplic: pa_ed := ("0011000","1111010","0000001","1000011","0110000","1110000","0000001",
	"1111111","0001000","0011000","1110001","1001111","0110001","0001000","1110000","1001111","1000001",
	"0000001","1111110","0110000","1000010","1111111","1111111");
	
begin
	
	process(clk, lvl, reset, pr_state)
	begin
		
		if ( reset='1' ) then
			i<=3;
			j<=19;
			count_l<=l;
			count_f<=f;
		
		elsif ( rising_edge(clk) ) then
			count_f<=count_f-1;
			count_l<=count_l-1;
			if (count_f=0) then
				count_f<=f;
				i<=i-1;
				if (i=0) then
					i<=3;
				end if;
			end if;
			if (count_l=0) then
				count_l<=l;
				j<=j-1;
				if (j=0) then
					j<=19;
				end if;
			end if;	
		end if;
		
		case lvl is
				
				when 1 => pont <= ("1111111","0000001","0000001","1111111");
				
				when 2 => pont <= ("1111111","0000001","1001111","1111111");
				
				when 3 => pont <= ("1111111","0000001","0010010","1111111");
				
				when 4 => pont <= ("1111111","0000001","0000110","1111111");
				
				when 5 => pont <= ("1111111","0000001","1001100","1111111");
				
				when 6 => pont <= ("1111111","0000001","0100100","1111111");
				
				when 7 => pont <= ("1111111","0000001","0100000","1111111");
				
				when 8 => pont <= ("1111111","0000001","0001111","1111111");
				
				when 9 => pont <= ("1111111","0000001","0000000","1111111");
				
				when 10 => pont <= ("1111111","0000001","0000100","1111111");
				
				when 11 => pont <= ("1111111","1001111","0000001","1111111");
				
				when 12 => pont <= ("1111111","1001111","1001111","1111111");
				
				when 13 => pont <= ("1111111","1001111","0010010","1111111");
				
				when 14 => pont <= ("1111111","1001111","0000110","1111111");
		
		end case;
		
		case pr_state is
			
				when idle =>  display <= projeto_aplic(i+j);
								 
			   when ff => display <= gameover(i);
				
				when gg => display <= win(i);
				
				when others => display <= pont(i);
									
		end case;
		
		anode <= anodos(i);
	
	end process;


end Behavioral;