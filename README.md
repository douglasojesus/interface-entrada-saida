<h1 align="center">
📄<br>Projeto de Sensor Digital em FPGA utilizando Comunicação Serial.
</h1>
<h4 align="center">
Projeto produzido a ser avaliado pela disciplina de M.I Sistemas Digitais da Universidade Estadual de Feira de Santana. 
</h4>
<h2 align="center">
Implementação de um protótipo de sensor para medição de temperatura e umidade.
</h2>

Contribuidores: Douglas Oliveira de Jesus, Emanuel Antonio Lima Pereira, Émerson Rodrigo Lima Pereira e Gabriel Sousa Sampaio.

• <a href="#introducao">Introdução</a> 

• <a href="#requisitos">Requisitos</a> 

• <a href="#recursos">Recursos utilizados</a> 

• <a href="#script-de-compilacao">Como executar</a> 

• <a href="#metodologia-e-tecnicas-aplicadas">Metodologia e técnicas aplicadas no projeto</a> 

• <a href="#descricao-do-sistema">Descrição em alto nível do sistema proposto</a> 

• <a href="#descricao-do-protocolo-de-comunicacao">Descrição do protocolo de comunicação desenvolvido</a> 

• <a href="#descricao-e-analise-dos-testes">Descrição e análise dos testes e simuações</a> 

• <a href="#membros">Membros</a> 

• <a href="#referencias">Referências</a> 
  
<h1 id="introducao" align="center">Introdução</h1> 

  O crescente mercado de internet das coisas (IoT) tem levado ao desenvolvimento de projetos cada vez mais sofisticados e movimentando centenas de bilhões de dólares por ano. Através dela, possibilita-se promover a conexão de dispositivos, sensores e sistemas em uma rede interconectada, assim, revolucionando a maneira como interagimos com o mundo digital e físico. 
  Neste contexto, surge-se a proposta da criação de um sistema modular de entrada e saída voltado para o monitoramento de temperatura e umidade local, utilizando uma plataforma baseada em FPGAs para confecção dos sensores. 
  Este relatório técnico, portanto, analisa um projeto de comunicação com sensores implementado em Verilog, com foco em sua funcionalidade e estrutura. O protótipo é projetado para operar em um ambiente de microcontrolador ou FPGA, interagindo com sensores diversos por meio de um barramento UART. É capaz de se comunicar com até 32 sensores, processar comandos, ler dados dos sensores, gerar respostas e suportar o sensoriamento contínuo. 
  Para atingir o objetivo, utilizou-se o kit de desenvolvimento Mercúrio IV como plataforma base, explorando os conceitos do protocolo de comunicação UART e fazendo uso do sensor DHT11. Além disso, esse projeto integra as linguagens de descrição de hardware (Verilog), desenvolvida através da ferramenta Quartus Prime 22.1, e programação de alto nível (C), ambas utilizando o sistema operacional Linux, unindo assim o melhor de ambos os mundos para oferecer uma solução eficiente e versátil. Este relatório descreve as principais características de todos os módulos, detalhando suas entradas e saídas, variáveis internas, controle de sensores, estados da máquina de estados finitos (MEF), geração de respostas, verificação de erros e o uso do clock. Além disso, é realizada uma análise crítica das funcionalidades do módulo e de sua aplicabilidade em sistemas embarcados.

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

<h1 id="descricao-do-sistema" align="center">Descrição do sistema</h1>
<img src="MEF/dependencyTree.drawio.png" alt=Diagrama de dependências para sicronização>

<h1 id="script-de-compilacao" align="center">Como executar</h1> 

Para clonar este repositório:

1. ```$ git clone https://github.com/douglasojesus/interface-entrada-saida;```

2. Abra com o Quartus \interface-entrada-saida\fpgaImplementation\FPGAImplementation.qpf e compile o código;

3. Programe o código na placa FPGA Cyclone IV E EP4CE30F23C7;

4. Conecte a porta serial do computador com a porta serial da FPGA;

5. Compile o código \interface-entrada-saida\uartSerialCommunication.c e o execute;

6. Interaja com o terminal e aproveite o sistema!
