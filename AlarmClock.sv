module alarm_clock(input CLK_2Hz, reset, time_set, alarm_set,sethrs1min0, run, activatealarm, alarmreset,setbutton,
output logic [7:0] sec, min, hrs, sec_alrm, min_alrm, hrs_alrm, output logic alrm);

logic CLK_1Hz, hr_eq, sec_eq, min_eq, alarmequal, set_enable, run_enable, set, runner;
logic [7:0] sec_set;

fdivby2 F2by1 (CLK_2Hz, reset, CLK_1Hz);
timer alarmset (reset, CLK_1Hz, CLK_2Hz, set_enable, setbutton, set, sethrs1min0, sec_set, min_alrm, hrs_alrm);
timer alarmrun (reset, CLK_1Hz, CLK_2Hz, run_enable, setbutton, runner, sethrs1min0, sec, min, hrs);
  
assign sec_alrm = 8'b0; 
assign sec_eq = (sec == sec_alrm) ? 1'b1:1'b0; 
assign min_eq = (min == min_alrm) ? 1'b1:1'b0;
assign hr_eq = (hrs == hrs_alrm) ? 1'b1:1'b0;
assign alarmequal = sec_eq&min_eq&hr_eq;

equaltimes eq1 (reset|~alarmreset, alarmequal, activatealarm, alrm);

always_comb begin
	run_enable=1'b0; runner=1'b0; set_enable=1'b0; set=1'b0;
	if (run & ~(time_set|alarm_set)) begin 
		run_enable =1'b1; runner=1'b1;
		set_enable=1'b0;
	end 
	else if (alarm_set & ~time_set &~run) begin
		set_enable=1'b1; set=1'b0; run_enable=1'b0;
	end

	else if (time_set & ~alarm_set &~run) begin
		set_enable=1'b0; runner=1'b0; run_enable=1'b1;
	end
	else begin 
	run_enable=1'b0; set_enable=1'b0;
	end
end	
endmodule



`timescale 1ns/1ps 
module alarm_clocktb();
logic CLK_2Hz, reset,time_set, alarm_set,sethrs1min0, run, activatealarm, alarmreset, setbutton;
logic [7:0] sec, min, hrs, sec_alrm, min_alrm, hrs_alrm; 
logic alrm;

alarm_clock A1 (CLK_2Hz, reset, time_set, alarm_set,sethrs1min0, run, activatealarm, alarmreset, setbutton,
sec, min, hrs, sec_alrm, min_alrm, hrs_alrm, alrm);

initial begin
	CLK_2Hz = 1'b0; reset = 1'b1; time_set = 1'b0; alarm_set = 1'b0; sethrs1min0 = 1'b0; run= 1'b0; activatealarm = 1'b0; alarmreset = 1'b1; setbutton = 1'b1; #5;
	reset = 1'b0; CLK_2Hz = 1'b1; #5;
	$display("Display: %b : %b : %b", hrs, min, sec);
	alarm_set = 1'b1; setbutton = 1'b0; CLK_2Hz = 1'b0; #5;
	repeat (22) begin
		CLK_2Hz = 1'b1; #5;
		CLK_2Hz = 1'b0; #5;
	end
	$display("Alarm Display: %d : %d : %d", hrs_alrm, min_alrm, sec_alrm);
	setbutton = 1'b1; CLK_2Hz = 1'b1; #5;
	sethrs1min0 = 1'b1; setbutton = 1'b0; CLK_2Hz = 1'b0; #5;
	repeat (7) begin
		CLK_2Hz = 1'b1; #5;
		CLK_2Hz = 1'b0; #5;
	end
	$display("Alarm Display: %d : %d : %d", hrs_alrm, min_alrm, sec_alrm);
	setbutton = 1'b1; CLK_2Hz = 1'b1; #5;
	sethrs1min0 = 1'b0; time_set = 1'b1; alarm_set = 1'b0; setbutton = 1'b0; CLK_2Hz = 1'b0; #5;
	repeat (21) begin
		CLK_2Hz = 1'b1; #5;
		CLK_2Hz = 1'b0; #5;
	end
	$display("Time Display: %d : %d : %d", hrs, min, sec);
	setbutton = 1'b1; CLK_2Hz = 1'b1; #5;
	sethrs1min0 = 1'b1; setbutton = 1'b0; CLK_2Hz = 1'b0; #5;
	repeat (7) begin
		CLK_2Hz = 1'b1; #5;
		CLK_2Hz = 1'b0; #5;
	end
	$display("Time Display: %d : %d : %d", hrs, min, sec);
	setbutton = 1'b1; time_set = 1'b0; activatealarm = 1'b1; CLK_2Hz = 1'b1; #5;
	run = 1'b1; CLK_2Hz = 1'b0; #5;
	repeat (123) begin
		CLK_2Hz = 1'b1; #5;
		CLK_2Hz = 1'b0; #5;
	$display("Time Display: %d : %d : %d, Alarm = %d", hrs, min, sec, alrm);
	end
	alarmreset = 1'b0; CLK_2Hz = 1'b0; #5;
	CLK_2Hz = 1'b1; #5;
	$display("Time Display: %d : %d : %d, Alarm = %d", hrs, min, sec, alrm);
	alarmreset = 1'b1;
	repeat (123) begin
		CLK_2Hz = 1'b1; #5;
		CLK_2Hz = 1'b0; #5;
	$display("Time Display: %d : %d : %d, Alarm = %d", hrs, min, sec, alrm);
	end
$display(" %0t",$realtime);
end 

endmodule



module equaltimes (input reset, deter_alarm, activate_alarm, output logic alrm);
always_comb begin 
	alrm = 1'b0; 
	if (reset) begin 
	  alrm <= 1'b0; 
	end
	else if (activate_alarm == 1'b1 & deter_alarm == 1'b1) begin 
	  alrm <= 1'b1; 
	end
end
endmodule 




module alarm_clock_pv(input CLK,SW5,SW4,SW3,SW2,SW1,SW0,KEY1,KEY0,
output logic [6:0] SEC_LSD, SEC_MSD, MIN_LSD,
MIN_MSD, HR_LSD, HR_MSD, output logic LED7,LED5,LED4,LED3,LED2,LED1,LED0);

logic clk_2hz, alrm,alarmlight; 
logic [7:0] sec, min, hrs, sec_alrm, min_alrm, hrs_alrm, sech,secl,minh,minl,hrsh,hrsl,SHI,SLO,MHI,MLO,HHI,HLO;
logic [7:0] message [5:0];
logic [24:0] maxval, pmcounter;
assign maxval = 24'b101111101011110000011111;

pmcntr #(24) p1(CLK, SW0, maxval, pmcounter, clk_2hz);

assign LED0=SW0; assign LED1=SW1; assign LED2=SW2; assign LED3=SW3;assign LED4=SW4;assign LED5=SW5; assign LED7 = alarmlight;

alarm_clock alarm1 (clk_2hz, SW0, SW2,SW1,SW3,SW5,SW4,KEY0,KEY1, sec, min, hrs, sec_alrm, min_alrm, hrs_alrm, alrm);

Timedisplaymsb t1 (sec, sech, secl);
Timedisplaymsb t2 (min, minh, minl);
Timedisplaymsb t3 (hrs, hrsh, hrsl);
Timedisplaymsb t4 (sec_alrm, SHI, SLO);
Timedisplaymsb t5 (min_alrm, MHI, MLO);
Timedisplaymsb t6 (hrs_alrm, HHI, HLO);

Dec27Seg d1 (message[0], SEC_LSD);
Dec27Seg d2 (message[1], SEC_MSD);
Dec27Seg d3 (message[2], MIN_LSD);
Dec27Seg d4 (message[3], MIN_MSD);
Dec27Seg d5 (message[4], HR_LSD);
Dec27Seg d6 (message[5], HR_MSD);

always_comb begin 
	if (SW1&~(SW5|SW2))begin
		message[0] = SLO; message[1] = SHI; message[2] = MLO; message[3] = MHI;
		message[4] = HLO; message[5] = HHI;
	end
	else if (SW2&~(SW5|SW1))begin
		message[0] = secl; message[1] = sech; message[2] = minl; message[3] = minh;
		message[4] = hrsl; message[5] = hrsh;
	end
	else if (SW5&~(SW1|SW2)) begin
		message[0] = secl; message[1] = sech; message[2] = minl; message[3] = minh;
		message[4] = hrsl; message[5] = hrsh;
	end

	else begin
		message[0] = 8'd0; message[1] = 8'd0; message[2] = 8'd0; message[3] = 8'd0;
		message[4] = 8'd0; message[5] = 8'd0;
	end
end 
always_comb begin
	if (alrm) 
	alarmlight = 1'b1;
	else alarmlight=1'b0;
end

endmodule







module clocktime (input clk, enable, reset, input [7:0] MaxVal, output logic [7:0] Count, output logic clkout);
localparam Zero = 8'd0, One = 8'd1, zero = 1'b0, one = 1'b1;
always_ff @ (posedge clk or posedge reset) begin
	if (reset) begin
		Count <= Zero;
		clkout <= zero;
	end
	else if (enable) begin
		if (Count < MaxVal) begin
			Count <= Count + One;
			clkout <= zero;
		end
		else begin
			Count <= Zero;
			clkout <= one;
		end
	end
end
endmodule






module timer (input reset, onehz, twohz, enable,KEY1, set0_run1, hrs1_min0, output [7:0] Seconds, Minutes, Hours);
	
logic clk_Min, clk_Hr, enable_Sec,enable_Min,enable_Hour,twoHz;

localparam twentythree = 8'b0010111, fiftynine = 8'b0111011;
clocktime secclock (onehz, enable_Sec, reset, fiftynine, Seconds, Min_in);
clocktime Minclock (clk_Min, enable_Min, reset, fiftynine, Minutes, Hr_in);
clocktime Hourclock (clk_Hr, enable_Hour, reset, twentythree, Hours, Days_in);

always_comb begin
	clk_Min = Min_in;
	clk_Hr = Hr_in;
	enable_Sec = 1'b0;
	enable_Min = 1'b0;
	enable_Hour = 1'b0;
	if (enable) begin
	if (~set0_run1)begin
	  case ({KEY1, hrs1_min0})
		2'b00 : begin 
			clk_Min = twohz;
			clk_Hr = 1'b0;
			enable_Sec = 1'b0; enable_Min = 1'b1; enable_Hour = 1'b0;
			end 
		2'b01 : begin 
			clk_Min = 1'b0;
			clk_Hr = twohz;
			enable_Sec = 1'b0; enable_Min = 1'b0; enable_Hour = 1'b1;
			end
		default : begin 
			enable_Sec = 1'b0; enable_Min = 1'b0; enable_Hour = 1'b0;
			  end
	  endcase
	end
		else if (set0_run1) begin 
			clk_Min = Min_in;
			clk_Hr = Hr_in;
			enable_Sec = 1'b1; enable_Min = 1'b1; enable_Hour = 1'b1;
				end

	end
end
endmodule 





// parameterized counter, frequency divider
module pmcntr #(parameter siz=5) (input clk, reset,
input [siz-1:0] count_max, output logic [siz-1:0]
count, output logic clkout);
always_ff @ (posedge clk or posedge reset)
	if (reset) begin
	  count <= {siz{1'b0}};
	  clkout <= 1'b0;
	end
	else if (count<count_max)
	  count <= count + {{(siz-1){1'b0}},1'b1};
	else begin
	  count <= {siz{1'b0}};
	  clkout <= ~clkout;
	end
endmodule



// divides clk freq by 2 giving clkout
module fdivby2 (input clk, reset, output logic clkout);
always_ff @ (posedge clk or posedge reset)
	if (reset)
	  clkout <= 1'b0;
	else
	  clkout <= ~clkout;
endmodule




module Timedisplaymsb (input [7:0] T, output [7:0] Th, Tl);
assign Th = T/8'd10;
assign Tl = T-Th*8'd10;
endmodule 





module Dec27Seg(input [7:0] Decimal, output reg[6:0] HexSeg);
  always_comb begin 
	HexSeg = 7'd0;
	case (Decimal)
	//Numbers
	//0
	8'h0 : begin 
		HexSeg[6] = 1;
		end 
	//1
	8'h1 : begin 
		HexSeg[3]=1;HexSeg[0]=1;HexSeg[4]=1;HexSeg[5]=1;HexSeg[6]=1;
		end
	//2
	8'h2 : begin 
		HexSeg[2]=1;HexSeg[5]=1;
		end
	//3
	8'h3 : begin 
		HexSeg[4]=1;HexSeg[5]=1;
		end
	//4
	8'h4 : begin 
		HexSeg[0]=1;HexSeg[4]=1;HexSeg[3]=1;
		end
	//5
	8'h5 : begin 
		HexSeg[1]=1;HexSeg[4]=1;
		end
	//6
	8'h6 : begin 
		HexSeg[1]=1;
		end
	//7
	8'h7 : begin 
		HexSeg[5]=1;HexSeg[4]=1;HexSeg[6]=1;HexSeg[3]=1;
		end
	//8
	8'h8 : begin 
		HexSeg[0]=0;HexSeg[1]=0;HexSeg[2]=0;HexSeg[3]=0;HexSeg[4]=0;HexSeg[5]=0;HexSeg[6]=0;
		end
	//9
	8'h9 : begin 
		HexSeg[4]=1;
		end
	endcase 
  end 
endmodule

