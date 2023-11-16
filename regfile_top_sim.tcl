##########################################################################
#
# regfile_top_sim.tcl
# Author: Ryan Chiang
# Class: ECEN 323
# Date: 01/23/2023
#
# Description: 
#   This .tcl script will perform a on regfile_top.sv by
#   writing the value 0x00001234 to register 1 and
#   writing the value 0x00003678 to register 2.
#   Then perform an add operation between register 1 and register 2 
#   and store the result in register 3.
#
##########################################################################

# restart the simulation at time 0
restart

# Run circuit with no input stimulus settings
run 20 ns

# Set the clock to oscillate with a period of 10 ns
add_force clk {0} {1 5} -repeat_every 10

# Run the circuit for two clock cycles
run 20 ns

# Issue a global reset (btnu) for 10 ns
add_force btnu 1
run 10 ns

# Lower global reset (btnu) for 10 ns
add_force btnu 0
run 10 ns

# Set all ports to 0s for 10 ns before actual simulation
add_force btnc 0 
add_force btnl 0
add_force btnd 0
add_force sw 0000 -radix hex
run 10 ns

# Load 1 into write address (0 in others) for 20 ns
add_force sw 0400 -radix hex
add_force btnl 1
run 20 ns

# Lower load register signal (btnl) for 20 ns
add_force btnl 0
run 20 ns

# Load 0x00001234 into register 1 for 20 ns
add_force sw 1234 -radix hex
add_force btnc 1
run 20 ns

# Lower write register signal (btnc) for 20 ns
add_force btnc 0
run 20 ns

# Load 2 into write address (0 in others) for 20 ns
add_force sw 0800 -radix hex
add_force btnl 1
run 20 ns

# Lower load register signal (btnl) for 20 ns
add_force btnl 0
run 20 ns

# Load 0x00003678 into register 1 for 20 ns
add_force sw 3678 -radix hex
add_force btnc 1
run 20 ns

# Lower write register signal (btnc) for 20 ns
add_force btnc 0
run 20 ns

# Load 3 into write address, 1 in A port address, 2 in B port address for 20 ns
add_force sw 0c41 -radix hex
add_force btnl 1
run 20 ns

# Lower load register signal (btnl) for 20 ns
add_force btnl 0
run 20 ns

# Perform Addition Operation for 20 ns
add_force sw 0002 -radix hex
add_force btnc 1
run 20 ns

# Lower write register signal (btnc) for 20 ns
add_force btnc 0
run 20 ns

# Run the circuit for 20 ns
run 20 ns

# End of simulation
