onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /uart_top_tb/i_clk
add wave -noupdate /uart_top_tb/i_rstn
add wave -noupdate -divider {TX FIFO}
add wave -noupdate /uart_top_tb/i_tx_wr
add wave -noupdate /uart_top_tb/i_tx_data
add wave -noupdate /uart_top_tb/o_tx_full
add wave -noupdate /uart_top_tb/o_tx_fill
add wave -noupdate /uart_top_tb/DUT/fifo_tx/i_rd
add wave -noupdate /uart_top_tb/DUT/fifo_tx/o_dout
add wave -noupdate -divider {TX UART}
add wave -noupdate /uart_top_tb/DUT/uart_tx/i_valid
add wave -noupdate /uart_top_tb/DUT/uart_tx/i_din
add wave -noupdate /uart_top_tb/DUT/uart_tx/tx_count
add wave -noupdate /uart_top_tb/DUT/uart_tx/STATE
add wave -noupdate /uart_top_tb/DUT/uart_tx/o_busy
add wave -noupdate -divider {RX UART}
add wave -noupdate /uart_top_tb/DUT/uart_rx/STATE
add wave -noupdate /uart_top_tb/DUT/uart_rx/o_valid
add wave -noupdate /uart_top_tb/DUT/uart_rx/rx_count
add wave -noupdate /uart_top_tb/DUT/uart_rx/o_dout
add wave -noupdate /uart_top_tb/DUT/uart_rx/o_error
add wave -noupdate -divider {RX FIFO}
add wave -noupdate /uart_top_tb/DUT/fifo_rx/i_wr
add wave -noupdate /uart_top_tb/DUT/fifo_rx/i_din
add wave -noupdate /uart_top_tb/DUT/fifo_rx/o_fill
add wave -noupdate /uart_top_tb/DUT/fifo_rx/i_rd
add wave -noupdate /uart_top_tb/DUT/fifo_rx/o_dout
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {20036548 fs} 0}
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
WaveRestoreZoom {20036437 fs} {20036967 fs}
