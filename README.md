<h1 align="center">
📄<br>Projeto de Sensor Digital em FPGA utilizando Comunicação Serial.
</h1>
<h4 align="center">
Projeto produzido a ser avaliado pela disciplina de M.I Sistemas Digitais da Universidade Estadual de Feira de Santana. 
</h4>
<h2 align="center">
Implementação de um protótipo de sensor para medição de temperatura e umidade.
</h2>


<h1 id="sumario" align="center">Sumário</h1>
<ul>
  <li><a href="#membros"><b>Membros;</b></li>
  <li><a href="#introducao"> <b>Introdução;</b></li>
	  <li><a href="#requisitos"> <b>Requisitos;</b> </a></li>
	      <li><a href="#recursos"> <b>Recursos Utilizados;</b></li>
		      <li><a href="#fundamentacao-teorica"> <b>Fundamentação Teórica</b> </a> </li>
	<li><a href="#desenvolvimento"> <b>Desenvolvimento;</b> </a> </li>
	<li><a href="#descricao-do-sistema"> <b>Descrição em alto nível do sistema proposto;</b> </a> </li>
  <li><a href="#descricao-do-protocolo-de-comunicacao"> <b>Descrição do protocolo de comunicação desenvolvido;</b> </a> </li>
	      <li><a href="#descricao-e-analise-dos-testes"> <b>Descrição e análise dos testes e simuações</b> </a></li>
		      <li><a href="#resultados"> <b>Resultados e Discussões</b> </a></li>
		      <li><a href="#conclusao"> <b>Conclusão</b> </a></li>
  <li><a href="#referencias"> <b>Referências</b> </a></li>
</ul>

<h1 id="membros" align="center">Equipe de Desenvolvimeno</h1>

  <ul>
		<li><a href="https://github.com/douglasojesus"> Douglas Oliveira de Jesus </li>
		<li><a href="https://github.com/Emanuel-Antonio"> Emanuel Antonio Lima Pereira </a></li>
      <li><a href="https://github.com/emersonrlp"> Emerson Rodrigo Lima Pereira </a></li>
      <li><a href="https://github.com/GabrielSousaSampaio"> Gabriel Sousa Sampaio </a></li>
	</ul>
  
<h1 id="introducao" align="center">Introdução</h1> 

 <p align="justify"> O crescente mercado de internet das coisas (IoT) tem levado ao desenvolvimento de projetos cada vez mais sofisticados e movimentando centenas de bilhões de dólares por ano. Através dela, possibilita-se promover a conexão de dispositivos, sensores e sistemas em uma rede interconectada, assim, revolucionando a maneira como interagimos com o mundo digital e físico. 
  Neste contexto, surge-se a proposta da criação de um sistema modular de entrada e saída voltado para o monitoramento de temperatura e umidade local, utilizando uma plataforma baseada em FPGAs para confecção dos sensores.
  Este relatório técnico, portanto, analisa um projeto de comunicação com sensores implementado em Verilog, com foco em sua funcionalidade e estrutura. O protótipo é projetado para operar em um ambiente de microcontrolador ou FPGA, interagindo com sensores diversos por meio de um barramento UART. É capaz de se comunicar com até 32 sensores, processar comandos, ler dados dos sensores, gerar respostas e suportar o sensoriamento contínuo. 
  
  Para atingir o objetivo, utilizou-se o kit de desenvolvimento Mercúrio IV como plataforma base, explorando os conceitos do protocolo de comunicação UART e fazendo uso do sensor DHT11. Além disso, esse projeto integra as linguagens de descrição de hardware (Verilog), desenvolvida através da ferramenta Quartus Prime 22.1, e programação de alto nível (C), ambas utilizando o sistema operacional Linux, unindo assim o melhor de ambos os mundos para oferecer uma solução eficiente e versátil. Este relatório descreve as principais características de todos os módulos, detalhando suas entradas e saídas, variáveis internas, controle de sensores, estados da máquina de estados finitos (MEF), geração de respostas, verificação de erros e o uso do clock. Além disso, é realizada uma análise crítica das funcionalidades do módulo e de sua aplicabilidade em sistemas embarcados. </p>

<h1 id="requisitos" align="center">Requisitos do problema</h1> 

- 📝 O código de comunicação com o usuário deve ser escrito em linguagem C;
- 📝 A implementação da lógica deve ser feita utilizando Verilog programado na FPGA (Kit de desenvolvimento Mercurio IV - Cyclone IV);
- 📝 A comunicação feita entre o computador e a placa FPGA deve ser feita através do UART;
- 📝 Deve haver a capacidade de interligação (endereçamento) com até 32 sensores (utilizando modularidade);
- 📝 O sensor a ser utilizado deve ser o DHT11;
- 📝 Deve haver mecanismo de controle de status de funcionamento dos sensores;
- 📝 Os comandos devem ser compostos por palavras de 8 bits;
- 📝 As requisições e respostas devem ser compostas de 2 bytes (Comando + Endereço do sensor).

<h1 id="recursos" align="center">Recursos utilizados</h1> 

- 🔧 Quartus Prime 22.1
- 🔧 Kit de desenvolvimento Mercúrio IV
- 🔧 Cabo serial
- 🔧 Sensor DHT11
- 🔧 Visual Studio Code
- 🔧 GNU Compiler Collection
- 🔧 Git e Github

<h1 id="fundamentacao-teorica" align="center">Fundamentação Teórica</h1>

<p align="justify">Durante a criação e elaboração do projeto foram utilizados os conceitos e materiais apresentados a seguir. Portanto, torna-se indispensável a sua compreensão para o entendimento da criação e funcionamento do protótipo solicitado.</p>

<h2>Comunicação Serial</h2>

<p align="justify">Comunicação serial é um modo de transmissão de dados onde os bits são enviados, um por vez, em sequência e, portanto, necessita-se de apenas um canal transmissor (podendo ser um pino ou um fio) ao invés de n canais de transmissão que seria o caso da transmissão em paralelo.

Para que alguns dispositivos funcionem e passem a receber e enviar os dados, é preciso, na maioria dos casos, de portas seriais. Elas são consideradas conexões externas que estão presentes nos equipamentos e servem para que alguns aparelhos básicos sejam conectados. Embora a maioria dos equipamentos da atualidade tenham substituído essas portas pelo USB, elas ainda são utilizadas em modems, impressoras, PDAs e até câmeras digitais.</p>

<h2>Protocolo de comunicação UART</h2>

<p align="justify">
UART (Universal Asynchronous Receiver-Transmitter) é um protocolo de comunicação assíncrono amplamente utilizado em dispositivos eletrônicos para transferência de dados, capaz de trabalhar com vários tipos de protocolos seriais para transmissão e recepção de dados. 
Um dos principais objetivos deste protocolo é fornecer uma maneira simples e eficiente de transmitir informações serialmente (bit a bit) entre um módulo transmissor (TX) e um receptor (RX) sem depender de um clock que coordenaria as ações entre os dispositivos. Em vez disso, a comunicação é baseada em uma combinação de bits de dados e de controle, incluindo bits de início e parada, que marcam o início e o fim de cada byte de dados.
</p>

<p align="center">
  <img src="anexos/uart_tx__ uart_rx.png" align="center" alt=Representação da comunicação via UART>
</p>

<p align="justify">Principais características da UART:

Comunicação Bidirecional: A UART permite a comunicação bidirecional, o que significa que os dispositivos podem tanto transmitir quanto receber dados. Isso é especialmente útil em sistemas onde informações precisam ser enviadas e recebidas.

Assincronia: Como mencionado, a comunicação UART é assíncrona, o que significa que os dispositivos não compartilham um relógio de sincronização central. Em vez disso, os dispositivos concordam com uma taxa de baud para determinar quando cada bit de dados deve ser transmitido ou recebido.

Start e Stop Bits: Para sincronizar a transmissão e recepção de dados, a UART utiliza bits de início (start bits) e bits de parada (stop bits) antes e depois de cada byte de dados. Isso ajuda os dispositivos a identificar o início e o fim de cada byte.

Configuração Flexível: A UART permite configurações flexíveis, incluindo a escolha do número de bits de dados por byte, o número de bits de parada e a taxa de baud. Essa flexibilidade torna a UART adequada para uma variedade de aplicações.

Em resumo, a UART é um componente fundamental para a comunicação de dados em sistemas eletrônicos e é particularmente valiosa em situações em que a comunicação assíncrona é necessária ou desejada. Ela desempenha um papel importante em muitas tecnologias e dispositivos que dependem da troca de informações digitais.
</p>

<h2>Kit de desenvolvimento Mercury IV</h2>

<p align="justify">O FPGA utilizado como plataforma para portar o protótipo disposto e que equipa a placa Mercurio® IV é uma Cyclone® IV EP4CE30F23, a qual possui 30 mil elementos lógicos (LEs), um clock de entrada de 50MHz e diversas interfaces/funcionalidades que auxiliam no desenvolvimento de circuitos lógicos.</p>

<h2>Sensor DHT11</h2>

<p align="justify">O sensor DHT11 é um dispositivo digital utilizado para efetuar medições de temperatura e umidade no ambiente. Suas características técnicas incluem:

Faixa de medição de temperatura: 0°C a 50°C, com precisão de ±2°C.

Faixa de medição de umidade do ar: 20% a 90%, com precisão de 5%.

Taxa de atualização das leituras: uma leitura a cada 2 segundos.

Tensão de operação: De 3,5 VDC a 5,5 VDC.

Corrente de operação: 0,3 mA.

Instruções de Uso:

O sensor DHT11 possui quatro pinos, que devem ser conectados da seguinte maneira:

Pino 1 (VCC): Conectar à fonte de alimentação.
Pino 2 (DATA ou SINAL): Utilizado para a transferência de dados lidos.
Pino 3 (NC): Não utilizado no projeto.
Pino 4 (GND): Conectar ao GND (terra).</p>

<p align="center">
  <img src="anexos/dth11.png" alt=Identificação dos pinos do DHT11 width="300" height="300">
</p>

<p align="justify">Os dados lidos pelo sensor são enviados em formato binário, seguindo esta sequência de bytes:

Primeiro byte (sequência de 8 bits): Dados de alta umidade (parte inteira).

Segundo byte (sequência de 8 bits): Dados de baixa umidade (casas decimais).

Terceiro byte (sequência de 8 bits): Dados de alta temperatura (parte inteira).

Quarto byte (sequência de 8 bits): Dados de baixa temperatura (casas decimais).

Quinto byte (sequência de 8 bits): Bit de paridade (funciona como um "checksum" para verificar a soma de todos os outros dados lidos).

Exemplo de leitura final:

0011 0101 | 0000 0000 | 0001 1000 | 0000 0000 | 0100 1101

Umidade alta | Umidade baixa | Temperatura alta | Temperatura baixa | Bit de paridade

Calculando a soma dos valores e verificando se está de acordo com o bit de paridade:

0011 0101 + 0000 0000 + 0001 1000 + 0000 0000 = 0100 1101

Caso os dados recebidos estejam corretos:

Umidade: 0011 0101 = 35H = 53% de umidade relativa.

Temperatura: 0001 1000 = 18H = 24°C.

Portanto, ao receber os dados é necessário, primeiramente, separar as sequências de bytes, segundamente, verificar, através da sequência do “parity bit”, se não houve nenhum erro durante a leitura e, por fim, faz-se uma decodificação para obter o real valor da umidade e temperatura, respectivamente.

</p>

<h1 id="desenvolvimento" align="center">Desenvolvimento</h1>

<p align="justify">Inicialmente foi proposto durante as sessões a criação de um diagrama inicial geral de como funcionaria o circuito. Dessa forma, foi possível identificar os três principais agentes do sistema. Sendo eles: o computador, a FPGA e o anexo do sensor DHT11.</p>

<img src="anexos/diagrama_projeto.png" alt=Diagrama em blocos do sistema>

<h1 id="descricao-do-sistema" align="center">Descrição do sistema</h1>

<p align="center">
  <img src="anexos/MEF/dependencyTree.drawio.png" alt=Diagrama de dependências para sicronização>
</p>

<h1 id="script-de-compilacao" align="center">Como executar</h1> 

<h1 id="descricao-e-analise-dos-testes" align="center">Descrição e Análise dos Testes</h1>

[Vídeo - Apresentação de metodologia, testes e discussão de melhorias do protótipo de interface de E/S](https://www.youtube.com/watch?v=cKk95P4JJlk,  "Vídeo do Youtube")

Para clonar este repositório:

1. ```$ git clone https://github.com/douglasojesus/interface-entrada-saida;```

2. Abra com o Quartus \interface-entrada-saida\fpgaImplementation\FPGAImplementation.qpf e compile o código;

3. Programe o código na placa FPGA Cyclone IV E EP4CE30F23C7;

4. Conecte a porta serial do computador com a porta serial da FPGA;

5. Compile o código \interface-entrada-saida\uartSerialCommunication.c e o execute;

6. Interaja com o terminal e aproveite o sistema!
