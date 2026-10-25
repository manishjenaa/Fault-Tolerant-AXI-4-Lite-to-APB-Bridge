`timescale 1ns/1ps
module tb;
    reg PCLK;
    reg PRESETn;

    reg        transfer_req;
    reg [31:0] addr_in;
    reg [31:0] data_in;
    reg        write_in;

    wire [31:0] PRDATA;
    wire        PREADY;

    wire [31:0] PADDR;
    wire [31:0] PWDATA;
    wire        PWRITE;
    wire        PSEL;
    wire        PENABLE;

    wire [31:0] result;

    APB_master master(
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .transfer_req(transfer_req),
        .addr_in     (addr_in),
        .data_in     (data_in),
        .write_in    (write_in),

        .PRDATA      (PRDATA),
        .PREADY      (PREADY),

        .PWDATA      (PWDATA),
        .PADDR       (PADDR),
        .PWRITE      (PWRITE),
        .PSEL        (PSEL),
        .PENABLE     (PENABLE),

        .result      (result)
    );

    APB_slave slave(
        .PCLK    (PCLK),
        .PRESETn (PRESETn),

        .PADDR   (PADDR),
        .PWDATA  (PWDATA),
        .PWRITE  (PWRITE),
        .PSEL    (PSEL),
        .PENABLE (PENABLE),

        .PRDATA  (PRDATA),
        .PREADY  (PREADY)
    );
    initial begin
        PCLK = 0;
        forever #5 PCLK = ~PCLK;
    end


    initial begin
        $dumpfile("APB.vcd");
        $dumpvars(0,tb);
        PRESETn = 0;
        transfer_req = 0;
        addr_in = 0;
        data_in = 0;
        write_in = 0;

        #20
        PRESETn = 1;

        //WRITE OPERATION
        
        addr_in <= 32'd5;
        data_in <= 32'h100;
        write_in <= 1;
        @(posedge PCLK);
        transfer_req <= 1;

        @(posedge PCLK);
        transfer_req <= 0;
        wait(PREADY);
        #10
        $display("WRITE");
        $display("Address : %h", addr_in);
        $display("Data : %h", data_in);

        
        //READ OPERATION
        addr_in <= 32'd5;
        data_in <= 32'd0;
        write_in <= 0;
        @(posedge PCLK);
        transfer_req <= 1;

        @(posedge PCLK);
        transfer_req <= 0;
        wait(PREADY);
        @(posedge PCLK);
        #1;
        $display("READ");
        $display("Address : %h", addr_in);
        $display("RESULT : %h", result);
    
    $finish;

    end
endmodule