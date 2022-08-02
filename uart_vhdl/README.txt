uart_vhdl

uart_vhdl is a customizable UART intended to mimic the functionality
of the Xilinx UartLite soft IP (minus the AXI4 interface at this time).
It has not been tested on hardware but passes synthesis with no 
unexpected warnings.

----------------------------- REQUIREMENTS -----------------------------
0) Pass timing @100MHz
1) Configurable baud rate      (110 - 256000)
2) Parameterizable data width 
3) Parameterizable parity bit  (off/on, odd/even)
4) Parameterizable TX/RX FIFO depth 

----------------------------- INSTRUCTIONS -----------------------------
0) Run ./script/createproject.tcl 
	-> This is a script that creates a Libero project imports all 
	   HDL, wave configuration, and testbench files from /source, 
	   then runs synthesis.

1) Open ./scripts/modelsim_compile.tcl 
	a) Ensure the paths under the "DIRECTORY DEFINES" section
	   are set correctly. 
	  
2) Open ModelSim and run ./scripts/modelsim_compile.tcl to
   run testbenches.
	a) First time run: 
		- Use 'source' with no arguments.
		-> source ./modelsim_compile.tcl 
		
	b) Normal use: 
		- Use 'src' with arguments specifying what testbench
		  to run. Examples shown below. Use "-h" or "--help"
		  to show all valid arguments. 
		-> src ./modelsim_compile.tcl -fifo_sync
		-> src ./modelsim_compile.tcl -tx 
		
	
----------------------------- DIRECTORY --------------------------------
³   README.txt
³   
/scripts
³       createproject.tcl      - Libero tcl script to create project
³       modelsim_compile.tcl   - ModelSim tcl script to run sims
³       src_with_args.tcl      - modelsim_compile.tcl dependency
³       
/source
    /hdl
    ³       fifo_sync.vhd       
    ³       uart_baudgen.vhd    
    ³       uart_demo.vhd
    ³       uart_rx.vhd
    ³       uart_top.vhd
    ³       uart_tx.vhd
    ³       
    /simulation
    ³       fifo_sync_tb.do
    ³       uart_baudgen_tb.do
    ³       uart_rx_tb.do
    ³       uart_top_tb.do
    ³       uart_tx_tb.do
    ³       
    /stimulus
    ³       fifo_sync_tb.sv
    ³       ref_uart_rx.sv
    ³       ref_uart_tx.sv
    ³       uart_baudgen_tb.sv
    ³       uart_rx_tb.sv
    ³       uart_top_tb.sv
    ³       uart_tx_tb.sv
	
