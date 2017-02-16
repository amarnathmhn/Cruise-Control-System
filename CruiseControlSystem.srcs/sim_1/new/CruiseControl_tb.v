`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.03.2016 23:26:06
// Design Name: 
// Module Name: CruiseControl_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CruiseControl_tb();
    
    reg clock;
    reg reset;
    wire state;
 
    reg throttle, set, accel;
    reg coast, cancel, resume, brake;
    wire [7:0] speed;
    wire [7:0] cruise_speed;
    wire cruise_status;
    
    // instantiate cruise control module
    CruiseControl cc( .clock(clock),
                      .reset(reset),
                      .throttle(throttle),
                      .set(set),
                      .accel(accel),
                      .coast(coast),
                      .cancel(cancel),
                      .resume(resume),
                      .brake(brake),
                      .speed(speed),
                      .cruise_speed(cruise_speed),
                      .cruise_status(cruise_status) );
                      
    //  monitor state
    assign state = cc.state;
    // define clock
    always #50 clock = ~clock;
    
    // drive test stimuli
    initial begin
       $monitor($time,"speed = %d", speed);
       // initialize clock
       clock = 0;
       // reset the design
       reset = 0;
       #150 reset = 1;
       #50  reset = 0;
       // 1) increase the speed to 30 mph using throttle
       #10;
       throttle = 1;
       wait(speed == 30);
       // try to set the cruise control using set
       @(negedge clock);
       #25;
       set = 1;
       #50;
       set = 0;
       // turn throttle off
       throttle = 0;
       // wait until speed is 20mph
       wait(speed == 20);
       // now turn throttle on
       throttle = 1;
       // wait until speed is 50 mph
       wait(speed == 50);
       //try to set the cruise control speed at this point, it should work
       @( negedge clock);
       set = 1;
       #100;
       set = 0;
       // continue to increase the speed until 60mph
       wait (speed == 60);
       #100;
       // take throttle off at this point
       throttle = 0;
       // wait till speed drops until 50
       wait(speed == 50);
       // cruise for 5 clock cycles at this cruising speed
       repeat(5) @(negedge clock)
       #100;
       // now apply brake
       #50; 
       brake = 1;
       #100;
       brake = 0;
       wait(speed == 30);
       #100;
       // provide resume pulse       
       # 50
       resume = 1;
       #100;
       resume = 0;
       wait (speed == 50);
       repeat(5) @(negedge clock);
       #100;
       // give five consecutive accel pulses
       repeat(5) begin
          @(negedge clock);
          #25;
          accel = 1;
          #50;
          accel = 0;       
       end
       #100;
       
        // give five consecutive coast pulses
        repeat(5) begin
          @(negedge clock);
          #25;
          coast = 1;
          #50;
          coast = 0;       
        end
        #100;
        repeat(5)
          #100;
        // apply cance
        @(negedge clock);
        #25 cancel = 1;
        #50 cancel = 0;
        // wait until speed goes to zero
        wait(speed == 0);
        #100;     
       $finish;
       
    end
    
endmodule
