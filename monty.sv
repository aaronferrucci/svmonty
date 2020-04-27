`default_nettype none
class Monty #(GOAT_COUNT=2);
  typedef enum {GOAT=1, PRIZE=0} t_door;

  int valid = 1;
  rand t_door doors[3];
  rand int unsigned stay;
  rand int unsigned show;
  rand int unsigned switch;

  constraint c_goat_count {
    doors.sum() == GOAT_COUNT;
  };

  constraint c_stay {
    stay < $size(doors);
  };

  // constraints are "bidirectional" without these constraints, which leads
  // to non-uniform distribution and unexpected results.
  constraint order0 { solve doors before stay;}
  constraint order1 { solve stay before show;}

  constraint c_show {
    show < $size(doors);
    show != stay;
    doors[show] == GOAT;
  };

  constraint c_switch {
    switch < $size(doors);
    switch != stay;
    switch != show;
  }

  covergroup results;
    option.per_instance = 1;
    stay: coverpoint doors[stay] {
      bins win = {PRIZE};
    }
    switch: coverpoint doors[switch] {
      bins win = {PRIZE};
    }
    coverpoint valid {
      bins valid_game = {1};
    }
  endgroup

  function void print;
    $display("%s %s %s", doors[0], doors[1], doors[2]);
    $display("\tstay: %0d (%s)", stay, doors[stay]);
    $display("\tshow: %0d (%s)", show, doors[show]);
    $display("\tswitch: %0d (%s)", switch, doors[switch]);
  endfunction

  function new;
    results = new;
  endfunction
endclass

module top;


  initial begin

    Monty monty = new;
    repeat (10000) begin
      if (!monty.randomize()) begin
        $display("error in randomize");
        $finish;
      end
      monty.results.sample();
      monty.print();
    end
    $stop;
    
  end
endmodule


`default_nettype wire
