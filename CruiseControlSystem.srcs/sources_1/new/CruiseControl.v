`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.03.2016 07:40:45
// Design Name: 
// Module Name: CruiseControl
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


module CruiseControl(
    input clock,
    input reset,
    input throttle,
    input set,
    input accel,
    input coast,
    input cancel,
    input resume,
    input brake,
    output reg [7:0] speed,
    output reg [7:0] cruise_speed,
    output reg cruise_status
    );
    
    // register for state
    reg [1:0] state;       // Current state
 
    
    // flags to indicate if brake pulse or resume pulse is given
    reg brake_appl;        // indicates brake pulse applied
    reg resume_appl;       // indicates resume pulse applied
        
    
    // Define states
    localparam CRUISE_ON  = 1'b1,  // Cruise Control is set
               CRUISE_OFF = 1'b0; // Cruise Control is unset ( turned off )

        

    // next state logic.
    always @( posedge clock, posedge reset ) begin
    
    if( reset ) begin
       cruise_speed  <= 8'hzz;
       state         <= CRUISE_OFF;
       cruise_status <= 1'b0;
       speed         <= 0;
    end
    else begin
       case(state)
          
            CRUISE_OFF: begin
            cruise_status <= 1'b0;
               // if throttle is on, increment the speed by 1 mph every cycle
               if(throttle) begin
                  speed <= speed + 1;
                  // if brake pulse was applied , cancel it 
                  if( brake_appl != 1'b0 )
                      brake_appl  <= 1'b0;
               end
               else begin
                    if(speed > 0) begin
                           speed <= speed - 1;
                    end
               end
               
              if (set) begin
               // if set is applied and speed is greater than 45mph, set the cruise speed to 
               // the current speed, and change state to CRUISE_ON
                  if(speed > 45) begin
                     cruise_speed <= speed;
                     state   <= CRUISE_ON; 
                     // if brake pulse was applied , cancel it
                     if( brake_appl != 1'b0 ) begin
                        brake_appl <= 1'b0;
                     end
                     
                  end
               end
               // if brake is applied, set brake_appl flag to zero
               if ( brake ) begin
                   brake_appl <= 1;
               end
               // if brake flag is on, decrement the speed by 2 every clock cycle
               if ( brake_appl )begin
                   speed <= speed - 2;
               end
               // if resume is applied, move to CRUISE_ON state
               if ( resume && cruise_speed > 0 && speed > 0 ) begin
                   state       <= CRUISE_ON;
                   resume_appl <= 1;
               end
               
              
               
            end
            
            CRUISE_ON : begin
            cruise_status <= 1'b1;
            // if throttle is applied, increment speed by 1 mph every cycle.
            // do not change cruise speed               
               if( throttle ) begin
                  speed <= speed + 1;
               end
              
               else begin             
                 // if accel is applied, increment the cruise speed by 1 mph every cycle
                   if ( accel ) begin
                      
                       cruise_speed <= cruise_speed + 1;
                       speed        <= speed + 1;
                       state        <= CRUISE_ON;
                       // cancel resume if it was applied
                        if( resume_appl == 1'b1 )
                            resume_appl <= 1'b0;
                       
                       
                   end
                   // if coast is applied, decrement the cruise speed by 1 mph every cycle
                   else if ( coast ) begin
                       cruise_speed <= cruise_speed - 1;
                       speed        <= speed - 1;
                       state   <= CRUISE_ON;
                      // cancel resume if it was applied
                        if( resume_appl == 1'b1 )
                            resume_appl <= 1'b0;
                       
                   end
                   // if cancel is applied, turn off cruise control
                   else if ( cancel ) begin
                       state   <= CRUISE_OFF;    
                       // cancel resume if it was applied
                       if( resume_appl == 1'b1 )
                          resume_appl <= 1'b0;     
                   end
                   // if brake is applied, turn off cruise control and decrement
                   // speed at 2 mph every cycle which is handled in CRUISE_OFF state
                   else if ( brake ) begin
                       
                       brake_appl   <= 1'b1;
                       state        <= CRUISE_OFF;
                       
                   end
                 // if speed is less than cruise speed and , increase it to reach cruise speed
                   else if (speed < cruise_speed && resume_appl ) begin
                         speed <= speed + 1;
                   end
                   else begin
                      // if no input is applied, then decrease until cruise_speed is reached
                      if(speed > cruise_speed) begin
                          speed <= speed - 1;
                      end
                    
                   end
               end
           end
            
       endcase
       end // else
    end // always
    
               
               
    
        
endmodule
