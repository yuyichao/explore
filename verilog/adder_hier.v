`include "addbit.v"

module adder_hier (result, carry, r1, r2, ci);
   // Input Port Declarations
   input[3:0] r1;
   input[3:0] r2;
   input ci;

   // Output Port Declarations
   output[3:0] result;
   output carry;

   // Port Wires
   wire[3:0] r1;
   wire[3:0] r2;
   wire ci;
   wire[3:0] result;
   wire carry;

   // Internal variables
   wire c1;
   wire c2;
   wire c3;

   // Code Starts Here
   addbit u0 (r1[0], r2[0], ci, result[0], c1);
   addbit u1 (r1[1], r2[1], c1, result[1], c2);
   addbit u2 (r1[2], r2[2], c2, result[2], c3);
   addbit u3 (r1[3], r2[3], c3, result[3], carry);
endmodule // End Of Module adder

module tb();
   reg[3:0] r1, r2;
   reg  ci;
   wire[3:0] result;
   wire  carry;

   // Drive the inputs
   initial begin
      r1 = 0;
      r2 = 0;
      ci = 0;
      #10 r1 = 10;
      #10 r2 = 2;
      #10 ci = 1;
      #10 $display("+--------------------------------------------------------+");
      $finish;
   end

   // Connect the lower module
   adder_hier U (result, carry, r1, r2, ci);

   // Hier demo here
   initial begin
      $display("+--------------------------------------------------------+");
      $display("|  r1  |  r2  |  ci  | u0.sum | u1.sum | u2.sum | u3.sum |");
      $display("+--------------------------------------------------------+");
      $monitor("|  %h   |  %h   |  %h   |    %h    |   %h   |   %h    |   %h    |",
               r1,r2,ci, U.u0.sum, tb.U.u1.sum, tb.U.u2.sum, tb.U.u3.sum);
   end
endmodule
