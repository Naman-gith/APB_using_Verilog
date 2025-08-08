
module apb_tb;

    // Parameters
    localparam ADDR_WIDTH = 4;
    localparam DATA_WIDTH = 32;

    // APB signals
    logic                  PCLK;
    logic                  PRESETn;
    logic                  PSEL;
    logic                  PENABLE;
    logic [ADDR_WIDTH-1:0] PADDR;
    logic                  PWRITE;
    logic [DATA_WIDTH-1:0] PWDATA;
    logic [DATA_WIDTH-1:0] PRDATA;
    logic                  PREADY;
    logic                  PSLVERR;

    apb_slave #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PADDR(PADDR),
        .PWRITE(PWRITE),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA),
        .PREADY(PREADY),
        .PSLVERR(PSLVERR)
    );

    initial PCLK = 0;
    always #5 PCLK = ~PCLK;

    // Task to perform APB write
    task apb_write(input [ADDR_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] data);
        begin
            @(posedge PCLK);
            PSEL    <= 1'b1;
            PENABLE <= 1'b0;
            PWRITE  <= 1'b1;
            PADDR   <= addr;
            PWDATA  <= data;

            @(posedge PCLK);
            PENABLE <= 1'b1; // ACCESS phase

            @(posedge PCLK);
            // Write complete
            PSEL    <= 1'b0;
            PENABLE <= 1'b0;
            PWRITE  <= 1'b0;
            PADDR   <= '0;
            PWDATA  <= '0;
        end
    endtask

    // Task to perform APB read
    task apb_read(input [ADDR_WIDTH-1:0] addr, output [DATA_WIDTH-1:0] data);
        begin
            @(posedge PCLK);
            PSEL    <= 1'b1;
            PENABLE <= 1'b0;
            PWRITE  <= 1'b0;
            PADDR   <= addr;

            @(posedge PCLK);
            PENABLE <= 1'b1; // ACCESS phase

            @(posedge PCLK);
            data = PRDATA;

            // Read complete
            PSEL    <= 1'b0;
            PENABLE <= 1'b0;
            PADDR   <= '0;
        end
    endtask
endmodule
