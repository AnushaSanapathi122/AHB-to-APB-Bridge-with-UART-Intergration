// Code your design here
module tb;

reg clk = 0;
always #5 clk = ~clk;

reg reset;
reg [31:0] HADDR;
reg [31:0] HWDATA;
reg HWRITE, HSEL, HREADY;

wire tx;
wire [31:0] HRDATA;

top uut(
    .clk(clk), .reset(reset),
    .HADDR(HADDR),
    .HWDATA(HWDATA),
    .HWRITE(HWRITE),
    .HSEL(HSEL),
    .HREADY(HREADY),
    .tx(tx),
    .HRDATA(HRDATA)
);

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,tb);

    reset = 1; HSEL = 0; HREADY = 0;
    
@(posedge clk);
    reset = 0;

    // WRITE 1 (A5)
    HSEL = 1; HREADY = 1; HWRITE = 1;
    HADDR = 32'h1;
    @(posedge clk);
    HWDATA = 32'hA5;

    // WRITE 2 (3C)
    HADDR = 32'h2;
    @(posedge clk);
    HWDATA = 32'h3C;

    @(posedge clk);
    @(posedge clk);

    HSEL = 0;

    #200;
    $finish;
end

endmodule
