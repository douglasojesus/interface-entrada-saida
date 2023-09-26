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
  <li><a href="#membros"><b>Equipe de Desenvolvimento;</b></li>
  <li><a href="#introducao"> <b>Introdução;</b></li>
  <li><a href="#requisitos"> <b>Requisitos;</b> </a></li>
  <li><a href="#recursos"> <b>Recursos Utilizados;</b></li>
	      <li><a href="#fundamentacao-teorica"> <b>Fundamentação Teórica</b> </a> </li>
<li><a href="#desenvolvimento"> <b>Desenvolvimento;</b> </a> </li>
<li><a href="#descricao-do-sistema"> <b>Descrição em alto nível do sistema proposto;</b> </a> </li>
      <li><a href="#descricao-e-analise-dos-testes"> <b>Descrição e análise dos testes e simuações</b> </a></li>
	      <li><a href="#resultados"> <b>Resultados e Discussões</b> </a></li>
	      <li><a href="#conclusao"> <b>Conclusão</b> </a></li>
  <li><a href="#referencias"> <b>Referências</b> </a></li>
</ul>

<h1 id="membros" align="center">Equipe de Desenvolvimento</h1>

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

<h2>Kit de Desenvolvimento Mercury IV</h2>

<p align="justify">O FPGA utilizado como plataforma para portar o protótipo disposto e que equipa a placa Mercurio® IV é uma Cyclone® IV E EP4CE30F23C7, a qual possui quase 30 mil elementos lógicos (LEs), um clock de entrada de 50MHz e diversas interfaces/funcionalidades que auxiliam no desenvolvimento de circuitos lógicos.</p>

<h2>Sensor DHT11</h2>

<p align="justify">O sensor DHT11 é um dispositivo digital utilizado para efetuar medições de temperatura e umidade no ambiente. Das suas principais características técnicas, ele permite um faixa de medição de 0°C até 50°C para temperatura e 20% até 90% para umidade; faz faz leitura a cada 2 segundos; tem uma tensão de operação de 3,5 VDC (suportando até 5,5 VDC) e uma corrente de 0,3 mA. 

Instruções de Uso:

O sensor DHT11 possui quatro pinos, que devem ser conectados da seguinte maneira:

Pino 1 (VCC): Conectar à fonte de alimentação.
Pino 2 (DATA ou SINAL): Utilizado para a transferência de dados lidos.
Pino 3 (NC): Não utilizado no projeto.
Pino 4 (GND): Conectar ao GND (terra).</p>

<p align="center">
  <img src="anexos/dth11.png" alt=Identificação dos pinos do DHT11 width="300" height="300">
</p>

<p align="justify">Os dados lidos pelo sensor são enviados em formato binário, seguindo a sequência: dados da parte inteira de umidade, dados da parte decimal da umidade, dados da parte inteira da temperatura, dados da parte decimal da temperatura e byte de paridade que funciona como um checksum para verificar a soma dos outros dados lidos. Todos os dados obtém um tamanho de 8 bits (1 byte). Portanto, o DHT11 retorna 40 bits de dados bruto.

Exemplo de leitura final:

0011 0101	 |	 0000 0000 |	0001 1000 	| 	0000 0000 | 	0100 1101

Umidade inteira	 | Umidade decimal |	Temperatura inteira | 	Temperatura decimal | 	Bit de paridade

Calculando a soma dos valores e verificando se está de acordo com o bit de paridade:

0011 0101 + 0000 0000 + 0001 1000 + 0000 0000 = 0100 1101

Caso os dados recebidos estejam corretos:

Umidade: 0011 0101 = 35H = 53% de umidade relativa.

Temperatura: 0001 1000 = 18H = 24°C.

Portanto, ao receber os dados é necessário, primeiramente, separar as sequências de bytes e depois verificar, através da sequência do “parity bit”, se não há nenhum erro durante a leitura e, por fim, faz-se uma decodificação para obter o real valor da umidade e temperatura, respectivamente.

</p>

<h1 id="fundamentacao-teorica" align="center">Fundamentação Teórica</h1>

<p align="justify">Durante a criação e elaboração do projeto foram utilizados os conceitos e materiais apresentados a seguir. Portanto, torna-se indispensável a sua compreensão para o entendimento da criação e funcionamento do protótipo solicitado.</p>

<h2>Comunicação Serial</h2>

<p align="justify">Comunicação serial é um modo de transmissão de dados onde os bits são enviados, um por vez, em sequência e, portanto, necessita-se de apenas um canal transmissor (podendo ser um pino ou um fio) ao invés de "n" canais de transmissão que seria o caso da transmissão em paralelo.

Para que alguns dispositivos funcionem e passem a receber e enviar os dados, é preciso, na maioria dos casos, de portas seriais. Elas são consideradas conexões externas que estão presentes nos equipamentos e servem para que alguns aparelhos básicos sejam conectados. Embora a maioria dos equipamentos da atualidade tenham substituído essas portas pelo USB, elas ainda são utilizadas em modems, impressoras, PDAs e até câmeras digitais.</p>

<h2>Protocolo de Comunicação UART</h2>

<p align="justify">
UART (Universal Asynchronous Receiver-Transmitter) é um protocolo de comunicação assíncrono amplamente utilizado em dispositivos eletrônicos para transferência de dados, capaz de trabalhar com vários tipos de protocolos seriais para transmissão e recepção de dados. 
Um dos principais objetivos deste protocolo é fornecer uma maneira simples e eficiente de transmitir informações serialmente (bit a bit) entre um módulo transmissor (TX) e um receptor (RX) sem depender de um clock que coordenaria as ações entre os dispositivos. Em vez disso, a comunicação é baseada em uma combinação de bits de dados e de controle, incluindo bits de início e parada, que marcam o início e o fim de cada byte de dados.
</p>

<p align="center">
  <img src="anexos/uart_tx__ uart_rx.png" align="center" alt=Representação da comunicação via UART>
</p>

<p align="justify">Principais características da UART:

- Comunicação Bidirecional: A UART permite a comunicação bidirecional, o que significa que os dispositivos podem tanto transmitir quanto receber dados. Isso é especialmente útil em sistemas onde informações precisam ser enviadas e recebidas.

- Assincronia: Como mencionado, a comunicação UART é assíncrona, o que significa que os dispositivos não compartilham um relógio de sincronização central. Em vez disso, os dispositivos concordam com uma taxa de baud para determinar quando cada bit de dados deve ser transmitido ou recebido.

- Start e Stop Bits: Para sincronizar a transmissão e recepção de dados, a UART utiliza bits de início (start bits) e bits de parada (stop bits) antes e depois de cada byte de dados. Isso ajuda os dispositivos a identificar o início e o fim de cada byte.

- Configuração Flexível: A UART permite configurações flexíveis, incluindo a escolha do número de bits de dados por byte, o número de bits de parada e a taxa de baud. Essa flexibilidade torna a UART adequada para uma variedade de aplicações.

Em resumo, a UART é um componente fundamental para a comunicação de dados em sistemas eletrônicos e é particularmente valiosa em situações em que a comunicação assíncrona é necessária ou desejada. Ela desempenha um papel importante em muitas tecnologias e dispositivos que dependem da troca de informações digitais.
</p>

<h1 id="desenvolvimento" align="center">Desenvolvimento e Descrição em Alto Nível</h1>

<p align="justify">Inicialmente foi proposto durante as sessões a criação de um diagrama inicial geral de como funcionaria o circuito. Dessa forma, foi possível identificar os três principais agentes do sistema. Sendo eles: o computador, a FPGA e o anexo do sensor DHT11.</p>

<p align="center">
	<img src="anexos/MEF/diagrama_geral.png" alt=Diagrama em blocos do sistema>
</p>

<p align="justify">A FPGA conterá o circuito lógico responsável por receber o byte do código do comando e do byte do endereço do sensor do computador (através do módulo de recebimento “rx”), decodificar os códigos e devolver o dado correspondente que será lido pelo sensor (através do módulo de transmissão “tx”). No circuito implementado na placa também é necessário o uso da máquina de estados geral (MEF) que transita entre os estados e controla o tempo de cada ação, além de um módulo específico para o sensor DHT11, responsável por receber, decodificar e devolver os dados lidos do ambiente de acordo com a solicitação do usuário. Como possuem 32 endereços para alocação de anexo do sensor, o módulo da MEF poderá chamar os 32 módulos, contanto que cada um tenha , como saída, 40 bits de dados, um bit de erro e um bit que informa que os dados foram recebidos. Além disso, todos os módulos chamados devem ter como entrada o “enable” de acordo com seu endereço e o clock. A comunicação da FPGA com o anexo do sensor é bidirecional, portanto, deve haver um fio “inout” de comunicação.

O sensor é um elemento externo que ficará conectado à placa através dos pinos da interface PMOD (VCC 3.3V, GND e algum pino compatível com o PMOD) presentes na placa, e é o responsável pela leitura da temperatura e umidade ambiente.
</p>

<h2>Protocolo de Envio e Recebimento de Dados</h2>

<p align="justify">
	O primeiro passo para o desenvolvimento do projeto foi a criação de um protocolo para envio e recebimento de dados. A importância de um protocolo adequado e bem definido se dá pela estrutura, eficiência, confiabilidade e integridade de dados, além de otimizar recursos fornecidos para o projeto. 
	A criação do protocolo para este projeto foi baseada nos requerimentos do problema, que demandava um sistema capaz de ler dados de temperatura e umidade, ativação de funções de monitoramento contínuo de cada um desses dados e o estado atual do sensor. Inicialmente, tinha-se também a informação de que as requisições e respostas deveriam ser compostas de 2 bytes, sendo o primeiro referente ao código do comando e, o segundo, referente ao endereço do sensor. Dessa forma, criou-se os seguintes protocolos para requisições e respostas.
</p>
<!-- TABELAAAAA -->
<div align="center">
  <table>
    <thead>
      <tr>
        <th>Código</th>
        <th>Descrição do Comando</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>0xAC</td>
        <td>Solicita a situação atual do sensor</td>
      </tr>
      <tr>
        <td>0x01</td>
        <td>Solicita a medida de temperatura atual</td>
      </tr>
      <tr>
        <td>0x02</td>
        <td>Solicita a medida de umidade atual</td>
      </tr>
      <tr>
        <td>0x03</td>
        <td>Ativa sensoriamento contínuo de temperatura</td>
      </tr>
      <tr>
        <td>0x04</td>
        <td>Ativa sensoriamento contínuo de umidade</td>
      </tr>
      <tr>
        <td>0x05</td>
        <td>Desativa sensoriamento contínuo de temperatura</td>
      </tr>
      <tr>
        <td>0x06</td>
        <td>Desativa sensoriamento contínuo de umidade</td>
      </tr>
    </tbody>
  </table>
</div>

<p align="center">Tabela do protocolo de requisições</p>


<div align="center">

| Código | Descrição da Resposta                                     |
| ------ | --------------------------------------------------------- |
| 0x1F   | Sensor com problema                                       |
| 0x07   | Sensor funcionando normalmente                            |
| 0x08   | Medida de umidade                                         |
| 0x09   | Medida de temperatura                                      |
| 0x0A   | Confirmação de desativação de sensoriamento contínuo de temperatura |
| 0x0B   | Confirmação de desativação de sensoriamento contínuo de umidade |
| 0x0D   | Medida de temperatura contínua (Inteiro)                  |
| 0x0E   | Medida de umidade contínua (Inteiro)                      |
| 0x0F   | Comando inválido                                          |
| 0xFF   | Comando inválido devido a ativação do sensoriamento contínuo |
| 0xAA   | Comando inválido pois o sensoriamento contínuo não foi ativado |
| 0xAB   | Erro na máquina de estados                                |

</div>

<p align="center">Tabela do protocolo de respostas</p>

<h2>Programação em Alto Nível (Linguagem C)</h2>

<p align="justify">
A comunicação inicial para o usuário solicitar uma requisição e posteriormente visualizar os dados retornados foi feita através de um programa, em linguagem C, no computador.
A etapa para o desenvolvimento do código referente a programação em alto nível  foi composta pela configuração da porta serial baseado na comunicação UART, uso de threads para a configuração do monitoramento contínuo e uma interface para solicitação e impressão de dados.
	
Dentro do módulo “main()” é inicializado algumas variáveis que auxiliarão no processo de criação da thread e na transferência/recebimento de dados. Em seguida o programa entra em um “while()” no qual ficará demonstrando ao usuário uma tabela com as funcionalidades do programa e exigindo a requisição de alguma das opções oferecidas dentro da validação de outro loop. 
Caso a resposta do usuário esteja dentro das oferecidas, o programa segue para dois switch case. O primeiro converterá a opção do usuário para um hexadecimal correspondente ao código de requerimento definido no protocolo. O segundo converterá a opção do usuário em relação ao endereço do sensor para um hexadecimal correspondente, dentre os 32 possíveis.
</p>

<h2>Módulo Principal</h2>

<p align="justify">O “FPGAImplementation” é o módulo principal responsável por conectar todos os outros módulos.

- input clock: O sinal de clock (50Mhz) usado para sincronizar todas as operações na FPGA.
- input bitSerialAtualRX: Sinal serial de entrada que carrega os bits recebidos da transmissão UART do PC.
- output bitSerialAtualTX: Sinal serial de saída que será transmitido para o PC.
- inout transmission_line_sensor_01: Fio bidirecional (inout) usado para se comunicar com o sensor DHT11.
- inout [30:0] transmission_line_other_sensors: Um vetor bidirecional  (inout) de 31 bits usado para se comunicar com outros sensores ou dispositivos que podem ser conectados à FPGA.

Ademais foram criados alguns fios utilizados para a transmissão de dados:

- dadosPodemSerEnviados: Um sinal wire que indica se os dados podem ser enviados da FPGA para outros dispositivos.
- request_command e request_address: Sinais wire que representam comandos e endereços recebidos do computador, respectivamente.
- response_command e response_value: Sinais wire que representam comandos e valores a serem transmitidos de volta ao computador.
- bitsEstaoEnviados: variável que informa quando os bits foram enviados para o computador. Essa variável é saída do módulo de comunicação UART TX. 
- indicaTransmissao: variável que informa que os dados estão sendo transmitidos para o computador.  
- bitsEstaoRecebidos: variável que informa quando os dados foram recebidos completamente pelo módulo de comunicação UART RX. Quando é atribuído valor lógico alto, significa que dois bytes foram recebidos pelo transmissor (computador). Esse fio direciona o início do processo de comunicação com o módulo da máquina de estados geral, tornando a MEF capaz de controlar o byte de requisição e endereço do sensor.

<h3>Módulo uart_rx</h3>
<p align="justify">No módulo principal, uart_rx possui como primeiro parâmetro o clock de 50Mhz. É responsável por receber os dados serializados através do sinal bitSerialAtualRX. Ele usa o sinal bitsEstaoRecebidos para indicar quando todos os bits foram recebidos com sucesso.Também lê os comandos e endereços recebidos e os coloca nos sinais request_command e request_address. </p>

<h3>Módulo uart_tx</h3>
<p align="justify">No módulo principal, uart_tx é responsável por transmitir os dados serializados de volta ao PC.
Ele usa o sinal indicaTransmissao para indicar quando a transmissão está ativa.
O sinal bitSerialAtualTX contém os bits que serão transmitidos serialmente.
Ele também usa o sinal bitsEstaoEnviados para indicar quando todos os bits foram transmitidos com sucesso.</p>

<h3>Módulo conexao_sensor</h3>
<p align="justify">
No módulo principal, conexao_sensor emprega uma MEF para controlar a sequência de operações, sendo assim o módulo principal do sistema. O primeiro parâmetro é referente ao clock de 50MHz do sistema. O segundo parâmetro (bitsEstaoRecebidos) é usado para determinar quando todos os bytes foram recebidos e o processamento pode começar. O terceiro e o quarto parâmetros são referentes ao comando enviado e o endereço do sensor, respectivamente. O quinto parâmetro (transmission_line_sensor_01) é um sinal bidirecional que representa o fio de comunicação com o sensor 01, especificamente um sensor DHT11. O sexto parâmetro (transmission_line_other_sensors) é uma linha de sinal para os outros 31 sensores que o sistema pode suportar. O sétimo parâmetro (dadosPodemSerEnviados) é um sinal que indica que os dados estão prontos para serem transmitidos.Os dois últimos parâmetros são referentes ao código da resposta e o valor da resposta. 
</p>

<h2>Módulo de Recepção (Rx)</h2>

<p align="justify">
	O módulo uart_rx é um módulo do protocolo UART responsável pela transmissão de dados de maneira serial. Nesse projeto, o modulo transmissor foi configurado para transmitir 8 bits de dados seriais, um bit de start e um bit de stop. Logo no início do módulo são declaradas algumas portas de entrada e saída. Dentre elas, tem-se:

- input clock: Sinal de clock de entrada para sincronização.
- input bitSerialAtual: Sinal serial de entrada que carrega os dados a serem recebidos.
- output bitsEstaoRecebidos:  Sinal de saída que indica que os dados foram recebidos e estão disponíveis.
- output [7:0] primeiroByteCompleto:  Saída de 8 bits que contém os dados do primeiro byte (de comando) recebido.
- output [7:0] segundoByteCompleto:  Saída de 8 bits que contém os dados do segundo byte (de endereço) recebido.

O código também usará registros (reg) para armazenar informações importantes, incluindo o valor do bit de start (serialDeEntrada), um contador de ciclos de clock (contadorDeClock) usado para temporização, um índice de bit atual (indiceDoBit) que rastreia a posição do bit atual dentro do byte recebido, um registro para armazenar os bits de dados recebidos (armazenaBits), e outros sinais de controle.

A máquina de estados é implementada em um bloco always sensível à borda de subida do sinal de clock. Cada estado realiza operações específicas de acordo com o protocolo de comunicação UART:

- estadoDeEspera: Aguarda a detecção de um bit de início (start bit). Se um bit de início for detectado, a máquina de estados transita para o estado estadoVerificaBitInicio. Caso contrário, ele se mantém nesse estado.

- estadoVerificaBitInicio: Verifica se o bit de início ainda está baixo (indicando a primeira metade do bit de início). Se a primeira metade do bit de início for detectada, a máquina de estados verifica se o bit de início ainda está baixo. Se sim, transita para o estado estadoDeEsperaBits.

- estadoDeEsperaBits: Aguarda para amostrar os bits de dados durante os próximos CLOCKS_POR_BIT - 1 ciclos de clock. Quando os 8 bits de dados são amostrados, transita para o estado estadoStopBit.

- estadoStopBit: Aguarda a conclusão do bit de parada (stop bit), que é logicamente alto. Após a espera, os dados são considerados recebidos, e a máquina de estados transita para o estado estadoDeLimpeza.

- estadoDeLimpeza: Após a recepção bem-sucedida de um byte completo, as ações de limpeza são realizadas. Os dados são considerados prontos para leitura (dadosOk   <= 1'b0), e a máquina de estados retorna ao estado “estadoDeEspera”.

Os sinais de saída são atribuídos com base nos estados da máquina de estados. bitsEstaoRecebidos recebe o sinal de dadosOk indicando que os dados foram lidos corretamente, e primeiroByteCompleto e segundoByteCompleto contêm os bytes de dados recebidos.

</p>

<h2>Módulo de Conexão com os Sensores</h2>
<p align="justify">
O módulo emprega uma MEF para controlar a sequência de operações. A MEF possui quatro estados principais: ESPERA, LEITURA, ENVIO e STOP. No estado ESPERA, o módulo aguarda comandos ou dados do sensor. No estado LEITURA, ele processa os comandos recebidos, lê os dados do sensor e prepara uma resposta. No estado ENVIO, os dados e comandos de resposta são sinalizados como prontos para envio. Finalmente, no estado STOP, o sensor é desativado e a MEF retorna ao estado ESPERA.

Ademais, os blocos de instruções geram respostas com base nos comandos recebidos. Essas respostas incluem valores lidos do sensor, comandos de confirmação e sinalização de erros, conforme necessário. Isso permite que o módulo forneça informações precisas aos dispositivos externos que o acessam por meio da interface UART.

Como este módulo funciona como uma máquina de estados geral, ela controla variáveis dentro do projeto. Para acionamento e saída do estado de ESPERA, “bitsEstaoRecebidos” entra como “enable” no módulo, possibilitando que a comunicação inicialize após o recebimento de dois bytes através do módulo “uart_rx”. Além disso, ao atribuir “dadosPodemSerEnviados”, cria um gatilho para que o módulo “uart_tx” envie os dados através da porta serial para o computador. Os bytes de requisição entram para serem analisados e os bytes de respostas são retornados para serem transmitidos.

Além disso, o módulo suporta o sensoriamento contínuo de temperatura e umidade. Ele verifica se o sensoriamento contínuo está ativado e responde aos comandos apropriados para ativar ou desativar essa funcionalidade. Isso é útil em aplicações que requerem monitoramento constante das condições ambientais. O código opera em um loop de estado, onde a máquina de estados é atualizada com base no sinal de clock. O processamento ocorre quando não há erros, e as respostas são preparadas para envio quando a máquina de estados está no estado de envio.

O módulo realiza verificações de erros, incluindo a detecção de erros de paridade (errorChecksum) e outros erros relacionados aos sensores. Se um erro for detectado, o módulo gera uma resposta apropriada, informando sobre o problema. Isso é crucial para garantir a confiabilidade das leituras dos sensores.

Portanto, o módulo conexao_sensor é uma implementação versátil de comunicação com sensores em Verilog. Ele oferece suporte a múltiplos sensores, controle flexível por endereço, sensoriamento contínuo e detecção de erros, tornando-o adequado para uma ampla gama de aplicações em sistemas embarcados.

</p>

<h2>Divisor de clock</h2>

<p align="justify">O projeto conta com um divisor de clock para a frequência oferecida na placa de 50MHz. Nesse caso, o clock será dividido em 1MHz. Isso ocorre, devido a necessidade de abaixar a frequência para realizar a leitura no sensor DHT11 pelo módulo DHT11_Communication de maneira eficiente.
	O programa entra em um bloco always sensível à borda de subida de “clock_SYS”. Ou seja, toda vez que houver uma borda de subida ele executará esse bloco que faz uma verficiação através de um registrador que serve como um contador (contador_clock). Caso esse registrador esteja abaixo de 50 ele entra em um bloco de verificação onde seu valor é acrescido em 1 ( contador_clock <= contador_clock + 1'b1) e a saída “clock_1MHz” é forçada a ser 0. Quando o contador exceder o valor de 50, o código entra no bloco “else” onde será resetado o valor do contador e a saída de “clock_1MHz” será forçada a ser 1. Assim, obtém-se o valor de 1MHz para o clock. 
	</p>

<h2>Módulo de Comunicação DHT11</h2>

<p align="justify">

O código apresentado é a descrição de um módulo de comunicação para interagir com um sensor DHT11, tendo destaque os principais componentes e estados da máquina de estados finitos (FSM) implementada. Este módulo teve sua base de implementação retirada do site [KanCloud](https://www.kancloud.cn/dlover/fpga/1637659). Entretanto, todas suas alterações foram realizadas pela equipe de desenvolvimento.

O módulo possui as seguintes entradas e saídas:

- clock_1M: Um sinal de relógio com frequência de 1 MHz.
- enable_sensor: Um sinal de controle que ativa ou desativa a comunicação com o sensor.
- dht11: Um sinal inout que se conecta ao sensor DHT11.
- dados_sensor: Um sinal de saída que contém os dados lidos do sensor.
- erro: Um sinal de saída que indica se ocorreu algum erro na máquina.
- done: Um sinal de saída que indica quando a máquina terminou sua operação.

O código também define várias variáveis e parâmetros que são usados durante a operação da máquina. Alguns deles são:

- direcao_dado: Indica a direção do sinal do dht11 (entrada ou saída).
- dados_enviados_sensor: Armazena o valor a ser enviado para o sensor.
- contador_dados: Conta os bits de dados recebidos do sensor.
- dados_bruto: Armazena os dados brutos recebidos do sensor antes de serem processados.
- contador: Contador de tempo usado para medir intervalos de tempo.
- start_f1, start_f2, start_rising: Sinais auxiliares para detectar bordas de subida no sinal de ativação.
- estado_atual: Variável que representa o estado atual da máquina de estados.
- erro_na_maquina: Indica se ocorreu algum erro durante a operação da máquina.
- done_reg: Sinal auxiliar para indicar o término da operação.

A principal parte do código é a máquina de estados finitos (FSM) que controla a comunicação com o sensor DHT11. Ela consiste em vários estados, cada um com sua própria lógica de funcionamento:

- ESPERA: Este é o estado inicial da máquina. Ela aguarda um sinal de início do sensor DHT11 (uma borda de subida seguida de um sinal alto). Se o sinal de início for detectado, a máquina transita para o estado BIT_DE_INICIO.

- BIT_DE_INICIO: Neste estado, a máquina aguarda um período de tempo específico para sincronizar com o sensor. Quando o tempo de sincronização é atingido, a máquina transita para o estado ENVIA_SINAL_A_20US.

- ENVIA_SINAL_A_20US: Neste estado, a máquina envia um sinal de 20 microssegundos para o sensor. Após o envio do sinal, a máquina transita para o estado ESPERA_SINAL_B.

- ESPERA_SINAL_B: A máquina espera que o sensor DHT11 responda com um sinal baixo. Se o sensor enviar um sinal baixo, a máquina transita para o estado ESPERA_SINAL_A. Se o sensor não responder dentro de um tempo limite, a máquina transita para o estado ACABA_PROCESSO e sinaliza um erro.

- ESPERA_SINAL_A: Neste estado, a máquina espera que o sensor DHT11 envie um sinal alto. Se o sensor enviar um sinal alto, a máquina transita para o estado FIM_SYNC. Se o sensor não responder dentro de um tempo limite, a máquina transita para o estado ACABA_PROCESSO e sinaliza um erro.

- FIM_SYNC: Indica o fim da sincronização com o sensor DHT11. A máquina aguarda o sensor enviar um sinal baixo. Se o sensor enviar um sinal baixo, a máquina transita para o estado WAIT_1_BIT_DHT11. Se o sensor não responder dentro de um tempo limite, a máquina transita para o estado ACABA_PROCESSO e sinaliza um erro.

- WAIT_1_BIT_DHT11: Neste estado, a máquina aguarda a transmissão de um bit de dados pelo sensor DHT11. Se o bit for lido como 1, a máquina transita para o estado LE_DADOS. Se o bit não for lido dentro de um tempo limite, a máquina transita para o estado ACABA_PROCESSO e sinaliza um erro.

- LE_DADOS: A máquina lê os dados enviados pelo sensor DHT11. Ela conta os bits recebidos e os armazena em dados_bruto. Dependendo do valor lido (0 ou 1), ela atualiza dados_bruto. Se todos os 40 bits foram lidos, a máquina transita para o estado COLETA_DADOS. Se um erro ocorrer durante a leitura, ela volta para WAIT_1_BIT_DHT11.

- COLETA_DADOS: Neste estado, a máquina transfere os dados brutos armazenados em dados_bruto para dados_sensor, representando os dados de temperatura e umidade lidos. Ela também verifica se o último bit recebido é 1; se não for, sinaliza um erro. Após a coleta dos dados, a máquina transita para o estado ACABA_PROCESSO.

- ACABA_PROCESSO: Este estado é alcançado após a conclusão bem-sucedida ou com erro da comunicação com o sensor DHT11. Se ocorrer um erro na máquina, ele mantém a máquina neste estado e sinaliza o erro. Se não houver erro, ele conclui o processo e sinaliza que a operação foi concluída. Após um período de normalização, a máquina volta ao estado ESPERA para aguardar a próxima comunicação.

O código utiliza contadores de tempo e sinais auxiliares para controlar o tempo e detectar eventos relevantes, como bordas de subida e descida nos sinais. A máquina de estados coordena a interação com o sensor DHT11 de acordo com o protocolo de comunicação especificado.

Em resumo, o código implementa uma máquina de estados para se comunicar com um sensor DHT11, lendo dados de temperatura e umidade do sensor e sinalizando erros, se necessário.

</p>

<h2>Módulo de Transmissão (Tx)</h2>

<p align="justify">

O módulo uart_tx é um módulo de protocolo UART, utilizado para a transmissão de dados de maneira serial. Nesse projeto, esse módulo foi configurado para ser capaz de transmitir 8 bits.
Primeiramente, define-se as entradas e saídas do módulo:

- input clock: Sinal de clock de 50MHz para sincronização.
- input haDadosParaTransmitir: Um sinal de dados válido que indica quando há dados para serem transmitidos.
- input [7:0] primeiroByteASerTransmitido: Sinal de 8 bits que contém os dados totais recebidos do 1° byte a ser enviado por TX.
- input [7:0] segundoByteASerTransmitido: Sinal de 8 bits que contém os dados totais recebidos do 2° byte a ser enviado por TX.
- output indicaTransmissao: Indica se a transmissão está ativa.
- output reg  bitSerialAtual: O bit do sinal serial atual que será transmitido.
- output bitsEstaoEnviados: Sinal de saída que confirma o envio dos dados.

Diversos registradores (reg) são definidos para armazenar informações importantes durante a transmissão, como o estado atual da máquina de estados, um contador de ciclos de clock, um índice do bit atual a ser transmitido, os dados a serem transmitidos, e outros sinais de controle.

A máquina de estados é implementada em um bloco always sensível à borda de subida do sinal de clock. Cada estado realiza operações específicas de acordo com o protocolo de comunicação UART:

- estadoDeEspera: O transmissor fica ocioso, com o bit serial em nível alto. Se houver dados válidos para transmitir, ele passa para o estado estadoEnviaBitInicio.

- estadoEnviaBitInicio: Este estado envia o bit de início da transmissão (0) e aguarda um número de ciclos de clock determinado.

- estadoEnviaBits: Neste estado, os bits de dados são enviados um por um e avança para o próximo bit até que todos os 8 bits tenham sido transmitidos. Aguarda um número específico de ciclos de clock para finalizar.

- estadoEnviaBitFinal: Envio do bit de parada da transmissão (1) e aguarda um número de ciclos de clock determinado.

- estadoDeLimpeza: Estado intermediário de finalização da transmissão.

Os valores dos sinais de saída (bitSerialAtual, indicaTransmissao e bitsEstaoEnviados) são atribuídos com base nos estados da máquina de estados. No estado estadoDeEspera, o código verifica se há dados válidos para transmitir e seleciona qual byte deve ser transmitido primeiro. Após a transmissão do primeiro byte, o código entra em um estado intermediário estadoDeLimpeza antes de voltar ao estadoDeEspera. O sinal transmissaoConcluida é usado para indicar quando a transmissão foi concluída. O sinal transmissaoEmAndamento é usado para indicar quando a transmissão está ativa.

Este módulo descreve a lógica necessária para transmitir dados UART de forma assíncrona, seguindo o protocolo de comunicação UART padrão. A temporização é crítica na comunicação UART, e este código aborda a transmissão de bits de dados serializados e os bits de início e parada.

</p>

<h1 id="descricao-e-analise-dos-testes" align="center">Descrição e Análise dos Testes e Simulações</h1>
<p align="justify">
	O projeto proposto, em sua fase final, apresentou ótimos resultados conforme o solicitado, lendo e entregando os dados solicitados corretamente. A interação do usuário com o  sistema é feita inteiramente através do terminal, onde, através de uma tabela de opções, deve ser selecionado o requerimento desejado e o endereço no qual se encontra o sensor.
	
Porém, destaca-se um problema quando o sensoriamento contínuo é ligado. Individualmente, o caso consegue atingir o requisito e lê os dados de maneira constante. Mas, após encerrar a leitura do sensoriamento e solicitar qualquer outra requisição, o programa cai no caso do sensoriamento contínuo aberto anteriormente. Uma alternativa possível para contornar esse caso foi criar um código em C que solicitasse a requisição de temperatura/umidade atual continuamente. Com isso, nenhum problema é observável. Outra solução é re-programar a placa depois de pedir uma ativação do sensoriamento contínuo.

Em relação ao funcionamento do programa e interação direta com o usuário, como dito anteriormente, foi desenvolvido uma tabela com as seguintes opções possíveis de requisição:

1.Solicita a situação atual do sensor 

2.Solicita a medida de temperatura atual 

3.Solicita a medida de umidade atual 

4.Ativa sensoriamento contínuo de temperatura 

5.Ativa sensoriamento contínuo de umidade

</p>

<p align="center">
	<img src="anexos/testes/testes-em-execucao/teste_tabela_requisicao.png" alt=Tabela de requisições>
</p>

<p align="justify">Nesse caso, a seleção da solicitação do dado que deseja ler e o endereço do sensor é feita através de números inteiros referentes a cada opção, que devem ser escritos e enviados pelo terminal. E, para desativar o sensoriamento contínuo de temperatura ou umidade basta apertar a tecla enter.

 Abaixo estão os testes referentes aos possíveis cenários de solicitação e exibição de dados para o usuário:
</p>

<p align="center">
	<img src="anexos/testes/testes-em-execucao/teste_1.png" alt=Teste para situação atual de funcionamento do sensor indicado no endereço 0x01>
</p>
<p align="center">Teste para situação atual de funcionamento do sensor indicado no endereço 0x01</p>

<p align="center">
	<img src="anexos/testes/testes-em-execucao/teste_2.png" alt=Teste para solicitação da temperatura atual do ambiente pelo sensor indicado no endereço 0x01>
</p>
<p align="center">Teste para solicitação da temperatura atual do ambiente pelo sensor indicado no endereço 0x01</p>

<p align="center">
	<img src="anexos/testes/testes-em-execucao/teste_3.png" alt=Teste para solicitação da umidade atual do ambiente pelo sensor indicado no endereço 0x01>
</p>
<p align="center">Teste para solicitação da umidade atual do ambiente pelo sensor indicado no endereço 0x01</p>

<p align="center">
	<img src="anexos/testes/testes-em-execucao/teste_4.png" alt=Teste para solicitação da ativação do sensoriamento contínuo de temperatura do ambiente pelo sensor indicado no endereço 0x01>
</p>
<p align="center">Teste para solicitação da ativação do sensoriamento contínuo de temperatura do ambiente pelo sensor indicado no endereço 0x01</p>

<p align="center">
	<img src="anexos/testes/testes-em-execucao/teste_4_continuo.png" alt=Exibição do resultado de maneira individual da ativação do sensoriamento contínuo de temperatura>
</p>
<p align="center">Exibição do resultado de maneira individual da ativação do sensoriamento contínuo de temperatura</p>

<p align="center">
	<img src="anexos/testes/testes-em-execucao/teste_5.png" alt=Teste para solicitação da ativação do sensoriamento contínuo de umidade do ambiente pelo sensor indicado no endereço 0x01>
</p>
<p align="center">Teste para solicitação da ativação do sensoriamento contínuo de umidade do ambiente pelo sensor indicado no endereço 0x01</p>

<p align="center">
	<img src="anexos/testes/testes-em-execucao/teste_5_continuo.png" alt=Exibição do resultado de maneira individual da ativação do sensoriamento contínuo de umidade>
</p>
<p align="center">Exibição do resultado de maneira individual da ativação do sensoriamento contínuo de umidade</p>

[Vídeo - Apresentação de metodologia, testes e discussão de melhorias do protótipo de interface de E/S](https://www.youtube.com/watch?v=cKk95P4JJlk "Vídeo do Youtube")


<h1 id="conclusao" align="center">Conclusão</h1>

<p align="justify">
	O sistema de entrada e saída para monitoramento de temperatura e umidade, com relação aos resultados, demonstrou um excelente funcionamento, uma vez que cumpre com a maioria dos requisitos propostos no projeto. O único problema encontrado, foi com relação ao monitoramento contínuo, que embora faça a leitura e exibição de maneira correta, possui um problema após o encerramento e solicitação de outro comando em seguida. 
	
Ademais, nota-se, durante a etapa de elaboração do projeto, a abordagem de diversos aspectos importantes da área de sistemas digitais que culminaram em uma solução completa e funcional e no desenvolvimento pessoal dos membros envolvidos. Dentre eles, têm-se a comunicação serial, protocolo de comunicação UART,  integração das linguagens de descrição de hardware (Verilog) e programação de alto nível (C), utilização da FPGA mercúrio IV, uso do sensor DHT11, etc. 

Além disso, esse projeto tem potencial para se expandir e evoluir ainda mais. Novas funcionalidades, como o envio de dados para nuvem ou a adição de sensores adicionais, podem ser incorporadas para aumentar a utilidade do sistema.
Porém, ressalta-se alguns tópicos sensíveis, tais como: a complexidade devido à capacidade de gerenciar até 32 sensores diferentes (o que aumenta o consumo de recursos em termos de lógica e memória em uma FPGA, o que pode ser uma preocupação em sistemas com recursos limitados), dificuldade de sincronização do clock (uma vez que ele recebe uma alta frequência (50 MHz) e realiza uma divisão desse sinal para operações internas) e gerenciamento da comunicação com um grande número de sensores.

Em resumo, o sistema representa uma implementação versátil e funcional para a comunicação com sensores em sistemas embarcados. Sua capacidade de gerenciar múltiplos sensores, detectar erros e oferecer suporte ao sensoriamento contínuo o torna uma escolha adequada para uma variedade de aplicações. No entanto, considerações de complexidade, escalabilidade e requisitos de clock devem ser cuidadosamente avaliadas ao adotar esse módulo em um projeto específico

</p>

<h1 id="referencias" align="center">Referências</h1>

<p align="justify">
DATASHEET; Sensor de Umidade e Temperatura - DHT 11. Disponível em: https://datasheetspdf.com/pdf/785590/D-Robotics/DHT11/1 Acessado em 26 de setembro de 2023.

BARUSSO, Carolina et al. Medição de Temperatura e Umidade utilizando Arduino Uno e Sensor DHT11 para Aplicações Residenciais. Publicação 2022. Disponível em: https://intranet.cbt.ifsp.edu.br/qualif/volume11/artigo1.pdf. Acessado em 26 de setembro de 2023.
</p>
























<h1 id="descricao-do-sistema" align="center">Descrição do sistema</h1>

<p align="center">
  <img src="anexos/MEF/dependencyTree.drawio.png" alt=Diagrama de dependências para sicronização>
</p>

<h1 id="script-de-compilacao" align="center">Como executar</h1> 

<h1 id="descricao-e-analise-dos-testes" align="center">Descrição e Análise dos Testes</h1>



Para clonar este repositório:

1. ```$ git clone https://github.com/douglasojesus/interface-entrada-saida;```

2. Abra com o Quartus \interface-entrada-saida\fpgaImplementation\FPGAImplementation.qpf e compile o código;

3. Programe o código na placa FPGA Cyclone IV E EP4CE30F23C7;

4. Conecte a porta serial do computador com a porta serial da FPGA;

5. Compile o código \interface-entrada-saida\uartSerialCommunication.c e o execute;

6. Interaja com o terminal e aproveite o sistema!
