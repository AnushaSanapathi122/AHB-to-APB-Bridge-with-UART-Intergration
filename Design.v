// Code your design here
`timescale 1ns/1ps

module ahb_apb_bridge (
    input clk, reset,

    // AHB
    input [31:0] HADDR,
    input [31:0] HWDATA,
    input HWRITE,
    input HSEL,
    input HREADY,

    output reg [31:0] HRDATA,

    // APB
    output reg [31:0] PADDR,
    output reg [31:0] PWDATA,
    output reg PWRITE,
    output reg PSEL,
    output reg PENABLE,

    input [31:0] PRDATA
);

// FSM states
parameter IDLE = 2'd0,
          SETUP = 2'd1,
          ENABLE = 2'd2;

reg [1:0] state, next_state;

// ⭐ PIPELINE REGISTERS
reg [31:0] HADDR_reg;
reg [31:0] HWDATA_reg;
reg HWRITE_reg;


// ================= ADDRESS PHASE =================
always @(posedge clk or posedge reset) begin
    if (reset) begin
        HADDR_reg <= 0;
        HWRITE_reg <= 0;
    end 
    else if (HSEL && HREADY) begin
        HADDR_reg <= HADDR;      // Address phase
        HWRITE_reg <= HWRITE;
    end
end


// ================= DATA PHASE (FIXED ⭐) =================
always @(posedge clk or posedge reset) begin
    if (reset)
        HWDATA_reg <= 0;
    else if (HSEL && HREADY && HWRITE)  // ⭐ capture only during write
        HWDATA_reg <= HWDATA;
end


// ================= FSM =================
always @(posedge clk or posedge reset) begin
    if (reset)
        state <= IDLE;
    else
        state <= next_state;
end

always @(*) begin
    case(state)
        IDLE:   next_state = (HSEL) ? SETUP : IDLE;
        SETUP:  next_state = ENABLE;
        ENABLE: next_state = IDLE;
        default: next_state = IDLE;
    endcase
end


// ================= OUTPUT LOGIC =================
always @(posedge clk or posedge reset) begin
    if (reset) begin
        PSEL <= 0;
        PENABLE <= 0;
        PWRITE <= 0;
        PADDR <= 0;
        PWDATA <= 0;
        HRDATA <= 0;
    end 
    else begin
        case(state)

        IDLE: begin
            PSEL <= 0;
            PENABLE <= 0;
        end

        SETUP: begin
            PSEL <= 1;
            PENABLE <= 0;
            PADDR <= HADDR_reg;
            PWRITE <= HWRITE_reg;
            
        end

        ENABLE: begin
            PENABLE <= 1;
            PWDATA <= HWDATA_reg;
            // READ
            if (!PWRITE)
                HRDATA <= PRDATA;
        end

        endcase
    end
end

endmodule

module uart_tx(
    input clk, reset,
    input [7:0] data,
    input start,
    output reg tx,
    output reg busy
);

reg [3:0] bit_index;
reg [9:0] shift_reg;

always @(posedge clk or posedge reset) begin
    if(reset) begin
        tx <= 1;
        busy <= 0;
        bit_index <= 0;
    end
    else begin
        if(start && !busy) begin
            shift_reg <= {1'b1, data, 1'b0}; // stop + data + start
            busy <= 1;
            bit_index <= 0;
        end
        else if(busy) begin
            tx <= shift_reg[0];
            shift_reg <= shift_reg >> 1;
            bit_index <= bit_index + 1;

            if(bit_index == 9) begin
                busy <= 0;
                tx <= 1;
            end
        end
    end
end

endmodule
module top(
    input clk, reset,

    // AHB
    input [31:0] HADDR,
    input [31:0] HWDATA,
    input HWRITE,
    input HSEL,
    input HREADY,

    output [31:0] HRDATA,
    output tx
);

wire [31:0] PADDR, PWDATA;
wire PWRITE, PSEL, PENABLE;
wire [31:0] PRDATA;

// Bridge
ahb_apb_bridge bridge(
    .clk(clk), .reset(reset),
    .HADDR(HADDR),
    .HWDATA(HWDATA),
    .HWRITE(HWRITE),
    .HSEL(HSEL),
    .HREADY(HREADY),
    .HRDATA(HRDATA),

    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .PWRITE(PWRITE),
    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PRDATA(PRDATA)
);

// UART control
wire uart_start;
wire busy;

assign uart_start = PSEL & PENABLE & PWRITE;

// UART
uart_tx uart(
    .clk(clk),
    .reset(reset),
    .data(PWDATA[7:0]),
    .start(uart_start),
    .tx(tx),
    .busy(busy)
);

// Dummy read data
assign PRDATA = {24'd0, PWDATA[7:0]};

endmodule
