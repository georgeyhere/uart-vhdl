onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /uart_tx_tb/DUT/i_clk
add wave -noupdate /uart_tx_tb/DUT/i_rstn
add wave -noupdate /uart_tx_tb/DUT/i_baud_x16
add wave -noupdate -divider INPUT
add wave -noupdate /uart_tx_tb/DUT/i_din
add wave -noupdate /uart_tx_tb/DUT/i_valid
add wave -noupdate -divider INTERNAL
add wave -noupdate /uart_tx_tb/DUT/tx_count
add wave -noupdate /uart_tx_tb/DUT/tx_queue
add wave -noupdate -divider OUTPUT
add wave -noupdate /uart_tx_tb/DUT/o_TX
add wave -noupdate -divider -height 27 RX
add wave -noupdate /uart_tx_tb/uart_rx_ref/i_rx
add wave -noupdate /uart_tx_tb/uart_rx_ref/o_rx_data
add wave -noupdate /uart_tx_tb/uart_rx_ref/o_rx_dvalid
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
WaveRestoreZoom {316401 fs} {339243 fs}
