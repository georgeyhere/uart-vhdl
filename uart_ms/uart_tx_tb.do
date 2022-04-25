onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /uart_tx_tb/i_clk
add wave -noupdate /uart_tx_tb/i_rstn
add wave -noupdate -divider {UART TX}
add wave -noupdate /uart_tx_tb/i_din
add wave -noupdate /uart_tx_tb/i_valid
add wave -noupdate /uart_tx_tb/DUT/o_baud_en
add wave -noupdate /uart_tx_tb/o_busy
add wave -noupdate -divider {UART TX INTERNAL}
add wave -noupdate /uart_tx_tb/DUT/o_baud_en
add wave -noupdate /uart_tx_tb/DUT/i_baud
add wave -noupdate /uart_tx_tb/o_TX
add wave -noupdate -radix unsigned /uart_tx_tb/DUT/tx_count
add wave -noupdate /uart_tx_tb/DUT/tx_queue
add wave -noupdate /uart_tx_tb/DUT/STATE
add wave -noupdate -divider {UART RX}
add wave -noupdate /uart_tx_tb/uart_rx_ref/o_rx_dvalid
add wave -noupdate /uart_tx_tb/uart_rx_ref/o_rx_data
add wave -noupdate -divider {RX INTERNAL}
add wave -noupdate /uart_tx_tb/uart_rx_ref/STATE
add wave -noupdate /uart_tx_tb/uart_rx_ref/rx_data_r
add wave -noupdate -divider BAUD
add wave -noupdate /uart_tx_tb/baudgen_i/count_baud
add wave -noupdate /uart_tx_tb/baudgen_i/count_fra_adj
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {350174 ps} 0}
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
WaveRestoreZoom {349864 ps} {351208 ps}
