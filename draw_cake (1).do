vlib work
vlog game_server.v
vsim -L altera_mf_ver cake_rain

log {/*}
add wave {/*}

#set clock
force CLOCK_50 0 0, 1 10ns -repeat 20ns

force KEY[0] 0
run 20ns
force KEY[0] 1
force KEY[1] 0
run 20ns

force KEY[1] 1
run 10000ns

