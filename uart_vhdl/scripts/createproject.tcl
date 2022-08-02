# Microsemi Tcl Script
# libero
# Date: Fri Jun 10 10:51:45 2022
# Directory C:\Users\GY34427\Documents\projects\work\scripts
# File C:\Users\GY34427\Documents\projects\work\scripts\createproject.tcl


new_project -location {../uart_vhdl} -name {uart_vhdl} -project_description {} -block_mode 0 -standalone_peripheral_initialization 0 -instantiate_in_smartdesign 1 -ondemand_build_dh 1 -use_relative_path 0 -linked_files_root_dir_env {} -hdl {VHDL} -family {SmartFusion2} -die {M2S010} -package {484 FBGA} -speed {STD} -die_voltage {1.2} -part_range {COM} -adv_options {DSW_VCCA_VOLTAGE_RAMP_RATE:100_MS} -adv_options {IO_DEFT_STD:LVCMOS 3.3V} -adv_options {PLL_SUPPLY:PLL_SUPPLY_25} -adv_options {RESTRICTPROBEPINS:1} -adv_options {RESTRICTSPIPINS:0} -adv_options {SYSTEM_CONTROLLER_SUSPEND_MODE:0} -adv_options {TEMPR:COM} -adv_options {VCCI_1.2_VOLTR:COM} -adv_options {VCCI_1.5_VOLTR:COM} -adv_options {VCCI_1.8_VOLTR:COM} -adv_options {VCCI_2.5_VOLTR:COM} -adv_options {VCCI_3.3_VOLTR:COM} -adv_options {VOLTR:COM} 
import_files \
         -convert_EDN_to_HDL 0 \
         -hdl_source {../source/hdl/fifo_sync.vhd} \
         -hdl_source {../source/hdl/uart_baudgen.vhd} \
         -hdl_source {../source/hdl/uart_demo.vhd} \
         -hdl_source {../source/hdl/uart_rx.vhd} \
         -hdl_source {../source/hdl/uart_top.vhd} \
         -hdl_source {../source/hdl/uart_tx.vhd} 
import_files \
         -convert_EDN_to_HDL 0 \
         -simulation {../source/simulation/fifo_sync_tb.do} \
         -simulation {../source/simulation/uart_baudgen_tb.do} \
         -simulation {../source/simulation/uart_rx_tb.do} \
         -simulation {../source/simulation/uart_top_tb.do} \
         -simulation {../source/simulation/uart_tx_tb.do} 
import_files \
         -convert_EDN_to_HDL 0 \
         -stimulus {../source/stimulus/fifo_sync_tb.sv} \
         -stimulus {../source/stimulus/ref_uart_rx.sv} \
         -stimulus {../source/stimulus/ref_uart_tx.sv} \
         -stimulus {../source/stimulus/uart_baudgen_tb.sv} \
         -stimulus {../source/stimulus/uart_rx_tb.sv} \
         -stimulus {../source/stimulus/uart_top_tb.sv} \
         -stimulus {../source/stimulus/uart_tx_tb.sv} 
build_design_hierarchy 
set_root -module {uart_demo::work} 
run_tool -name {SYNTHESIZE} 
