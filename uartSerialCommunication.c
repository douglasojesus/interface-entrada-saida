//Abaixo os importes necessários para o funcionamento do código.
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <termios.h>
#include <string.h>
#include <sys/time.h>
#include <sys/types.h>
#include <pthread.h>
#include <stdlib.h>

//Struct para acesso dessas variáveis em varias funções inclusive a main (função principal).
struct ThreadData {
    int arquivoSerial;
    int tam;
    unsigned char *bufferRxTx;
    int parar;
};

//Função que mostra as opções disponíveis para o leitor.
void tabela();

//Função para limpar o buffer.
void limparBufferEntrada();

//Função para escrever na porta serial.
void escrever_Porta_Serial(int, unsigned char[], int);

//Função para ler da porta serial.
void ler_Porta_Serial(int, unsigned char[], int);

//Thread para o sensoriamento contínuo de temperatura.
void *sensoriamento_Temp(void *arg);

//Thread para o sensoriamento contínuo de umidade.
void *sensoriamento_Umid(void *arg);

int main() {
	//Declaração de variáveis.
	int arquivoSerial, tam;
	unsigned int requisicao;
	unsigned int endereco_sensor;
	unsigned char bufferRxTx[255];

	//Configuração das portas seriais.
	struct termios options;

	//O endereço é por convenção a primeira porta serial disponível.
	arquivoSerial = open("/dev/ttyS0", O_RDWR | O_NDELAY | O_NOCTTY); 

	//Verifica se não conseguiu abrir o arquivo por algum motivo.
	if (arquivoSerial < 0) { 
		perror("\x1b[31mErro ao abrir porta serial\x1b[0m\n");
		return -1;
	}
	
	//Configurando a porta serial.
	options.c_cflag = B9600 | CS8 | CLOCAL | CREAD; //Baud: 9600, CS8: tamanho do envio de dados.
	options.c_iflag = IGNPAR;
	options.c_oflag = 0;
	options.c_lflag = 0;

	//Aplicando as configurações.
	tcflush(arquivoSerial, TCIFLUSH); //Limpa o buffer do arquivoSerial.
	tcsetattr(arquivoSerial, TCSANOW, &options); //Aplique agora, neste instante.

	while(1){
		//Criando a thread.
		pthread_t thread, thread1;

		//Criando a struct dos argumentos que vão na thread.
		struct ThreadData data;

		//Atribuindo dados da main nas variáveis da struct.
		data.arquivoSerial = arquivoSerial;
		data.bufferRxTx = bufferRxTx;
		data.tam = tam;
		data.parar = 0;
	
		//Chamando a tabela de requisições.
		tabela();

		//Recebendo a requisição e o endereço do sensor.
		scanf("%d %d", &requisicao, &endereco_sensor);

		//Validação das entradas.
		while(requisicao < 1 || requisicao > 7 || endereco_sensor < 1 || endereco_sensor > 32){
			printf("Escolha uma requisição e sensor valido!\n");
			scanf("%d %d", &requisicao, &endereco_sensor);
			system("clear");
		}

		//Switch case para atribuir os dados corretos na variável requisicao, de acordo com a opção escolhida.
		switch(requisicao){
			case 1:
				requisicao = 0xAC;
				break;
			case 2:
				requisicao = 0x01;
				break;
			case 3:
				requisicao = 0x02;
				break;
			case 4:
				requisicao = 0x03;
				break;
			case 5:
				requisicao = 0x04;
				break;
			case 6:
				requisicao = 0x05;
				break;
			case 7: 
				requisicao = 0x06;
				break;
			default:
				break;
		}

		//Switch case para atribuir os dados corretos na variável endereco_sensor, de acordo com a opção escolhida.
		switch (endereco_sensor)
		{
		case 1:
			endereco_sensor = 0x01;
			break;
		default:
			printf("Esse sensor não está em funcionamento!\n");
			break;
		}
		
		limparBufferEntrada();

		//Juntando e convertendo para string. 
		sprintf(bufferRxTx, "%c%c", requisicao, endereco_sensor);

		//Requisições válidas.
		switch (requisicao)
		{
		case 0xAC:
			break;
		case 0x01:
			break;
		case 0x02:
			break;
		case 0x03:
			break;
		case 0x04:
			break;
		case 0x05:
			break;
		case 0x06:
			break;
		default:
			printf("\x1b[31mRequisição inválida, por favor escolha uma requisição válida da próxima vez.\x1b[0m\n");
			break;
		}

		escrever_Porta_Serial(arquivoSerial, bufferRxTx, tam);
		ler_Porta_Serial(arquivoSerial, bufferRxTx, tam);
		
		//Switch case responsável por verificar a resposta da placa, e realizar uma operação de saída adequada, no caso printf().
		unsigned int resposta = (unsigned int) bufferRxTx[0];
		switch(resposta){
			case 0x1F:
				printf("\x1b[31mSensor com problema.\x1b[0m\n");
				sleep(3);
				break;
			case 0x07:
				printf("Sensor funcionando normalmente.\n"); 
				sleep(3);
				break;
			case 0x08:
				printf("\nMedida de umidade: %02d %% RH.\n",bufferRxTx[1]); 
				sleep(3);
				break;
			case 0x09:
				printf("\nMedida de temperatura: %02d °C.\n",bufferRxTx[1]); 
				sleep(3);
				break;
			case 0x0A:
				printf("Confirmação de desativação de sensoriamento contínuo de temperatura.\n"); 
				sleep(3);
				break;
			case 0x0B:
				printf("Confirmação de desativação de sensoriamento contínuo  de umidade.\n"); 
				sleep(3);
				break;				
			case 0x0D:
				// Cria a thread de sensoriamento de temperatura e passa os dados como argumento.
				if (pthread_create(&thread, NULL, sensoriamento_Temp, &data) != 0) {
					fprintf(stderr, "Erro ao criar a thread.\n");
					return 1;
				}

				printf("Pressione Enter para parar sair do Sensoriamento Contínuo.\n");
				getchar(); // Aguarda a entrada do usuário.

				// Define a variável 'parar' como verdadeira para encerrar a thread de sensoriamento de temperatura.
				data.parar = 1;
			
				// Aguarda a thread de sensoriamento de temperatura terminar
				if (pthread_join(thread, NULL) != 0) {
					fprintf(stderr, "Erro ao esperar pela thread.\n");
					return 1;
				}

				printf("Sensoriamento Contínuo de temperatura encerrado.\n");

				break;
			case 0x0E:
				// Cria a thread de sensoriamento de umidade e passa os dados como argumento.
				if (pthread_create(&thread1, NULL, sensoriamento_Umid, &data) != 0) {
					fprintf(stderr, "Erro ao criar a thread.\n");
					return 1;
				}
				
				printf("Pressione Enter para parar sair do Sensoriamento Contínuo.\n");
				getchar(); // Aguarda a entrada do usuário.
			
				// Define a variável 'parar' como verdadeira para encerrar a thread de sensoriamento de umidade.
				data.parar = 1;
			
				// Aguarda a thread de sensoriamento de umidade terminar.
				if (pthread_join(thread1, NULL) != 0) {
					fprintf(stderr, "Erro ao esperar pela thread.\n");
					return 1;
				}
			
				printf("Sensoriamento Contínuo de umidade encerrado.\n");

				break;
			case 0xFF:
				printf("\x1b[31mComando inválido devido a ativação do sensoriamento contínuo.\x1b[0m\n"); 
				sleep(3);
				break;
			case 0xAA:
				printf("\x1b[31mComando inválido pois o sensoriamento contínuo não foi ativado.\x1b[0m\n"); 
				sleep(3);
				break;
			case 0xAB:
				printf("\x1b[31mErro na máquina de estados.\x1b[0m\n"); 
				sleep(3);
				break;	
			default:
				printf("\x1b[31mErro de leitura, observe se o sensor se encontra conectado! \x1b[0m\033[0m\n"); 
				sleep(3);
				break;					
		}
	}
	//Fecho o arquivoSerial para evitar possíveis erros.
	close(arquivoSerial);
	return 0;
}


void tabela(){
system("clear");
printf("\033[32m-------------------------------------------------------------------------------------------------------\n");
    printf("|                Tabela Requisição                  |                Endereço Sensor                  |\n");
    printf("-------------------------------------------------------------------------------------------------------\n");
    printf("|                                                   | DHT11 => 1: 0x01  9:  0x09  17: 0xAB  25: 0xBD  |\n");
    printf("| 1: Situação atual do sensor.                      |          2: 0x02  10: 0x0A  18: 0xAC  26: 0xBE  |\n");
    printf("| 2: Medida de temperatura atual.                   |          3: 0x03  11: 0x0B  19: 0xAD  27: 0xBF  |\n");
    printf("| 3: Medida de umidade atual.                       |          4: 0x04  12: 0x0C  20: 0xAE  28: 0xCA  |\n");
    printf("| 4: Ativa sensoriamento contínuo de temperatura.   |          5: 0x05  13: 0x0D  21: 0xAF  29: 0xCB  |\n");
    printf("| 5: Ativa sensoriamento contínuo de umidade.       |          6: 0x06  14: 0x0E  22: 0xBA  30: 0xCC  |\n");
    printf("| 6: Desativa sensoriamento contínuo de temperatura.|          7: 0x07  15: 0x0F  23: 0xBB  31: 0xCD  |\n");
    printf("| 7: Desativa sensoriamento contínuo de umidade.    |          8: 0x08  16: 0xAA  24: 0xBC  32: 0xCE  |\n");
    printf("|                                                   |                                                 |\n");
    printf("-------------------------------------------------------------------------------------------------------\n");
}

void escrever_Porta_Serial(int arquivoSerial, unsigned char bufferRxTx[], int tam){
  	tam = strlen(bufferRxTx);
  	tam = write(arquivoSerial, bufferRxTx, tam);
  	printf("Escreveu %d bytes em UART\n", tam);
  	sleep(3);
}

void ler_Porta_Serial(int arquivoSerial, unsigned char bufferRxTx[], int tam){
  	memset(bufferRxTx, 0, 255);
  	tam = read(arquivoSerial, bufferRxTx, 2);
  	printf("Recebeu %d bytes\n", tam);
	sleep(1);
}

void *sensoriamento_Temp(void *arg){
	//Manipulação para acesso das variáveis contidas na struct nessa função.
  	struct ThreadData *data = (struct ThreadData *)arg;
  	while (!data->parar) {
		system("clear");
    	ler_Porta_Serial(data->arquivoSerial, data->bufferRxTx, data->tam);
    	printf("Temperatura atual: %d °C\n", data->bufferRxTx[1]);
    	sleep(3); 
    }
    return NULL;
}

void *sensoriamento_Umid(void *arg){
	//Manipulação para acesso das variáveis contidas na struct nessa função.
  	struct ThreadData *data = (struct ThreadData *)arg;
	while (!data->parar) {
		system("clear");
    	ler_Porta_Serial(data->arquivoSerial, data->bufferRxTx, data->tam);
    	printf("Umidade atual: %d %% RH\n", data->bufferRxTx[1]);
    	sleep(3); 
    }
    return NULL;
}

void  limparBufferEntrada(){
	int c;
  	while((c = getchar()) != '\n' && c != EOF){
  	}
}