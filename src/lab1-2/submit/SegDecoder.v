`timescale 1ns / 1ps

module SegDecoder (
    input wire [3:0] data,
    input wire point,
    input wire LE,

    output wire a,
    output wire b,
    output wire c,
    output wire d,
    output wire e,
    output wire f,
    output wire g,
    output wire p
);
  
  wire wire0, wire1, wire2, wire3;
  wire inv_wire0, inv_wire1, inv_wire2, inv_wire3;
  assign {wire3 ,wire2, wire1, wire0} = data;
  assign {inv_wire0, inv_wire1, inv_wire2, inv_wire3} = {~wire0, ~wire1, ~wire2, ~wire3};
  
  // minterms for number 0-f
  wire [15:0] and_gate;
  assign and_gate[1] = wire0 & inv_wire1 & inv_wire2 & inv_wire3; // 1
  assign and_gate[4] = inv_wire0 & inv_wire1 & wire2 & inv_wire3; // 4
  assign and_gate[11] = wire0 & wire1 & inv_wire2 & wire3; // B
  assign and_gate[13] = wire0 & inv_wire1 & wire2 & wire3; // D
  // fill your code for remaining numbers
  
  // SegDecoder for a
  wire a_or, a_result;
  assign a_or = and_gate[1] | and_gate[4] | and_gate[11] | and_gate[13];
  assign a_result = a_or | LE;
  assign a = a_result;
  
 // fill your code for decoder of b-g and p
 

endmodule