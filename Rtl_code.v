
module apb_slave #(
    parameter ADDR_WIDTH = 4,   // address width
    parameter DATA_WIDTH = 32   // data bus width
)(
    input  logic                  PCLK,      // APB clock
    input  logic                  PRESETn,   // Active-low reset

    // APB interface
    input  logic                  PSEL,      // Slave select
    input  logic                  PENABLE,   // Enable phase
    input  logic [ADDR_WIDTH-1:0] PADDR,     // Address bus
    input  logic                  PWRITE,    // Write = 1, Read = 0
    input  logic [DATA_WIDTH-1:0] PWDATA,    // Write data
    output logic [DATA_WIDTH-1:0] PRDATA,    // Read data
    output logic                  PREADY,    // Ready signal
    output logic                  PSLVERR    // Error signal
);

   
    logic [DATA_WIDTH-1:0] reg0;

    // Always ready (single-cycle access)
    assign PREADY  = 1'b1;
    assign PSLVERR = 1'b0; // no error handling in this simple example

    // Write logic
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn)
            reg0 <= '0;
        else if (PSEL && PENABLE && PWRITE) begin
            case (PADDR)
                4'h0: reg0 <= PWDATA; // write to reg0
                default: ;           // ignore invalid address
            endcase
        end
    end

    // Read logic
    always_comb begin
        PRDATA = '0;
        if (PSEL && !PWRITE) begin
            case (PADDR)
                4'h0: PRDATA = reg0; // read reg0
                default: PRDATA = '0;
            endcase
        end
    end

endmodule
