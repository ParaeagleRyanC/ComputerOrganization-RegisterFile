##########################################################################
#
# regfile_sim.tcl
# Author: Ryan Chiang
# Class: ECEN 323
# Date: 01/23/2023
#
# Description: 
#   This .tcl script will perform a simulation on regfile.sv by
#   writing a negative value to one register a positive value the other.
#   As well as writing a non-zero to register x0.
#   Finally we read from the three registers that was just written to
#   and making sure that we read a 0 from x0.
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

# No reset needed for this simulation
# Issue a global reset
# add_force rst 1
# run 10 ns

# Set all ports to 0s for 10 ns before actual simulation
add_force writeData 00000000 -radix hex
add_force writeReg 00000
add_force write 0
add_force readReg1 00000
add_force readReg2 00000
run 20 ns

# Write 0x80000000 to register x1
# and set write (signal to write) to 1 for 20 ns
add_force writeData 80000000 -radix hex
add_force writeReg 00001
add_force write 1
run 20 ns

# Write 0x00000001 to register x2
# and set write (signal to write) to 1 for 20 ns
add_force writeData 00000001 -radix hex
add_force writeReg 00010
add_force write 1
run 20 ns

# Write 0x00000001 to register x0
# and set write (signal to write) to 1 for 20 ns
add_force writeData 00000001 -radix hex
add_force writeReg 00000
add_force write 1
run 20 ns

# Set write (signal to write) to 0 for 20 ns
add_force write 0
run 20 ns

# Read from readReg1 (register x1) and readReg2 (register x2) for 20 ns
add_force readReg1 00001
add_force readReg2 00010
run 20 ns

# Read from readReg1 (register x0) for 20 ns
add_force readReg1 00000
run 20 ns

# Run the circuit for 20 ns
run 20 ns

# End of simulation
