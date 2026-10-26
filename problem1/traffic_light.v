// Traffic light controller: RED(00) -> GREEN(01) -> YELLOW(10) -> RED
// Next-state and output logic come from the K-map equations in derivation.md.
// No behavioral state-transition statements: only the derived equations
// feeding a plain 2-bit register.
module traffic_light (
    input  wire clk,
    input  wire reset,   // synchronous, active high, returns to RED
    output wire red,
    output wire green,
    output wire yellow
);
    // 2-bit state register {S1, S0}
    reg s1, s0;

    // Derived next-state equations (K-map, code 11 treated as don't care)
    wire d1 = s0;              // D1 = S0
    wire d0 = ~s1 & ~s0;       // D0 = S1' S0'

    // Plain register with synchronous reset to RED (00)
    always @(posedge clk) begin
        s1 <= reset ? 1'b0 : d1;
        s0 <= reset ? 1'b0 : d0;
    end

    // Derived Moore output equations (one minterm each)
    assign red    = ~s1 & ~s0;   // 00
    assign green  = ~s1 &  s0;   // 01
    assign yellow =  s1 & ~s0;   // 10
endmodule
