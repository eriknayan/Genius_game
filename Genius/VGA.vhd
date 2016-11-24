library ieee;
use ieee.std_logic_1164.all;
use work.global_pack.all;
use work.rom_characters.all;

entity VGA is

  generic(
    h_pulse  :  integer   := 120;   --horiztonal sync pulse width in pixels
    h_bp     :  integer   := 64;   --horiztonal back porch width in pixels
    h_pixels :  integer   := 800;  --horiztonal display width in pixels
    h_fp     :  integer   := 56;   --horiztonal front porch width in pixels
    h_pol    :  std_logic := '1';   --horizontal sync pulse polarity (1 = positive, 0 = negative)
    v_pulse  :  integer   := 6;     --vertical sync pulse width in rows
    v_bp     :  integer   := 23;    --vertical back porch width in rows
    v_pixels :  integer   := 600;  --vertical display width in rows
    v_fp     :  integer   := 37;     --vertical front porch width in rows
    v_pol    :  std_logic := '1');  --vertical sync pulse polarity (1 = positive, 0 = negative)
	 
  port(
    clk 		  :  in   std_logic;  --pixel clock at frequency of vga mode being used
    reset     :  in   std_logic;  --active low asycnchronous reset
	 nibble	  :  in   std_logic_vector (3 downto 0);
	 lvl       :  in 	 integer range 1 to 14;
	 pr_state  :  in   states;
    h_sync    :  out  std_logic;  --horiztonal sync pulse
    v_sync    :  out  std_logic;  --vertical sync pulse
	 red       :  out  std_logic_vector (2 downto 0);
    green     :  out  std_logic_vector (2 downto 0);
    blue      :  out  std_logic_vector (1 downto 0));	 
	 
end VGA;

architecture behavior of VGA is

  constant  h_period  :  integer := h_pulse + h_bp + h_pixels + h_fp;  --total number of pixel clocks in a row
  constant  v_period  :  integer := v_pulse + v_bp + v_pixels + v_fp;  --total number of rows in column
  shared variable h_count  :  integer range 0 to h_period - 1 := 0;  --horizontal counter (counts the columns)
  shared variable v_count  :  integer range 0 to v_period - 1 := 0;  --vertical counter (counts the rows)
  signal first_char: char_data :=((others=> (others=>'0')));
  signal secon_char: char_data :=((others=> (others=>'0')));
  
begin					
  
  process(clk, reset, pr_state)
  begin
	 
    if(reset = '1') then  --reset asserted
      h_count := 0;         --reset horizontal counter
      v_count := 0;         --reset vertical counter
      h_sync <= not h_pol;  --deassert horizontal sync
      v_sync <= not v_pol;  --deassert vertical sync
      
    elsif(rising_edge(clk)) then

      --counters
      if(h_count < h_period - 1) then    --horizontal counter (pixels)
        h_count := h_count + 1;
      else
        h_count := 0;
        if(v_count < v_period - 1) then  --veritcal counter (rows)
          v_count := v_count + 1;
        else
          v_count := 0;
        end if;
      end if;

      --horizontal sync signal
      if(h_count < h_pixels + h_fp or h_count > h_pixels + h_fp + h_pulse) then
        h_sync <= not h_pol;    --deassert horiztonal sync pulse
      else
        h_sync <= h_pol;        --assert horiztonal sync pulse
      end if;
      
      --vertical sync signal
      if(v_count < v_pixels + v_fp or v_count > v_pixels + v_fp + v_pulse) then
        v_sync <= not v_pol;    --deassert vertical sync pulse
      else
        v_sync <= v_pol;        --assert vertical sync pulse
      end if;
      
      --set display output
      if(h_count < h_pixels and v_count < v_pixels) then --display time
			
			if (v_count>300) then
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
				elsif (nibble="1111") then
					if (h_count<200) then
						red <= "111";
						green <= "000";
						blue <= "00";
					elsif (h_count>200 and h_count<400) then
						red <= "000";
						green <= "000";
						blue <= "11";			
					elsif (h_count>400 and h_count<600) then
						red <= "111";
						green <= "111";
						blue <= "00";
					elsif (h_count>600 and h_count<800) then
						red <= "000";
						green <= "111";
						blue <= "00";
					end if;
				end if;
	
			else
				if (pr_state=idle) then
					if (h_count<200) then
						red <= "111";
						green <= "000";
						blue <= "00";
					elsif (h_count>200 and h_count<400) then
						red <= "000";
						green <= "000";
						blue <= "11";			
					elsif (h_count>400 and h_count<600) then
						red <= "111";
						green <= "111";
						blue <= "00";
					elsif (h_count>600 and h_count<800) then
						red <= "000";
						green <= "111";
						blue <= "00";
					end if;
				elsif (pr_state=ff) then
					if (h_count>250 and h_count<400 and v_count>50 and v_count<250) then
						if (F(v_count-50)(h_count-225)='1') then
							red <= (others => '1');
							green <= (others => '1');
							blue <= (others => '1');
						else
							red <= (others => '0');
							green <= (others => '0');
							blue <= (others => '0');
						end if;
					elsif (h_count>400 and h_count<550 and v_count>50 and v_count<250) then
						if (F(v_count-50)(h_count-375)='1') then
							red <= (others => '1');
							green <= (others => '1');
							blue <= (others => '1');
						else
							red <= (others => '0');
							green <= (others => '0');
							blue <= (others => '0');
						end if;
					end if;
				elsif (pr_state=gg) then
					if (h_count>250 and h_count<400 and v_count>50 and v_count<250) then
						if (G(v_count-50)(h_count-225)='1') then
							red <= (others => '1');
							green <= (others => '1');
							blue <= (others => '1');
						else
							red <= (others => '0');
							green <= (others => '0');
							blue <= (others => '0');
						end if;
					elsif (h_count>400 and h_count<550 and v_count>50 and v_count<250) then
						if (G(v_count-50)(h_count-375)='1') then
							red <= (others => '1');
							green <= (others => '1');
							blue <= (others => '1');
						else
							red <= (others => '0');
							green <= (others => '0');
							blue <= (others => '0');
						end if;
					end if;
				else
				
					case lvl is
					
					when 1 => first_char<=zero;
								 secon_char<=zero;
								 
					when 2 => first_char<=zero;
								 secon_char<=one;
								 
					when 3 => first_char<=zero;
								 secon_char<=two;
								 
					when 4 => first_char<=zero;
								 secon_char<=three;
								 
					when 5 => first_char<=zero;
								 secon_char<=four;
								 
					when 6 => first_char<=zero;
								 secon_char<=five;
								 
					when 7 => first_char<=zero;
								 secon_char<=six;
								 
					when 8 => first_char<=zero;
								 secon_char<=seven;
								 
					when 9 => first_char<=zero;
								 secon_char<=eight;
								 
					when 10 => first_char<=zero;
								 secon_char<=nine;
								 
					when 11 => first_char<=one;
								 secon_char<=zero;
								 
					when 12 => first_char<=one;
								 secon_char<=one;
								 
					when 13 => first_char<=one;
								 secon_char<=two;
								 
					when 14 => first_char<=one;
								 secon_char<=three;
					
					end case;
								 
						if (h_count>250 and h_count<400 and v_count>50 and v_count<250) then
							if (first_char(v_count-50)(h_count-225)='1') then
								red <= (others => '1');
								green <= (others => '1');
								blue <= (others => '1');
							else
								red <= (others => '0');
								green <= (others => '0');
								blue <= (others => '0');
							end if;
						elsif (h_count>400 and h_count<550 and v_count>50 and v_count<250) then
							if (secon_char(v_count-50)(h_count-375)='1') then
								red <= (others => '1');
								green <= (others => '1');
								blue <= (others => '1');
							else
								red <= (others => '0');
								green <= (others => '0');
								blue <= (others => '0');
							end if;
						end if;
						
				end if;
				
			end if;
	

      else --blanking time
			red <= (others => '0');
			green <= (others => '0');
			blue <= (others => '0');
      end if;

    end if;
  end process;

end behavior;