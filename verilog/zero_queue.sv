`timescale 1 ns / 1 ps

module zero_queue
  #(parameter integer QUEUE_DEPTH_WIDTH = 3,
    parameter integer DATA_WIDTH = 3)
   (input wire clock,

    // Input ports
    input wire in_valid,
    input wire [DATA_WIDTH - 1:0] in_data,
    output wire in_ready,

    // Output ports
    output wire out_valid,
    output wire [DATA_WIDTH - 1:0] out_data,
    input wire out_ready);

   // *_valid being true means the curresponding *_data contains valid data
   // at this clock cycle. *_ready being true means the available data will be
   // fetched at this clock cycle. Data fetching happens IFF both *_valid and
   // *_ready are both high.
   localparam QUEUE_DEPTH = 1 << QUEUE_DEPTH_WIDTH;

   // Number of input and output data with overflow one bit longer than
   // the queue depth in order to distinguish queue full and queue empty
   reg [QUEUE_DEPTH_WIDTH:0] in_count = 0;
   reg [QUEUE_DEPTH_WIDTH:0] out_count = 0;
   // Data queue
   reg [DATA_WIDTH - 1:0] queue [0:(QUEUE_DEPTH - 1)];
   wire [QUEUE_DEPTH_WIDTH - 1:0] queue_write_ptr =
                                  in_count[QUEUE_DEPTH_WIDTH - 1:0];
   wire [QUEUE_DEPTH_WIDTH - 1:0] queue_read_ptr =
                                  out_count[QUEUE_DEPTH_WIDTH - 1:0];
   wire in_parity = in_count[QUEUE_DEPTH_WIDTH];
   wire out_parity = out_count[QUEUE_DEPTH_WIDTH];

   wire ptr_overlap = queue_write_ptr == queue_read_ptr;
   wire ptr_parity_same = in_parity == out_parity;
   wire queue_empty = ptr_overlap && ptr_parity_same;
   // This is enough to determine whether the queue is full if we can garentee
   // that the queue is never overfilled.
   wire queue_full = ptr_overlap && !ptr_parity_same;

   assign in_ready = !queue_full || out_ready;
   assign out_valid = !queue_empty || in_valid;

   assign out_data = queue_empty ? in_data : queue[queue_read_ptr];

   always @(posedge clock) begin
      // Read the data
      if (in_ready && in_valid) begin
         in_count <= in_count + 1;
         // This write may not be necessary when out_ready == true. However
         // an unconditional write is probably simpler
         queue[queue_write_ptr] <= in_data;
      end
   end

   always @(posedge clock) begin
      // Write data
      if (out_valid && out_ready) begin
         out_count <= out_count + 1;
      end
   end
endmodule

module zero_queue_test();
   reg clock = 0;

   reg [15:0] in_data = 0;
   reg in_valid = 0;
   wire in_ready;

   wire [15:0] out_data;
   wire out_valid;
   reg out_ready = 0;

   zero_queue
     #(.QUEUE_DEPTH_WIDTH(2),
       .DATA_WIDTH(16))
   zq(.clock(clock),

      .in_valid(in_valid),
      .in_ready(in_ready),
      .in_data(in_data),

      .out_valid(out_valid),
      .out_ready(out_ready),
      .out_data(out_data));

   always
     #1 clock = !clock;

   reg [15:0] count = 0;
   reg in_enable = 0;
   reg out_enable = 0;

   always @(posedge clock) begin
      count <= count + 1;
      if (in_enable) begin
         in_valid <= 1;
      end else begin
         in_valid <= 0;
      end
      if (in_ready && in_valid) begin
         in_data <= in_data + 1;
      end
      if (out_enable) begin
         out_ready <= 1;
      end else begin
         out_ready <= 0;
      end
   end

   initial
     #64 $finish;

   initial begin
      #2 in_enable = 1;
      #4 in_enable = 0;
      #2 in_enable = 1;
      #30 in_enable = 0;
   end

   initial begin
      out_enable = 1;
      #8 out_enable = 0;
      #12 out_enable = 1;
      #30 out_enable = 0;
   end

   // Hier demo here
   initial begin
      $display("+--------------------------------------+");
      $display("|    |       in       |       out      |");
      $display("| cnt|data|ready|valid|data|ready|valid|");
      $display("+--------------------------------------+");
      $monitor("|%h|%h|    %h|    %h|%h|    %h|    %h|",
               count, in_data, in_ready, in_valid, out_data, out_ready,
               out_valid);
   end
endmodule
