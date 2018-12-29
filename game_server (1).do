vlib work
vlog game_server.v
vsim game_server

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
run 20ns

force done_cherry 1
run 20ns
force caught_cherry 0
run 20ns
force {done_cake1} 1
run 20ns
force {caught_cake1} 0
run 20ns
force done_buffer 1
run 20ns
force done_erase 1
run 20ns 
