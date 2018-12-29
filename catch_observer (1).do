vlib work
vlog catch_observer.v
vsim -L altera_mf_ver catch_observer

log {/*}
add wave {/*}

#set clock
force clk 0 0, 1 10ns -repeat 20ns

force resetn 0
run 20ns
force resetn 1
run 20ns


force cake1_x 2#1001101
force cake1_y 2#