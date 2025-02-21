module Segway(clk,RST_n,LED,INERT_SS_n,INERT_MOSI,
              INERT_SCLK,INERT_MISO,A2D_SS_n,A2D_MOSI,A2D_SCLK,
			  A2D_MISO,PWM_rev_rght,PWM_frwrd_rght,PWM_rev_lft,
			  PWM_frwrd_lft,piezo_n,piezo,INT,RX);
			  
  input clk,RST_n;
  input INERT_MISO;						// Serial in from inertial sensor
  input A2D_MISO;						// Serial in from A2D
  input INT;							// Interrupt from inertial indicating data ready
  input RX;								// UART input from BLE module

  
  output [7:0] LED;						// These are the 8 LEDs on the DE0, your choice what to do
  output A2D_SS_n, INERT_SS_n;			// Slave selects to A2D and inertial sensor
  output A2D_MOSI, INERT_MOSI;			// MOSI signals to A2D and inertial sensor
  output A2D_SCLK, INERT_SCLK;			// SCLK signals to A2D and inertial sensor
  output PWM_rev_rght, PWM_frwrd_rght;  // right motor speed controls
  output PWM_rev_lft, PWM_frwrd_lft;	// left motor speed controls
  output piezo_n,piezo;					// diff drive to piezo for sound
  
  ////////////////////////////////////////////////////////////////////////
  // fast_sim is asserted to speed up fullchip simulations.  Should be //
  // passed to both balance_cntrl and to steer_en.  Should be set to  //
  // 0 when we map to the DE0-Nano.                                  //
  ////////////////////////////////////////////////////////////////////
  localparam fast_sim = 1;				// asserted to speed up simulations. 
  localparam BATT_LOW_THRESH = 11'h800; // if batt from A2D_Intf drops below, batt_low signal will be high
  
  ///////////////////////////////////////////////////////////
  ////// Internal interconnecting sigals defined here //////
  /////////////////////////////////////////////////////////
  wire rst_n;                           // internal global reset that goes to all units
  
  
  
  // A2D Interface Signals 
  wire [11:0] lft_ld, rght_ld;
  wire [11:0] batt;
 
  
  // Inertial Interface Signals
  wire vld;								// Asserted from SM. Consumed in intertial_integrator. Also used in balance_ctrl
  wire [15:0] ptch;						// Primary output. Fusion corrected ptch from Segway 
 						
						
  // Auth_blk signals
  wire pwr_up;
		
  // Steer Enable Signals
  wire [11:0] ld_cell_diff;
  wire en_steer;
  wire rider_off;
  
  // Balance Control Signals
  wire lft_rev, rght_rev;
  wire [10:0] lft_spd, rght_spd;
  wire ovr_spd;
  
  // Piezo Signals
  wire batt_low;
  assign batt_low = batt <= BATT_LOW_THRESH; // TODO: Is this OK??
  

  ////////////////////////////////////
   
  
  ///////////////////////////////////////////////////////
  // How you arrange the hierarchy of the top level is up to you.
  //Kevin : I'm going with the flat instantiation
  
  //   Auth_blk 		GOOD
  Auth_blk Auth_block(.clk(clk), .rst_n(rst_n), .rider_off(rider_off), .pwr_up(pwr_up), .RX(RX));
   
   
  //   inert_intf 		GOOD
  inert_intf Inertial_Interface(.clk(clk), .rst_n(rst_n), .vld(vld), .ptch(ptch), .SS_n(INERT_SS_n), 
								.SCLK(INERT_SCLK), .MOSI(INERT_MOSI), .MISO(INERT_MISO), .INT(INT));
			
			
  //   balance_cntrl 	GOOD 
  balance_cntrl balance_control(.clk(clk), .rst_n(rst_n), .vld(vld), .ptch(ptch), .ld_cell_diff(ld_cell_diff),
							   .lft_spd(lft_spd), .lft_rev(lft_rev), .rght_spd(rght_spd), .rght_rev(rght_rev),
							   .rider_off(rider_off), .en_steer(en_steer), .pwr_up(pwr_up), .ovr_spd(ovr_spd));
							   
  //   steer_en			GOOD
  steer_en steer_enable(.clk(clk), .rst_n(rst_n), .lft_ld(lft_ld), .rght_ld(rght_ld), .ld_cell_diff(ld_cell_diff),
						.en_steer(en_steer), .rider_off(rider_off));
  
  
  
  //   mtr_drv			GOOD
  mtr_drv motor_drive(.clk(clk), .rst_n(rst_n), .PWM_rev_lft(PWM_rev_lft), .PWM_rev_rght(PWM_rev_rght), .PWM_frwrd_rght(PWM_frwrd_rght),
					  .PWM_frwrd_lft(PWM_frwrd_lft), .lft_spd(lft_spd), .lft_rev(lft_rev), .rght_spd(rght_spd), .rght_rev(rght_rev));
					  
					  
  //   A2D_intf 		GOOD
   // use vld from intertial interface for next signal of A2D_Interface
  A2D_Intf A2D_interface(.clk(clk), .rst_n(rst_n), .nxt(vld), .lft_ld(lft_ld), .rght_ld(rght_ld),
						.batt(batt), .SS_n_A2D(A2D_SS_n), . SCLK_A2D(A2D_SCLK), .MOSI_A2D(A2D_MOSI),
						.MISO_A2D(A2D_MISO));
						
						
  //   piezo		   GOOD
  piezo pepperoni_piezo(.clk(clk), .rst_n(rst_n), .piezo(piezo), .piezo_n(piezo_n), .batt_low(batt_low), 
						.ovr_spd(ovr_spd), .norm_mode(en_steer));
  
  //////////////////////////////////////////////////////
 
					
  /////////////////////////////////////
  // Instantiate reset synchronizer //
  ///////////////////////////////////  
  rst_synch iRST(.clk(clk),.RST_n(RST_n),.rst_n(rst_n));
  
endmodule
