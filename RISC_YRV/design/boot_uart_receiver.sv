module boot_uart_receiver
# (
    parameter clk_frequency = 50 * 1000 * 1000,
              baud_rate     = 115200
)
(
    input              clk,
    input              reset,
    input              rx,
    output             byte_valid,
    output logic [7:0] byte_data
);

    localparam clk_cycles_in_symbol = clk_frequency / baud_rate;

    // Synchronize rx input to clk

    logic rx_sync1, rx_sync;

    always_ff @ (posedge clk or posedge reset)
    begin
        if (reset)
        begin
            rx_sync1 <= 1;
            rx_sync  <= 1;
        end
        else
        begin
            rx_sync1 <= rx;
            rx_sync  <= rx_sync1;
        end
    end

    // Finding edge for start bit

    logic prev_rx_sync;

    always_ff @ (posedge clk or posedge reset)
    begin
        if (reset)
            prev_rx_sync <= 1;
        else
            prev_rx_sync <= rx_sync;
    end

    wire start_bit_edge = prev_rx_sync & ~ rx_sync;

    // Counter to measure distance between symbols

    logic [$clog2 (clk_cycles_in_symbol * 3 / 2) - 1:0] counter;
    logic [$clog2 (clk_cycles_in_symbol * 3 / 2) - 1:0] load_counter_value;
    logic load_counter;

    always_ff @ (posedge clk or posedge reset)
    begin
        if (reset)
            counter <= 1'b0;
        else if (load_counter)
            counter <= load_counter_value;
        else if (counter != 0)
            counter <= counter - 1'b1;
    end

    wire counter_done = counter == 1'b1;

    // Shift register to accumulate data

    logic       shift;
    logic [7:0] shifted_1;

    assign byte_valid = shifted_1 [0];

    always @ (posedge clk or posedge reset)
    begin
        if (reset)
        begin
            shifted_1 <= 1'b0;
        end
        else if (shift)
        begin
            if (shifted_1 == 1'b0)
                shifted_1 <= 8'b10000000;
            else
                shifted_1 <= shifted_1 >> 1;
        end
        else if (byte_valid)
        begin
            shifted_1 <= 1'b0;
        end
    end

    always @ (posedge clk)
        if (shift)
            byte_data <= { rx, byte_data [7:1] };

    logic idle, idle_r;

    always @*
    begin
        idle  = idle_r;
        shift = 1'b0;

        load_counter        = 1'b0;
        load_counter_value  = 1'b0;

        if (idle)
        begin
            if (start_bit_edge)
            begin
                load_counter       = 1'b1;
                load_counter_value = clk_cycles_in_symbol * 3 / 2;
           
                idle = 1'b0;
            end
        end
        else if (counter_done)
        begin
            shift = 1'b1;

            load_counter       = 1'b1;
            load_counter_value = clk_cycles_in_symbol;
        end
        else if (byte_valid)
        begin
            idle = 1'b1;
        end
    end

    always @ (posedge clk or posedge reset)
    begin
        if (reset)
            idle_r <= 1;
        else
            idle_r <= idle;
    end

endmodule