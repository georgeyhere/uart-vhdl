onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /fifo_sync_tb/i_clk
add wave -noupdate /fifo_sync_tb/i_rstn
add wave -noupdate -divider Inputs
add wave -noupdate /fifo_sync_tb/fifo_wr
add wave -noupdate /fifo_sync_tb/fifo_rd
add wave -noupdate /fifo_sync_tb/fifo_din
add wave -noupdate -divider {Data Out}
add wave -noupdate /fifo_sync_tb/fifo_dout
add wave -noupdate -divider {Status Flags}
add wave -noupdate /fifo_sync_tb/status_almost_empty
add wave -noupdate /fifo_sync_tb/status_empty
add wave -noupdate /fifo_sync_tb/status_almost_full
add wave -noupdate /fifo_sync_tb/status_full
add wave -noupdate /fifo_sync_tb/status_fill
add wave -noupdate /fifo_sync_tb/status_overrun
add wave -noupdate -divider Internal
add wave -noupdate /fifo_sync_tb/DUT/wrPtr
add wave -noupdate /fifo_sync_tb/DUT/rdPtr
add wave -noupdate /fifo_sync_tb/DUT/fillCount
add wave -noupdate /fifo_sync_tb/DUT/overrun_next_wr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {100 fs} 0}
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
WaveRestoreZoom {0 fs} {529 fs}
