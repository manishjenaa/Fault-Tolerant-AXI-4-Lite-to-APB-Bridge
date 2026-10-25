module APB_master(
    input PCLK,
    input PRESETn,

    // Transaction request from AXI side
    input        transfer_req,
    input [31:0] addr_in,
    input [31:0] data_in,
    input        write_in,

    // From APB slave
    input [31:0] PRDATA,
    input        PREADY,

    // To APB slave
    output [31:0] PWDATA,
    output [31:0] PADDR,
    output        PWRITE,
    output        PSEL,
    output        PENABLE,

    // Read result
    output reg [31:0] result
);

parameter IDLE   = 2'b00;
parameter SETUP  = 2'b01;
parameter ACCESS = 2'b10;

reg [1:0] current_state;
reg [1:0] next_state;

reg [31:0] addr_reg;
reg [31:0] data_reg;
reg        write_reg;


// Sequential logic
always @(posedge PCLK) begin

    if (!PRESETn) begin
        current_state <= IDLE;
        addr_reg      <= 32'b0;
        data_reg      <= 32'b0;
        write_reg     <= 1'b0;
        result        <= 32'b0;
    end

    else begin
        current_state <= next_state;

        
        if ((current_state == IDLE) && transfer_req) begin
            addr_reg  <= addr_in;
            data_reg  <= data_in;
            write_reg <= write_in;
        end

        // Capture read data
        if ((current_state == ACCESS) &&
            PREADY &&
            !write_reg) begin
            result <= PRDATA;
        end
    end

end



always @(*) begin

    case (current_state)

        IDLE: begin
            if (transfer_req)
                next_state = SETUP;
            else
                next_state = IDLE;
        end

        SETUP: begin
            next_state = ACCESS;
        end

        ACCESS: begin
            if (PREADY)
                next_state = IDLE;
            else
                next_state = ACCESS;
        end

        default: begin
            next_state = IDLE;
        end

    endcase

end


// APB outputs
assign PADDR   = addr_reg;
assign PWDATA  = data_reg;
assign PWRITE  = write_reg;

assign PSEL    = (current_state == SETUP) ||
                 (current_state == ACCESS);

assign PENABLE = (current_state == ACCESS);

endmodule