vlib work
vlog game_server.v
vsim -L altera_mf_ver game_top


log {/*}
add wave {/*}

#set clock
force clk 0 0, 1 10ns -repeat 20ns

force resetn 0
run 20ns
force resetn 1
run 20ns

force game_start 0
#run 20ns
force game_start 1
run 40ns
force game_start 0

run 30000000000ns