onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /uart_baudgen_tb/DUT/i_clk
add wave -noupdate /uart_baudgen_tb/DUT/i_rstn
add wave -noupdate -divider Inputs
add wave -noupdate /uart_baudgen_tb/DUT/i_divisor
add wave -noupdate /uart_baudgen_tb/DUT/i_fra_adj
add wave -noupdate -divider Internal
add wave -noupdate /uart_baudgen_tb/DUT/count_baudx16
add wave -noupdate /uart_baudgen_tb/DUT/count_fra_adj
add wave -noupdate /uart_baudgen_tb/DUT/count_baud
add wave -noupdate -divider Outputs
add wave -noupdate /uart_baudgen_tb/DUT/o_baud_x16
add wave -noupdate /uart_baudgen_tb/DUT/o_baud
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1783 ps}
