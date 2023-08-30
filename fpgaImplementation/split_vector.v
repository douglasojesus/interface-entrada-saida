module split_vector (
    input [15:0] vetor,
    output [7:0] vetor_parte1,
    output [7:0] vetor_parte2
);

    assign vetor_parte1 = vetor[15:8];
    assign vetor_parte2 = vetor[7:0];

endmodule