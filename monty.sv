`default_nettype none
class Monty;
  typedef enum {GOAT=1, PRIZE=0} t_door;

  rand logic[1:0] goatcount;
  rand t_door doors[3];
  rand int unsigned stay;
  rand int unsigned show;
  rand int unsigned switch;
  bit valid;

  constraint c_goat_count {
    doors.sum() == goatcount;
  };

  constraint c_stay {
    stay < $size(doors);
  };

  // constraints are "bidirectional" without these constraints, which leads
  // to non-uniform distribution and unexpected results.
  constraint order {
    solve goatcount before doors;
    solve doors before stay;
    solve stay before show;
  }

  constraint c_goatcount {
    goatcount inside {[0:3]};
  }

  constraint c_show {
    show < $size(doors);
    show != stay;
    // valid for goatcount = {1, 2, 3}; skip for goatcount = 0.
    goatcount > 0 && doors[stay] == PRIZE -> doors[show] == GOAT;
  };

  constraint c_show2 {
    goatcount > 1 -> doors[show] == GOAT;
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
    coverpoint valid;

    // ignore_bins ignore_invalid = stay_stats with (!valid);
    stay_stats: cross goatcount, valid, doors[stay];
    switch_stats: cross goatcount, valid, doors[switch];

    goat_independent_stay_stats: cross valid, doors[stay] {
      ignore_bins ignore_invalid = goat_independent_stay_stats with (!valid);
    }
    goat_independent_switch_stats: cross valid, doors[switch] {
      ignore_bins ignore_invalid = goat_independent_switch_stats with (!valid);
    }
  endgroup

  function void post_randomize();
      valid = doors[show] == GOAT;
  endfunction

  function void print;
    $display("%s %s %s", doors[0], doors[1], doors[2]);
    $display("\tstay: %0d (%s)", stay, doors[stay]);
    $display("\tshow: %0d (%s)", show, doors[show]);
    $display("\tswitch: %0d (%s)", switch, doors[switch]);
    $display("\tvalid: %0d", valid);
  endfunction

  function new;
    results = new;
    results.option.name = "Modified Monty Hall Problem";
  endfunction
endclass

module top;

  Monty monty;
  initial begin

    monty = new;
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
