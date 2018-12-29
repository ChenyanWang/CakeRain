vlib work
vlog recipe_render.v
vsim -L altera_mf_ver recipe_render

log {/*}
add wave {/*}

#set clock
force clk 0 0, 1 10ns -repeat 20ns

force resetn 0
run 20ns
force resetn 1
run 20ns

force ld_recipe 1
run 500ns 
force ld_recipe 0