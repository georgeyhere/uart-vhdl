onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /uart_rx_tb/i_clk
add wave -noupdate /uart_rx_tb/i_rstn
add wave -noupdate -divider {UART RX BAUD}
add wave -noupdate /uart_rx_tb/DUT/i_baud_x16
add wave -noupdate /uart_rx_tb/DUT/o_baud_x16_en
add wave -noupdate -divider {UART RX OUTPUT}
add wave -noupdate /uart_rx_tb/DUT/o_valid
add wave -noupdate /uart_rx_tb/DUT/o_dout
add wave -noupdate /uart_rx_tb/DUT/o_error
add wave -noupdate -divider {UART RX INTERNAL}
add wave -noupdate /uart_rx_tb/DUT/q2_RX
add wave -noupdate /uart_rx_tb/DUT/STATE
add wave -noupdate /uart_rx_tb/DUT/rx_count
add wave -noupdate /uart_rx_tb/DUT/rx_data
add wave -noupdate /uart_rx_tb/DUT/baud_count
add wave -noupdate -divider {UART TX}
add wave -noupdate /uart_rx_tb/uart_tx_i/i_baud
add wave -noupdate /uart_rx_tb/uart_tx_i/i_din
add wave -noupdate /uart_rx_tb/uart_tx_i/i_valid
add wave -noupdate /uart_rx_tb/uart_tx_i/tx_queue
add wave -noupdate /uart_rx_tb/uart_tx_i/STATE
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {86324 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 207
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
WaveRestoreZoom {350765 ps} {351160 ps}
