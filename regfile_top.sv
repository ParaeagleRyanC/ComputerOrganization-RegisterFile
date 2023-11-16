`timescale 1ns / 1ps
`include "riscv_alu_constants.sv"
/***************************************************************************
* 
* File: regfile_top.sv
*
* Author: Ryan Chiang
* Class: ECEN 323, Winter Semester 2023
* Date: 01/23/2023
*
* Module: regfile_top
*
* Description:
*    This .sv file uses is the top module that utilizes regfile module,
*    oneshot module, and alu module. 
*    This module is a simple dataflow circuit that is similar 
*    to the RISC-V datapath circuit we will create in lab 5.
*    This circuit will allow you to store values in the register file and 
*    perform ALU operations on the values stored in the ALU
*    much like the RISC-V processor.
*
****************************************************************************/


module regfile_top(clk, btnc, btnl, btnu, btnd, sw, led);

    // 1-bit inputs for global clock and 4 buttons with the following functionalities
    // Center Button - Write register
    // Left Button - Load address register
    // Up Button - Global Reset Signal
    // Down Button - Multiplexer select signal
    input wire logic clk, btnc, btnu, btnd, btnl;
	// 16-bit data input port named "sw" for the 16 switches on the Basys3 board
	input wire logic [15:0] sw;
	// 16-bit accumulator output port named "led" for the 16 leds on the Basys3 board
	output logic [15:0] led;
	
	// 1-bit reset signal
	logic rst;
	assign rst = btnu;
	
	////////// Synchronizer ////////// 
	//////////////////////////////////
	// write signals (synchronized version of btnc)
	logic btnc_d, btnc_dd, write;
	// The write counter output from the one shot module
	logic write_count;
	
	// synchronized version of btnl and btnd
	logic btnl_d, btnl_dd, btnd_d, btnd_dd;
	
	// btnc, btnd, btnl synchronizer
	always_ff@(posedge clk) begin
        if (rst) begin
			btnc_d <= 0;
			btnc_dd <= 0;
			btnl_d <= 0;
			btnl_dd <= 0;
			btnd_d <= 0;
			btnd_dd <= 0;
        end
        else begin
			btnc_d <= btnc;
			btnc_dd <= btnc_d;
			btnl_d <= btnl;
			btnl_dd <= btnl_d;
			btnd_d <= btnd;
			btnd_dd <= btnd_d;
        end
    end
    
    assign write = btnc_dd;
	
	//////////////////////////////////
	////////// Synchronizer ////////// 
	
	
	// 1-bit zero port for alu
	logic alu_zero;
	// 32-bit signal of the alu result
	logic [31:0] alu_result;
	// 15-bit resister that controls the three ports of the register file
	logic [14:0] register;
	// output signals of the register file
	logic [31:0] readData1, readData2;
	// signal for write data
	logic [31:0] writeData;
	// logic and assignment for load signal
	logic loadRegister;
	assign loadRegister = btnl_dd;
	
	
	////////// Register File /////////
	//////////////////////////////////
	
	// Reset register by the global reset signal ('btnu')
	// Load register with the bottom 15 switches (sw[14:0]) when 'btnl' is pressed.
	always_ff@(posedge clk) begin
        if (rst)
            register <= 0;
        else if (loadRegister) begin
            // the register address for the first operand (readReg1 port)
            register[4:0] <= sw[4:0];
            // the register address for the second operand (readReg2 port)
            register[9:5] <= sw[9:5];
            // the register address for the destination register (writeReg)
            register[14:10] <= sw[14:10];
        end
    end
    
    // 32-bit sign-extended value of the lower 15 switches
    logic [31:0] extended_sw;
    assign extended_sw = {{17{sw[14]}},sw[14:0]};
    assign writeData = sw[15] == 0 ? alu_result : extended_sw;
    
    // LED outputs
    // Selects the lower 16-bits of the readData1 when 'btnd' is NOT pressed 
    // and selects the upper 16-bits of the readData1 signal when 'btnd' IS pressed. 
    // This will allow the user to examine the full 32-bit value of readData1.
	assign led = !btnd_dd ? readData1[15:0] : readData1[31:16];
	
	//////////////////////////////////
	////////// Register File /////////
    
    // Instance the OneShot module for write signal (btnc)
	OneShot os_d (.clk(clk), .rst(rst), .in(write), .os(write_count));
	
	// Instance alu module
	alu reg_alu (.op1(readData1), .op2(readData2), .alu_op(sw[3:0]),
		.result(alu_result), .zero(alu_zero));
		
	// Instance regfile module
	regfile register_file (.clk(clk), .readReg1(register[4:0]), .readReg2(register[9:5]), 
	                       .writeReg(register[14:10]), .writeData(writeData), 
	                       .write(write_count), .readData1(readData1), .readData2(readData2));
    
endmodule
