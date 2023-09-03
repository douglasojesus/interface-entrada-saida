/**
* This module implements a tri-state buffer, which can assume one of three output states: high (1),
*  low (0), or high-impedance (Z), depending on the control signal `dir`.
*
* Usage:
*   - Connect `port` to the desired signal bus.
*   - Set `dir` to 1 to enable data flow from `send` to `port`.
*   - Set `dir` to 0 to place `port` in a high-impedance state (Z) and read data from `port`
*     using `read`.
*
* Source: https://www.youtube.com/watch?v=BkTYD7kujTk&list=PLZ8dBTV2_5HT0Gm24XcJcx43YMWRbDlxW&index=11&pp=iAQB
*
* NOTE: Minor modifications were made to the original code to suit the targeted problem and for
* better understanding of the working group.
*/

module TriState (
    inout  wire port,
    input  wire dir,
    input  wire send,
    output wire read
);

  assign port = dir ? send : 1'bZ;
  assign read = dir ? 1'bZ : port;

endmodule