# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in fill.v to working dir
# could also have multiple verilog files
vlog score.v

#load simulation using score as the top level simulation module
vsim -L altera_mf_ver score

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}



#clock
force {clock} 0 0ms, 1 {5ms} -r 10ms

#Resetn	active low
force {resetn} 1'b0
run 10ms
force {resetn} 1'b1
run 10ms 
force {score_enable} 1'b1
force {recipe} 18'b111_100_101_110_001
force {cake_caught} 18'b18'b111_100_101_110_001
run 1000ms

#Resetn	active low
force {resetn} 1'b0
run 10ms
force {resetn} 1'b1
force {recipe} 18'b111_110_001_101_011
force {cake_caught} 18'b18'b111_101_101_110_001
run 1000ms

