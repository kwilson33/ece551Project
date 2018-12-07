//`include "tb_tasks.sv"
/*  SendCmd is going to send 'g' or 's' into Segway.v, mimicing real siganls from usr's bluetooth
   'g' go is 0x67
   's' stop is 0x73
*/
task test1;
    Initialize();
    batt = BATT_THRESHOLD + 1;
    lft_ld = MIN_RIDER_WEIGHT;
    rght_ld = MIN_RIDER_WEIGHT;
    rider_lean = 0;
    SendCmd(8'h67);
    repeat(100000)@(posedge clk);   // power up, wait for a short time
    @(negedge clk);
    rider_lean = 14'h1fff;          // test most positive lean
    repeat(1000000)@(posedge clk);
    @(negedge clk);
    rider_lean = 14'h2000;          // most negative lean
    repeat(1000000)@(posedge clk);
    $stop();
    
endtask


task test2;
    Initialize();
    batt = BATT_THRESHOLD + 1;
    lft_ld = MIN_RIDER_WEIGHT;
    rght_ld = MIN_RIDER_WEIGHT;
    rider_lean = 0;
    
    SendCmd(8'h67);
    repeat(200)@(posedge clk);
    
    @(negedge clk);
    lft_ld = MIN_RIDER_WEIGHT - 1;
    rght_ld = MIN_RIDER_WEIGHT - 1;
    repeat(200)@(posedge clk);      // should back to IDLE
    
    @(negedge clk);
    lft_ld = MIN_RIDER_WEIGHT;
    rght_ld = MIN_RIDER_WEIGHT;
    rider_lean = 14'h0;
    SendCmd(8'h67);                 // PWR1
    repeat(300000000)@(posedge clk);  // now should be in PWR2
    
    @(negedge clk);
    rider_lean = 14'h1fff;
    SendCmd(8'h73);
    repeat(200)@(posedge clk);  // TODO, wait long enough to stop?
    
    @(negedge clk);
    rider_lean = 14'h1fff;
    SendCmd(8'h73);
    repeat(200)@(posedge clk);
    
    
    $stop();

endtask



task test3;


endtask


