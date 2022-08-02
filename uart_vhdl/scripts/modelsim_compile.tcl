# modelsim_compile.tcl
#
# This is a tickle script to run testbenches from a Libero
# project in ModelSim. See ../README.txt for more information.
# 
# -------------------- IMPORTANT !!!!!! --------------------- #
# BEFORE RUNNING THIS SCRIPT:
# - Make sure that the directories under "SCRIPT CONFIG" 
#   are set correctly.
#
# THE FIRST TIME YOU RUN THIS SCRIPT: 
# - Use 'source' with no arguments.
# 	 -> source ./modelsim_compile.tcl
#
# NORMAL USE:
# - Use 'src' with arguments. Examples shown below.
#    -> src ./modelsim_compile.tcl -fifo 
#    -> src ./modelsim_compile.tcl -tx 
#    -> src ./modelsim_compile.tcl --help

# -------------------- SCRIPT CONFIG ------------------------ #
source ./src_with_args.tcl

# DIRECTORY DEFINES
quietly set SM2_DIR "C:/Users/GY34427/Documents/programs/microsemi/Designer/lib/modelsimpro/precompiled/vlog/SmartFusion2"
quietly set ACTELLIBNAME SmartFusion2
quietly set PROJECTNAME uart_vhdl
quietly set PROJECT_DIR ../${PROJECTNAME}/

# FILE DEFINITIONS
quietly set ARGS(fifo_sync)    -fifo
quietly set ARGS(uart_baudgen) -baudgen
quietly set ARGS(uart_rx)      -rx
quietly set ARGS(uart_tx)      -tx
quietly set ARGS(uart_top)     -top
quietly set ARGS(uart_demo)    -demo 
quietly set ARGS(nosim)        -nosim

# --------------------- SCRIPT SETUP ------------------------ #

# LOCAL VARS
quietly set INPUTVALID 0 
quietly set SIMTORUN   foo

# FUNCTION TO PRINT COMMANDS
proc print_cmds {} {
	echo ""
	echo "Valid arguments:"
	echo "-fifo    : run fifo_sync_tb"
	echo "-baudgen : run uart_baudgen_tb"
	echo "-rx      : run uart_rx_tb"
	echo "-tx      : run uart_tx_tb"
	echo "-top     : run uart_top_tb"
	echo "-nosim   : compile all HDL files; do not launch testbenches"
	echo ""
	return 
}

# -------------------- SCRIPT START ------------------------ #

# check if user has provided an argument 
if {$argc>0} {
	quietly set USERINPUT [lindex $argv 0]
}
if {$argc>1 || $argc==0} {
	echo ""
	echo "Please add the name of a single testbench to run."
	print_cmds
	return 
} elseif {${USERINPUT} == "--help" || ${USERINPUT} == "-h"}  {
	print_cmds
	echo ""
	echo ""
	return 
} 

#foreach index [array names ARGS] {
#	puts "ARGS($index): $ARGS($index)"
#}

# check if argument is valid
foreach index [array names ARGS] {
	if {$USERINPUT == $ARGS($index)} {
		quietly set INPUTVALID 1
		set SIMTORUN   $index
		echo $SIMTORUN 
		break  
	}
}
if {$INPUTVALID == 0} {
	echo ""
	echo "Invalid argument."
	print_cmds
	return 
}


# check if simulation library already exists.
if {[file exists presynth/_info]} {
	echo "INFO: Simulation library presynth already exists"
} else {
	file delete -force presynth
	vlib presynth
}

# map logical libraries to physical libraries
vmap presynth presynth
vmap SmartFusion2 ${SM2_DIR}


# add VHDL source files 
vcom -2008 -explicit -work presynth "${PROJECT_DIR}/hdl/fifo_sync.vhd"
vcom -2008 -explicit -work presynth "${PROJECT_DIR}/hdl/uart_baudgen.vhd"
vcom -2008 -explicit -work presynth "${PROJECT_DIR}/hdl/uart_tx.vhd"
vcom -2008 -explicit -work presynth "${PROJECT_DIR}/hdl/uart_rx.vhd"
vcom -2008 -explicit -work presynth "${PROJECT_DIR}/hdl/uart_top.vhd"
vcom -2008 -explicit -work presynth "${PROJECT_DIR}/hdl/uart_demo.vhd"

# add SystemVerilog reference designs (testbench dependencies)
vlog -sv -work presynth "${PROJECT_DIR}/stimulus/ref_uart_rx.sv"
vlog -sv -work presynth "${PROJECT_DIR}/stimulus/ref_uart_tx.sv"

# launch the selected testbench
if {$SIMTORUN == "nosim"} {
	return 
}
vlog -sv -work presynth "${PROJECT_DIR}/stimulus/${SIMTORUN}_tb.sv"
vsim -L SmartFusion2 -L presynth -t 1fs presynth.${SIMTORUN}_tb
do "${PROJECT_DIR}/simulation/${SIMTORUN}_tb.do"
add log -r /* 
run -all


