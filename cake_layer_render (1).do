vlib work
vlog cherry_render.v
vsim -L altera_mf_ver cherry_render

log {/*}
add wave {/*}

#set clock
force clk 0 0, 1 10ns -repeat 20ns

force resetn 0
run 20ns
force resetn 1
run 20ns

force go_cherry 1
force x_init_loc 2#011_1100
force y_init_loc 2#000_0000
run 1000ns 

#force go_shift 1
#run 200ns
