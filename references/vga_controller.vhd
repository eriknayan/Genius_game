library ieee;
use ieee.std_logic_1164.all;

entity vga_controller is

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
	 
	 --pixels_y :  integer := 478;   --row size of the colors rectangles 
    --pixels_x :  integer := 600;   --column size of the colors rectangles
	 
  port(
    pixel_clk :  in   std_logic;  --pixel clock at frequency of vga mode being used
    reset_n   :  in   std_logic;  --active low asycnchronous reset
	 
    h_sync    :  out  std_logic;  --horiztonal sync pulse
    v_sync    :  out  std_logic;  --vertical sync pulse
	 red       :  out  std_logic_vector (2 downto 0);
    green     :  out  std_logic_vector (2 downto 0);
    blue      :  out  std_logic_vector (1 downto 0));	 
	 
end vga_controller;

architecture behavior of vga_controller is

  constant  h_period  :  integer := h_pulse + h_bp + h_pixels + h_fp;  --total number of pixel clocks in a row
  constant  v_period  :  integer := v_pulse + v_bp + v_pixels + v_fp;  --total number of rows in column
  shared variable h_count  :  integer range 0 to h_period - 1 := 0;  --horizontal counter (counts the columns)
  shared variable v_count  :  integer range 0 to v_period - 1 := 0;  --vertical counter (counts the rows)
  
begin
  
  process(pixel_clk, reset_n)
  begin
	 
    if(reset_n = '1') then  --reset asserted
      h_count := 0;         --reset horizontal counter
      v_count := 0;         --reset vertical counter
      h_sync <= not h_pol;  --deassert horizontal sync
      v_sync <= not v_pol;  --deassert vertical sync
      
    elsif(rising_edge(pixel_clk)) then

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
      
      --set display enable output
      if(h_count < h_pixels and v_count < v_pixels) then --display time
			red <= (others => '1');
			green <= (others => '1');
			blue <= (others => '0');
       -- disp_ena <= '1';                                  --enable display
      else --blanking time
			red <= (others => '0');
			green <= (others => '0');
			blue <= (others => '0');
        --disp_ena <= '0';                                  --disable display
      end if;

    end if;
  end process;

end behavior;
