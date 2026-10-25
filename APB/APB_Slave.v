module APB_slave(
    input        PCLK,
    input        PRESETn,

    input [31:0] PADDR,
    input [31:0] PWDATA,
    input        PWRITE,
    input        PSEL,
    input        PENABLE,

    output [31:0] PRDATA,
    output        PREADY
);
 reg [31:0]mem[0:31];
 assign PREADY = PSEL && PENABLE;

always@(posedge PCLK) begin
    if(!PRESETn) begin 
        
    end
    else begin
        if (PSEL && PENABLE && PWRITE) begin //write operation
            mem[PADDR[4:0]] <= PWDATA;
        end
        
    end
end

assign PRDATA = (!PWRITE && PSEL && PENABLE) ? mem[PADDR[4:0]] : 32'b0;
endmodule
