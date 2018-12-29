vlib work
vlog cake_render.v
vsim -L altera_mf_ver cake_render

log {/*}
add wave {/*}

#set clock
force clk 0 0, 1 10ns -repeat 20ns

force resetn 0
run 20ns
force resetn 1
run 20ns

force go_cake 1
run 1200ns 
force go_cake 0

force go_shift 1
run 50ns

force go_shift 0
run 1500ns 


force go_cake 1
run 1200ns 

force go_shift 1
run 50ns 
force go_cake 1
run 50ns 
force go_shift 0
run 1000ns 


force go_shift 1
run 1000ns

