<h1 align="center">
📄<br>Projeto de Sensor Digital em FPGA utilizando Comunicação Serial.
</h1>
<h4 align="center">
Projeto produzido a ser avaliado pela disciplina de M.I Sistemas Digitais da Universidade Estadual de Feira de Santana. 
</h4>
<h2 align="center">
Implementação de um protótipo de sensor para medição de temperatura e umidade.
</h2>

Contribuidores: Douglas Oliveira de Jesus, Emanuel Antonio Lima Pereira, Émerson Rodrigo Lima Pereira e Gabriel Souza Sampaio.

- 📝 O código de comunicação com o usuário deve ser escrito em linguagem C;
- 📝 A implementação da lógica deve ser feita utilizando Verilog programado na FPGA (Kit de desenvolvimento Mercurio IV - Cyclone IV);
- 📝 A comunicação feita entre o computador e a placa FPGA deve ser feita através do UART;
- 📝 Deve haver a capacidade de interligação (endereçamento) com até 32 sensores (utilizando modularidade);
- 📝 O sensor a ser utilizado deve ser o DHT11;
- 📝 Deve haver mecanismo de controle de status de funcionamento dos sensores;
- 📝 Os comandos devem ser compostos por palavras de 8 bits;
- 📝 As requisições e respostas devem ser compostas de 2 bytes (Comando + Endereço do sensor).

Ferramentas:
- 🔧 Quartus Prime 22.1
- 🔧 Kit de desenvolvimento Mercúrio IV
- 🔧 Visual Studio Code






Para clonar este repositório:
1. $ git clone https://github.com/douglasojesus/interface-entrada-saida;

2. Abra com o Quartus \interface-entrada-saida\fpgaImplementation\FPGAImplementation.qpf e compile o código;

3. Programe o código na placa FPGA Cyclone IV E EP4CE30F23C7;

4. Conecte a porta serial do cmoputador com a porta serial da FPGA;

5. Compile o código \interface-entrada-saida\uartSerialCommunication.c e o execute;

6. Interaja com o terminal e aproveite o sistema!
