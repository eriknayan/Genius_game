library ieee;
use ieee.std_logic_1164.all;
use work.global_pack.all;
use work.rom_characters.all;

entity VGA is

  generic(
    h_pulse  :  integer   := 120; -- Largura do pulso de sincronização horizontal em pixels
    h_bp     :  integer   := 64; -- Largura do back porch horizontal em pixels
    h_pixels :  integer   := 800; -- Largura de display horizontal em pixels
    h_fp     :  integer   := 56; -- Largura do front porch horizontal em pixels
    h_pol    :  std_logic := '1'; -- Polaridade da sincronização horizontal (1 = positiva, 0 = negativa)
    v_pulse  :  integer   := 6; -- Largura do pulso de sincronização vertical em linhas
    v_bp     :  integer   := 23; -- Largura do back porch vertical em linhas
    v_pixels :  integer   := 600; -- Largura de display vertical em linhas
    v_fp     :  integer   := 37; -- Largura do front porch vertical em linhas
    v_pol    :  std_logic := '1'); --Polaridade da sincronização vertical (1 = positiva, 0 = negativa)
	 
  port(
    clk 		  :  in   std_logic; -- Pixel clock
    reset     :  in   std_logic;  -- Reset
	 nibble	  :  in   std_logic_vector (3 downto 0); -- Estado dos leds
	 lvl       :  in 	 integer range 1 to 14; -- Nível atual do jogo
	 pr_state  :  in   states; -- Estado da máquina
    h_sync    :  out  std_logic; -- Pulso de sincronização horizontal
    v_sync    :  out  std_logic; -- Pulso de sincronização vertical
	 red       :  out  std_logic_vector (2 downto 0); -- Bits do vermelho do VGA
    green     :  out  std_logic_vector (2 downto 0); -- Bits do verde do VGA
    blue      :  out  std_logic_vector (1 downto 0));	-- Bits do azul do VGA
	 
end VGA;

architecture behavior of VGA is

  constant  h_period  :  integer := h_pulse + h_bp + h_pixels + h_fp;  -- Número total de pixels em uma linha
  constant  v_period  :  integer := v_pulse + v_bp + v_pixels + v_fp;  -- Número total de linhas em uma coluna
  shared variable h_count  :  integer range 0 to h_period - 1 := 0;  -- Contador horizontal
  shared variable v_count  :  integer range 0 to v_period - 1 := 0;  -- Contador vertical
  shared variable red_var : std_logic_vector (2 downto 0) := ( others => '0'); -- Variável para procedure de caracteres
  shared variable green_var : std_logic_vector (2 downto 0) := ( others => '0'); -- Variável para procedure de caracteres
  shared variable blue_var : std_logic_vector (1 downto 0) := ( others => '0'); -- Variável para procedure de caracteres
  
begin					
  
  process(clk, reset, pr_state)
  begin
	 
	 -- Reinicia o VGA em caso de reset
    if(reset = '1') then  
      h_count := 0;         
      v_count := 0;         
      h_sync <= not h_pol;  
      v_sync <= not v_pol;  
      
    elsif(rising_edge(clk)) then

      -- Contadores
      if(h_count < h_period - 1) then    
        h_count := h_count + 1;
      else
        h_count := 0;
        if(v_count < v_period - 1) then  
          v_count := v_count + 1;
        else
          v_count := 0;
        end if;
      end if;

      -- Sincronização Horizontal
      if(h_count < h_pixels + h_fp or h_count > h_pixels + h_fp + h_pulse) then
        h_sync <= not h_pol;    
      else
        h_sync <= h_pol;        
      end if;
      
      -- Sincronização Vertical
      if(v_count < v_pixels + v_fp or v_count > v_pixels + v_fp + v_pulse) then
        v_sync <= not v_pol;    
      else
        v_sync <= v_pol;        
      end if;
      
      -- Verifica se está dentro da área de impressao do display e implementa a lógica para cada estado
      if(h_count < h_pixels and v_count < v_pixels) then 
			
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
				
					-- Case que verifica o level e chama procedure para impressão dos devidos caracteres
					case lvl is
					
					when 1 => characters (h_count, v_count, zero, zero, red_var, green_var, blue_var);
								 
					when 2 => characters (h_count, v_count, zero, one, red_var, green_var, blue_var);
								 
					when 3 => characters (h_count, v_count, zero, two, red_var, green_var, blue_var);
								 
					when 4 => characters (h_count, v_count, zero, three, red_var, green_var, blue_var);
								 								 
					when 5 => characters (h_count, v_count, zero, four, red_var, green_var, blue_var);
								 								 
					when 6 => characters (h_count, v_count, zero, five, red_var, green_var, blue_var);
								 
					when 7 => characters (h_count, v_count, zero, six, red_var, green_var, blue_var);
								 								 
					when 8 => characters (h_count, v_count, zero, seven, red_var, green_var, blue_var);
								 
					when 9 => characters (h_count, v_count, zero, eight, red_var, green_var, blue_var);
								 								 
					when 10 => characters (h_count, v_count, zero, nine, red_var, green_var, blue_var);
								 								 
					when 11 => characters (h_count, v_count, one, zero, red_var, green_var, blue_var);
								 								 
					when 12 => characters (h_count, v_count, one, one, red_var, green_var, blue_var);
								 								 
					when 13 => characters (h_count, v_count, one, two, red_var, green_var, blue_var);
								 								 
					when 14 => characters (h_count, v_count, one, three, red_var, green_var, blue_var);
								  
					end case;
						
					-- Associação das variáveis com as saidas RGB
					red <= red_var;
					green <= green_var;
					blue <= blue_var;
								 
				end if;
				
			end if;
	
		-- Tempo em que nada é enviado no RGB
      else 
			red <= (others => '0');
			green <= (others => '0');
			blue <= (others => '0');
      end if;

    end if;
  end process;

end behavior;