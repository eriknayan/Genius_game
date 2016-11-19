library IEEE;
use IEEE.STD_LOGIC_1164.all;

package global_pack is

	type states is (idle, print, dly, waiting, upack, dbc, downack, nextlvl, gg, ff);
	type pa_ed is array (22 downto 0) of std_logic_vector (6 downto 0);
	type score is array (3 downto 0) of std_logic_vector (6 downto 0);
	type enable is array (3 downto 0) of std_logic_vector (3 downto 0);
	type sequence is array (14 downto 0) of std_logic_vector (3 downto 0);
	constant seq: sequence := ("0001","1000","0001","0010","0100","1000","1000",
	"0100","0010","0001","0001","0010","0100","1000", "0000");
	
	procedure colors (signal nibble: in std_logic_vector;
							variable h_count: in integer;
							signal red: out std_logic_vector (2 downto 0);
							signal green: out std_logic_vector (2 downto 0);
							signal blue: out std_logic_vector (1 downto 0));

end global_pack;

package body global_pack is

	procedure colors (signal nibble: in std_logic_vector;
							variable h_count: in integer;
							signal red: out std_logic_vector (2 downto 0);
							signal green: out std_logic_vector (2 downto 0);
							signal blue: out std_logic_vector (1 downto 0)) is
   begin						
	
		if (nibble="1000") then
			if (h_count<200) then
				red <= "111";
				green <= "000";
				blue <= "00";
			else
				red <= (others => '0');
				green <= (others => '0');
				blue <= (others => '0');
			end if;
		elsif (nibble="0100") then
			if (h_count>200 and h_count<400) then
				red <= "000";
				green <= "000";
				blue <= "11";
			else
				red <= (others => '0');
				green <= (others => '0');
				blue <= (others => '0');
			end if;
		elsif (nibble="0010") then
			if (h_count>400 and h_count<600) then
				red <= "111";
				green <= "111";
				blue <= "00";
			else
				red <= (others => '0');
				green <= (others => '0');
				blue <= (others => '0');
			end if;
		elsif (nibble="0001") then
			if (h_count>600 and h_count<800) then
				red <= "000";
				green <= "111";
				blue <= "00";
			else
				red <= (others => '0');
				green <= (others => '0');
				blue <= (others => '0');
			end if;
		end if;
		
	end colors;
							
end global_pack;


