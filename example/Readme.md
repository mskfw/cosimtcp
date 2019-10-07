
## General information

Example project showing the basic idea of the cosimtcp

## Server side

### ModelSim

Chang directory to modelsim:

    cd ./modelsim

run ModelSim in command line mode:

    vsim -c -do ./modelsim_do_example.tcl

or run ModelSim sim in gui mode:

    vsim -c -do ./modelsim_do_example.tcl

(modelsim will create default modelsim.ini file, if different ini is required copy yours modelsim.ini into this folder before running modelsim)

### Vivado 


Chang directory to vivado:

    cd ./vivado
    
run Vivado:

    vivado -mode batch -source vivado_do_example.tcl
        
## Client side

### Python

Go to ./tb/ folder and run:

    python ./py_example_test1.py
    
