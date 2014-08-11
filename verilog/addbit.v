module addbit(a, b, ci, sum, co);
   input a;
   input b;
   input ci;
   output sum;
   output co;

   wire a;
   wire b;
   wire ci;
   wire sum;
   wire co;

   assign {co, sum} = a + b + ci;
endmodule
