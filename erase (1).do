vlib work
vlog game_server.v
vsim -L altera_mf_ver erase_screen

log {/*}
add wave {/*}

#set clock
force clk 0 0, 1 10ns -repeat 20ns

force resetn 0
run 20ns
force resetn 1
run 20ns

force go_erase 1
run 400000ns 
force go_erase 0

run 100ns 