`include"conv_struct.vh"
module Testbench;

    import Conv::*;

    reg clk;
    reg rst;
    data_t in_data;
    data_vector kernel;
    reg in_valid;
    wire in_ready;
    result_t result;
    wire out_valid;
    wire out_ready; 

    integer i;
    initial begin
        // fill the testcase
        $display("success!!!");
        $finish;
    end

    always begin
        #5;
        clk=~clk;
    end

    ConvUnit conv_unit (
        .clk(clk),
        .rst(rst),
        .in_data(in_data),
        .kernel(kernel),
        .in_valid(in_valid),
        .in_ready(in_ready),

        .result(result),
        .out_valid(out_valid),
        .out_ready(out_ready)
    );

    assign out_ready = 1'b1;

    `ifdef VERILATE
		initial begin
			$dumpfile({`TOP_DIR,"/Testbench.vcd"});
			$dumpvars(0,dut);
			$dumpon;
		end

        wire error;
        Judge judge (
            .clk(clk),
            .rst(rst),
            .in_data(in_data),
            .kernel(kernel),
            .in_valid(in_valid),
            .in_ready(in_ready),

            .result(result),
            .out_valid(out_valid),
            .out_ready(out_ready),
            .error(error)
        );

        always@(negedge clk)begin
            if(error)begin
                $display("fail!!!");
                $finish;
            end
        end
    `endif
    
endmodule
