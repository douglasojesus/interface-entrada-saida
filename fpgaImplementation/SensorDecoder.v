/**
* This module implements a decoder for handling communication with the DHT11 sensor.
*
* Regarding the `counter` use:
*   * When using a clock 50Mhz every clock cycle takes 20ns, that is 2 x 10⁻⁵ ms. Supposing we need
*     to wait for 18ms, it would take:
*       - 18 / 2 x 10⁻⁵ = 900,000 cycles
*   * To know how much time each `counter` is accounting for, just multiply the compared number by
*   the clock period (2 x 10⁻⁵). The result is the time in milliseconds.
*       - 900,000 * (2 x 10⁻⁵) = 18ms
*
* Source: https://www.youtube.com/watch?v=BkTYD7kujTk&list=PLZ8dBTV2_5HT0Gm24XcJcx43YMWRbDlxW&index=11&pp=iAQB
*
* NOTE: Minor modifications were made to the original code to suit the targeted problem and for
* better understanding of the working group.
*/

module SensorDecoder (
    input wire clock,
    input wire enable,
    input wire reset,
    inout wire transmission_line,
    output wire [7:0] hum_int,
    output wire [7:0] hum_float,
    output wire [7:0] temp_int,
    output wire [7:0] temp_float,
    output reg hold,  // Signalizes that the communication is on going.
    output reg error,  // Signalizes that a problem has occurred on some step/state.
	 output reg dadosPodemSerEnviados
);

  reg [39:0] sensor_data;
  reg [26:0] counter;
  reg [ 5:0] index;
  reg sensor_out, direction;

  wire sensor_in;
  wire [7:0] checksum;
  reg debug;

  TriState TS0 (
      .port(transmission_line),
      .dir (direction),
      .send(sensor_out),
      .read(sensor_in)
  );

  assign hum_int[0] = sensor_data[0];
  assign hum_int[1] = sensor_data[1];
  assign hum_int[2] = sensor_data[2];
  assign hum_int[3] = sensor_data[3];
  assign hum_int[4] = sensor_data[4];
  assign hum_int[5] = sensor_data[5];
  assign hum_int[6] = sensor_data[6];
  assign hum_int[7] = sensor_data[7];

  assign hum_float[0] = sensor_data[8];
  assign hum_float[1] = sensor_data[9];
  assign hum_float[2] = sensor_data[10];
  assign hum_float[3] = sensor_data[11];
  assign hum_float[4] = sensor_data[12];
  assign hum_float[5] = sensor_data[13];
  assign hum_float[6] = sensor_data[14];
  assign hum_float[7] = sensor_data[15];

  assign temp_int[0] = sensor_data[16];
  assign temp_int[1] = sensor_data[17];
  assign temp_int[2] = sensor_data[18];
  assign temp_int[3] = sensor_data[19];
  assign temp_int[4] = sensor_data[20];
  assign temp_int[5] = sensor_data[21];
  assign temp_int[6] = sensor_data[22];
  assign temp_int[7] = sensor_data[23];

  assign temp_float[0] = sensor_data[24];
  assign temp_float[1] = sensor_data[25];
  assign temp_float[2] = sensor_data[26];
  assign temp_float[3] = sensor_data[27];
  assign temp_float[4] = sensor_data[28];
  assign temp_float[5] = sensor_data[29];
  assign temp_float[6] = sensor_data[30];
  assign temp_float[7] = sensor_data[31];

  assign checksum[0] = sensor_data[32];
  assign checksum[1] = sensor_data[33];
  assign checksum[2] = sensor_data[34];
  assign checksum[3] = sensor_data[35];
  assign checksum[4] = sensor_data[36];
  assign checksum[5] = sensor_data[37];
  assign checksum[6] = sensor_data[38];
  assign checksum[7] = sensor_data[39];

  localparam [3:0] S0 = 4'b0001, S1 = 4'b0010, S2 = 4'b0011,
                   S3 = 4'b0100, S4 = 4'b0101, S5 = 4'b0110,
                   S6 = 4'b0111, S7 = 4'b1000, S8 = 4'b1001,
                   S9 = 4'b1010, START = 4'b1011, STOP = 4'b0000;

  reg [3:0] current_state = STOP;

  always @(posedge clock) begin : FSM
    if (enable == 1'b1) begin
      if (reset == 1'b1) begin
        hold <= 1'b0;
        error <= 1'b0;
        direction <= 1'b1;
        sensor_out <= 1'b1;
        counter <= 27'b000000000000000000000000000;
        sensor_data <= 40'b0000000000000000000000000000000000000000;
        current_state <= START;
      end else begin
        case (current_state)
          /**
          * Initialize the state machine by updating the following signals:
          *   - `sensor_out` to 1: Tells the DHT11 that the communication will start.
          *   - `hold` to 1: Signalizes that the communication is starting.
          *   - `direction` to 1: Allows the state machine to send signals to the sensor, see the
          *     `TriState` module for more details.
          *   - `current_state` to `S0`: Effectively starting the state machine.
          */
          START: begin
            hold <= 1'b1;
            direction <= 1'b1;
            sensor_out <= 1'b1;
				dadosPodemSerEnviados <= 1'b0;
            current_state <= S0;
          end

          /**
          * On this state the signals: `hold`, `direction` and `sensor_out` are kept on high, as
          * the communication is still on progress.
          * The `counter` register will be incremented until it reaches 900,000 accounting for
          * 18ms.
          */
          S0: begin
            hold <= 1'b1;
            error <= 1'b0;
            direction <= 1'b1;
            sensor_out <= 1'b1;

            if (counter < 900_000) begin
              counter <= counter + 1'b1;
            end else begin
              current_state <= S1;
              counter <= 27'b000000000000000000000000000;
            end
          end

          /**
          * On this state the signals: `hold` and `direction` are kept on high, as the communication
          * is still on progress. `sensor_out` is set to 0 to complete the signal of request to the
          * DHT11.
          * The `counter` register will be incremented until it reaches 900,000 accounting for
          * 18ms.
          */
          S1: begin
            hold <= 1'b1;
            sensor_out <= 1'b0;

            if (counter < 900_000) begin
              counter <= counter + 1'b1;
            end else begin
              current_state <= S2;
              counter <= 27'b000000000000000000000000000;
            end
          end


          /**
          * On this state we change `sensor_out` back to high level and wait for 20us (0.02ms),
          * time needed for the DHT11 to respond to the request. Once we reach that limit, that
          * `direction` signal is put on low, allowing the DHT11 to take over the `transmission_line`.
          */
          S2: begin
            sensor_out <= 1'b1;

            if (counter < 1_000) begin
              counter <= counter + 1'b1;
            end else begin
              current_state <= S3;
              direction <= 1'b0;
            end
          end

          /**
          * Here we wait for another 60us (0.06ms) waiting for the DHT11 to confirm the start of
          * the communication.
          * If the time is excedeed without any answer the `error` signal is set to high and the
          * state machine go to the `STOP`.
          */
          S3: begin
            if (sensor_in == 1'b1 && counter < 3_000) begin
              current_state <= S3;
              counter <= counter + 1'b1;
            end else begin
              if (sensor_in == 1'b1) begin
                current_state <= STOP;
                error <= 1'b1;
                counter <= 27'b000000000000000000000000000;
              end else begin
                current_state <= S4;
                counter <= 27'b000000000000000000000000000;
              end
            end
          end

          /**
          * After the DHT11 confirm the start of the communication, we need to check for the
          * synchronization signals. The DHT11 will send a low level signal for 88us (0.088ms) -
          * verified on `S4` - followed by a high level signal for the same period - verified on
          * `S5`.
          */
          S4: begin
            if (sensor_in == 1'b0 && counter < 4_400) begin
              current_state <= S4;
              counter <= counter + 1'b1;
            end else begin
              if (sensor_in == 1'b0) begin
                current_state <= STOP;
                error <= 1'b1;
                counter <= 27'b000000000000000000000000000;
              end else begin
                current_state <= S5;
                counter <= 27'b000000000000000000000000000;
              end
            end
          end

          /**
          * If the synchronization signals are both detected and valid, that `index` and `counter`
          * registers will be reseted to allow the reception of the data from the sensor on the
          * next states.
          */
          S5: begin
            if (sensor_in == 1'b1 && counter < 4_400) begin
              current_state <= S5;
              counter <= counter + 1'b1;
            end else begin
              if (sensor_in == 1'b1) begin
                current_state <= STOP;
                error <= 1'b1;
                counter <= 27'b000000000000000000000000000;
              end else begin
                current_state <= S6;
                error <= 1'b1;
                index <= 6'b000000;
                counter <= 27'b000000000000000000000000000;
              end
            end
          end

          /**
          * On this step, if the signal coming from the sensor isn't low, we have a problem on the
          * communication, so the state machine is sent to the `STOP` state.
          */
          S6: begin
            if (sensor_in == 1'b0) begin
              current_state <= S7;
            end else begin
              current_state <= STOP;
              error <= 1'b1;
              counter <= 27'b000000000000000000000000000;
            end
          end

          /**
          * Here we check if the signal coming from the DHT11 is on a high level. If not, we wait
          * for 32ms as the sensor might have hanged for some reason. When the time limit is
          * reached the state machine is sent to the `STOP` state.
          */
          S7: begin
            if (sensor_in == 1'b1) begin
              current_state <= S8;
              counter <= 27'b000000000000000000000000000;
            end else begin
              if (counter < 1_600_000) begin
                current_state <= S7;
                counter <= counter + 1'b1;
              end else begin
                current_state <= STOP;
                error <= 1'b1;
                counter <= 27'b000000000000000000000000000;
              end
            end
          end

          /**
          * On this state we start receiving the data bits. The DHT11 will sent a low signal for
          * 50us (0.05ms) followed by a high signal of variable length:
          *   - A length of 26us to 28us (~0.02ms to 0.03ms) indicates a bit 0.
          *   - A length of 70us (0.07ms) indicates a bit 1.
          *
          * The machine will be kept on this state until all the 40 bits are received.
          */
          S8: begin
            if (sensor_in == 1'b0) begin
              if (counter > 2_500) begin
                debug <= 1'b1;
                sensor_data[index] <= 1'b1;
              end else begin
                debug <= 1'b0;
                sensor_data[index] <= 1'b0;
              end

              if (index < 39) begin
                current_state <= S9;
                counter <= 27'b000000000000000000000000000;
              end else begin
                current_state <= STOP;
                error <= 1'b0;
              end
            end else begin
              counter <= counter + 1'b1;

              if (counter == 1_600_000) begin
                current_state <= STOP;
                error <= 1'b1;
              end
            end
          end

          /**
          * This state is used to guarantee that the `index` is incremented and stabilized before
          * we begin receiving another bit.
          */
          S9: begin
            current_state <= S6;
            index <= index + 1'b1;
          end

          /**
          * Once we reach `STOP`, we check if again if there where no problems with the
          * communication and perform the resets of the internal/external registers. If `error`
          * is a high logical level, we wait for another 32ms for a proper reset of the state
          * machine.
          */
          STOP: begin
            current_state <= STOP;

            if (error == 1'b0) begin
              hold <= 1'b0;
              error <= 1'b0;
				  dadosPodemSerEnviados <= 1'b1;
              direction <= 1'b1;
              sensor_out <= 1'b1;
              index <= 6'b000000;
              counter <= 27'b000000000000000000000000000;
            end else begin
              if (counter < 1_600_000) begin
                hold <= 1'b1;
                error <= 1'b1;
					 dadosPodemSerEnviados <= 1'b0; 
                direction <= 1'b0;
                counter <= counter + 1'b1;
                sensor_data <= 40'b0000000000000000000000000000000000000000;
              end else begin
                error <= 1'b0;
              end
            end
          end

          default: begin
          end
        endcase
      end
    end
  end

endmodule