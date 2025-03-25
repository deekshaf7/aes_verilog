// key_expansion.v
module key_expansion (
    input         clk,
    input         rst,
    input  [127:0] key,         // 128-bit key
    output reg [1407:0] w       // 44 words x 32 bits = 1408 bits
);

    integer i;
    reg [31:0] temp;
    reg [31:0] w_mem [0:43]; // 44 words of 32 bits

    wire [31:0] rcon [0:9];
    assign rcon[0] = 32'h01000000;
    assign rcon[1] = 32'h02000000;
    assign rcon[2] = 32'h04000000;
    assign rcon[3] = 32'h08000000;
    assign rcon[4] = 32'h10000000;
    assign rcon[5] = 32'h20000000;
    assign rcon[6] = 32'h40000000;
    assign rcon[7] = 32'h80000000;
    assign rcon[8] = 32'h1b000000;
    assign rcon[9] = 32'h36000000;

    wire [31:0] subword_out;
    reg  [31:0] subword_in;
    reg         subword_req;
    wire        subword_ack;

    // Instantiate SubWord (uses SBox)
    subword u_subword (
        .clk(clk),
        .in_word(subword_in),
        .out_word(subword_out),
        .req(subword_req),
        .ack(subword_ack)
    );

    // FSM for sequential expansion
    reg [6:0] count;
    reg [3:0] state;
    parameter S_IDLE = 0,
              S_INIT = 1,
              S_SUB  = 2,
              S_XOR  = 3,
              S_DONE = 4;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= S_IDLE;
            count <= 0;
            for (i = 0; i < 44; i = i + 1)
                w_mem[i] <= 32'b0;
        end else begin
            case (state)
                S_IDLE: begin
                    count <= 0;
                    w_mem[0] <= key[127:96];
                    w_mem[1] <= key[95:64];
                    w_mem[2] <= key[63:32];
                    w_mem[3] <= key[31:0];
                    count <= 4;
                    state <= S_INIT;
                end
                S_INIT: begin
                    if (count < 44) begin
                        temp <= w_mem[count - 1];
                        if (count % 4 == 0) begin
                            subword_in <= {temp[23:0], temp[31:24]}; // ROTWORD
                            subword_req <= 1;
                            state <= S_SUB;
                        end else begin
                            w_mem[count] <= w_mem[count - 4] ^ temp;
                            count <= count + 1;
                        end
                    end else begin
                        state <= S_DONE;
                    end
                end
                S_SUB: begin
                    if (subword_ack) begin
                        subword_req <= 0;
                        temp <= subword_out ^ rcon[(count / 4) - 1];
                        state <= S_XOR;
                    end
                end
                S_XOR: begin
                    w_mem[count] <= w_mem[count - 4] ^ temp;
                    count <= count + 1;
                    state <= S_INIT;
                end
                S_DONE: begin
                    for (i = 0; i < 44; i = i + 1)
                        w[i*32 +: 32] <= w_mem[i];
                    state <= S_DONE; // stay here, key schedule is ready
                end
            endcase
        end
    end

endmodule

