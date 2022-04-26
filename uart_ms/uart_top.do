onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /uart_top_tb/PARITY_EN
add wave -noupdate /uart_top_tb/i_clk
add wave -noupdate /uart_top_tb/i_rstn
add wave -noupdate -divider {UART TX}
add wave -noupdate /uart_top_tb/DUT/uart_tx/STATE
add wave -noupdate /uart_top_tb/DUT/uart_tx/i_valid
add wave -noupdate /uart_top_tb/DUT/uart_tx/i_din
add wave -noupdate -radix unsigned /uart_top_tb/DUT/uart_tx/tx_count
add wave -noupdate /uart_top_tb/DUT/uart_tx/tx_queue
add wave -noupdate /uart_top_tb/DUT/uart_tx/parity
add wave -noupdate /uart_top_tb/DUT/uart_tx/i_baud
add wave -noupdate /uart_top_tb/TX
add wave -noupdate -divider {UART RX}
add wave -noupdate /uart_top_tb/DUT/uart_rx/q2_RX
add wave -noupdate /uart_top_tb/DUT/uart_rx/i_baud_x16
add wave -noupdate /uart_top_tb/DUT/uart_rx/STATE
add wave -noupdate -radix unsigned /uart_top_tb/DUT/uart_rx/rx_count
add wave -noupdate /uart_top_tb/DUT/uart_rx/parity
add wave -noupdate /uart_top_tb/DUT/uart_rx/rx_data
add wave -noupdate /uart_top_tb/DUT/uart_rx/i_RX
add wave -noupdate /uart_top_tb/DUT/uart_rx/o_valid
add wave -noupdate /uart_top_tb/DUT/uart_rx/o_dout
add wave -noupdate /uart_top_tb/o_uart_rx_error
add wave -noupdate -divider {RX CONSTANTS}
add wave -noupdate /uart_top_tb/DUT/uart_rx/FRAME_WIDTH
add wave -noupdate /uart_top_tb/DUT/uart_rx/DATA_WIDTH
add wave -noupdate /uart_top_tb/DUT/uart_rx/PARITY_EN
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {20 ps} 0}
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
WaveRestoreZoom {0 ps} {14800 ps}
