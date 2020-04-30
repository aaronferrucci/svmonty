all: compile run

compile:
	vlog -sv monty.sv

gui:
	vsim top

run:
	vopt top -o top_debug
	vsim \
	  -c \
	  -sv_seed random \
	  top_debug \
          -do "coverage save -onexit top.ucdb; run 0us; exit -code 0"

cov:
	vcover report -all -details top.ucdb

clean:
	rm -rf work
	rm -f top.ucdb
	rm -f transcript
