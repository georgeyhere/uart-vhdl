onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /uart_baudgen_tb/i_clk
add wave -noupdate /uart_baudgen_tb/i_rstn
add wave -noupdate -divider {BAUD TICK}
add wave -noupdate /uart_baudgen_tb/i_baud_en
add wave -noupdate /uart_baudgen_tb/i_fra_adj_x16
add wave -noupdate -divider {16x BAUD TICK}
add wave -noupdate /uart_baudgen_tb/i_baud_x16_en
add wave -noupdate /uart_baudgen_tb/o_baud_x16
add wave -noupdate -divider INTERNAL
add wave -noupdate /uart_baudgen_tb/DUT/count_baudx16
add wave -noupdate /uart_baudgen_tb/DUT/count_fra_adjx16
add wave -noupdate /uart_baudgen_tb/DUT/count_baud
add wave -noupdate /uart_baudgen_tb/DUT/count_fra_adj
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {108980 ps} 0}
quietly wave cursor active 1
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
WaveRestoreZoom {102973 ps} {115798 ps}
