--------------------------------------------------------------------
-- Name:	Chris Coulston
-- Date:	Fall 2022
-- File:	signalAcquire.vhd
--
-- Purp: Tie the datapath and control unit together
--
-- Documentation:	No help
--
-- Academic Integrity Statement: I certify that, while others may have 
-- assisted me in brain storming, debugging and validating this program, 
-- the program itself is my own work. I understand that submitting code 
-- which is the work of other individuals is a violation of the honor   
-- code.  I also understand that if I knowingly give my original work to 
-- another individual is also a violation of the honor code. 
------------------------------------------------------------------------- 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.signalAcquire_Package.ALL;	
use work.basicBuildingBlocks_package.ALL;
					-- Include any packages that are instantiated


entity signalAcquire is
    PORT ( clk : in  STD_LOGIC;
           resetn : in  STD_LOGIC;
		   btn: in	STD_LOGIC_VECTOR(2 downto 0);
		   an7606data: in STD_LOGIC_VECTOR(15 downto 0);
		   an7606convst, an7606cs, an7606rd, an7606reset: out STD_LOGIC;
		   an7606od: out STD_LOGIC_VECTOR(2 downto 0);
		   an7606busy : in STD_LOGIC;
		   reg0Magnitude: out STD_LOGIC_VECTOR(3 downto 0));		   
end signalAcquire;

architecture behavior of signalAcquire is

    signal sw: STD_LOGIC_VECTOR(SW_WIDTH - 1 downto 0);
    signal cw: STD_LOGIC_VECTOR(CW_WIDTH - 1 downto 0);
    signal rfData: STD_LOGIC_VECTOR(15 downto 0);
    signal btnCurr, btnPrev: STD_LOGIC;
    	
begin

    dp: signalAcquire_Datapath
        PORT MAP(clk => clk,
                 resetn => resetn,
                 cw => cw,
                 sw => sw(DATAPATH_SW_WIDTH - 1 downto 0),
                 an7606data => an7606data,
                 rfAddr => "000", --only read channel 1 ("000")
                 rfData => rfData
                 );
    
    cu: signalAcquire_Fsm
        PORT MAP(clk => clk,
                 resetn => resetn,
                 sw => sw,
                 cw => cw
                 );
                 
    comp066V: genericCompare
        GENERIC MAP(16)
        PORT MAP(x => FIRST_THRESHOLD_CONSTANT,
                 y => rfData,
                 g => reg0Magnitude(0),
                 l => open,
                 e => open
                 );
                 
    comp132V: genericCompare
        GENERIC MAP(16)
        PORT MAP(x => SECOND_THRESHOLD_CONSTANT,
                 y => rfData,
                 g => reg0Magnitude(1),
                 l => open,
                 e => open
                 );
                 
    comp198V: genericCompare
        GENERIC MAP(16)
        PORT MAP(x => THIRD_THRESHOLD_CONSTANT,
                 y => rfData,
                 g => reg0Magnitude(2),
                 l => open,
                 e => open
                 );
                 
    comp264V: genericCompare
        GENERIC MAP(16)
        PORT MAP(x => FOURTH_THRESHOLD_CONSTANT,
                 y => rfData,
                 g => reg0Magnitude(3),
                 l => open,
                 e => open
                 );
                 
    btnCurr <= btn(0);
    an7606convst <= cw(CONVST_CW_BIT_INDEX);
    an7606rd <= cw(RD_CW_BIT_INDEX);
    an7606cs <= cw(CS_CW_BIT_INDEX);
    an7606reset <= cw(RESET_AD7606_CW_BIT_INDEX);
    an7606od <= "000"; --hard coded
    sw(BUSY_SW_BIT_INDEX) <= an7606busy;
    
    button_process: process(clk)  
	begin
		if (rising_edge(clk)) then
			if (resetn = '0') then 
				btnPrev <= '0';
				sw(START_CONV_SW_BIT_INDEX) <= '0';
		    else
		    
		    if (btnCurr = '1' and btnPrev = '0') then
		      sw(START_CONV_SW_BIT_INDEX) <= '1';
		    else
		      sw(START_CONV_SW_BIT_INDEX) <= '0';
		    end if;
--		    sw(START_CONV_SW_BIT_INDEX) <= '1' when (btnCurr = '1' and btnPrev = '0')
--			                               else '0';
			btnPrev <= btnCurr;
			end if;
	    end if;
	end process;
 
end behavior;
