onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /uart_rx_tb/DUT/i_clk
add wave -noupdate /uart_rx_tb/DUT/i_rstn
add wave -noupdate -divider {TX stuff}
add wave -noupdate /uart_rx_tb/uart_tx_i/i_baud_x16
add wave -noupdate /uart_rx_tb/uart_tx_i/tick_count
add wave -noupdate /uart_rx_tb/uart_tx_i/tx_count
add wave -noupdate /uart_rx_tb/uart_tx_i/tx_queue
add wave -noupdate -divider Inputs
add wave -noupdate /uart_rx_tb/DUT/i_RX
add wave -noupdate /uart_rx_tb/DUT/q2_RX
add wave -noupdate -divider Internal
add wave -noupdate /uart_rx_tb/DUT/STATE
add wave -noupdate /uart_rx_tb/DUT/baud_count
add wave -noupdate /uart_rx_tb/DUT/rx_count
add wave -noupdate /uart_rx_tb/DUT/rx_data
add wave -noupdate -divider Output
add wave -noupdate /uart_rx_tb/DUT/o_valid
add wave -noupdate /uart_rx_tb/DUT/o_error
add wave -noupdate /uart_rx_tb/DUT/o_dout
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {331217 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 165
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
configure wave -timelineunits fs
update
WaveRestoreZoom {15978881 fs} {16001723 fs}
