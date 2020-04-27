all: compile run

compile:
	vlog +acc +cover -sv monty.sv

gui:
	vsim top

run:
	vopt +cover +acc top -o top_debug
	vsim \
	  -c \
	  -coverage \
	  -sv_seed random \
	  top_debug \
          -do "coverage save -onexit top.ucdb; run 0us; exit -code 0"

cov:
	vcover report -all -details top.ucdb

clean:
	rm -rf work
	rm -f top.ucdb
	rm -f transcript
