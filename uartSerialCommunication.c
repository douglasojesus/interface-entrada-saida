#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <pthread.h>
#include <termios.h>
#include <pthread.h>
#include <stdlib.h>

#define true 1
#define false 0

struct Serial
{
	int arquivoSerial; 
	int tam;
	unsigned char bufferRxTx[255]; 

};

/*
*Código que faz a configuração UART e envio dos dados pela porta serial ttyS0.
*/

typedef struct ThreadData ThreadData;
typedef struct ThreadData1 ThreadData;

// Estrutura para armazenar os dados da thread
struct ThreadDataT {
    int temperatura;
    int parar;
};

// Estrutura para armazenar os dados da thread1
struct ThreadDataH {
    int umidade;
    int parar;
};

// Função executada pela thread de sensorimaneto contínuo de temperatura
void *sensoriamento_Temperatura(void *arg) {
    ThreadDataT *data = (ThreadDataT *)arg;
    while (!data->parar) {
		system("clear");
		ler_Porta_Serial(data->bufferRxTx, data->arquivoSerial, data->tam);
        printf("Temperatura: %d\n °C", data->temperatura);
        sleep(1); // Espera 1 segundo antes de incrementar o contador
    }
    return NULL;
}

//Função executada pela thread de sensoriamento contínuo de umidade
void *sensoriamento_Umidade(void *arg) {
    ThreadDataH *data = (ThreadDataH *)arg;
    while (!data->parar) {
		system("clear");
		ler_Porta_Serial(data->bufferRxTx, data->arquivoSerial, data->tam);
        printf("Umidade: %d\n %%RH", data->umidade);
        sleep(1); // Espera 1 segundo antes de incrementar o contador
    }
    return NULL;
}

//função que mostra as opções disponíveis para o leitor
void tabela();

//Lendo entradas da porta serial
void ler_Porta_Serial(unsigned char, int, int);

//Escrevendo na porta serial
void escreve_Porta_Serial(int, unsigned char, int);

int main() {
	
		struct Serial dados;
		unsigned int requisicao;
		struct termios options; 
		
		/* Configuração das portas seriais */

		dados.arquivoSerial = open("/dev/ttyS0", O_RDWR | O_NDELAY | O_NOCTTY); //O endereço é por convenção a primeira porta serial disponível
		
		if (dados.arquivoSerial < 0) { //Não conseguiu abrir o arquivo por algum motivo.
			perror("\x1b[31Error ao abrir a porta serial.\x1b[0m");
			return -1;
		}
		
		// Configurando a porta serial 
		options.c_cflag = B9600 | CS8 | CLOCAL | CREAD; //Baud: 9600, CS8: tamanho do envio de dados.
		options.c_iflag = IGNPAR;
		options.c_oflag = 0;
		options.c_lflag = 0;

		// Aplicando as configurações 
		tcflush(dados.arquivoSerial, TCIFLUSH); //Limpa o buffer do arquivoSerial
		tcsetattr(dados.arquivoSerial, TCSANOW, &options); //Aplique agora, neste instante

		while(true){
			
			//Chamando a tabela de requisições
			tabela();
			//Recebendo a requisição
			int num = scanf("%x", &requisicao);
			while(num != 1){
				int num = scanf("%x", &requisicao);
			}
			
			//juntando e convertendo para string 
			sprintf(dados.bufferRxTx, "%c%c", 0x41,requisicao);

			//Requisições válidas
			switch (requisicao) {
			case 0x00:
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
			case 0x10:
				break;
			
			default:
				printf("\x1b[31mRequisição inválida, por favor escolha uma requisição válida da próxima vez.\x1b[0m\n");
				break;
			}

			/*Escrevendo na prota serial*/
			escreve_Porta_Serial(dados.arquivioSerial, dados.bufferRxTx, dados.tam);

			/* Lendo da porta serial */
			ler_Porta_Serial(dados.bufferRxTx, dados.arquivoSerial, dados.tam);

			/*Fazendo casting da resposta para hexadecimal para usar no switch abaixo*/
			unsigned int resposta = (unsigned int) dados.bufferRxTx[0];

			switch(resposta){
				case 0x1F:
					printf("\x1b[31mSensor com problema.\x1b[0m");
					sleep(5);
					break;
				case 0x07:
					printf("Sensor funcionando normalmente."); 
					sleep(5);
					break;
				case 0x08:
					printf("\nMedida de umidade: %02d %% RH.\n",dados.bufferRxTx[1]); 
					sleep(5);
					break;
				case 0x09:
					printf("\nMedida de temperatura: %02d °C.\n",dados.bufferRxTx[1]); 
					sleep(5);
					break;
				case 0x0A:
					printf("Confirmação de desativação de sensoriamento contínuo de temperatura."); 
					sleep(5);
					break;
				case 0x0B:
					printf("Confirmação de desativação de sensoriamento contínuo  de umidade."); 
					sleep(5);
					break;
				case 0x11:
					printf("Confirmação de recebimento da requisição."); 
					sleep(5);
					break;				
				case 0x0D:
					// Cria a thread de sensoriamento contínuo de umidade e passa os dados como argumento
					if (pthread_create(&thread, NULL, sensoriamento_Temperatura, &dados) != 0) {
						fprintf(stderr, "\x1b[31mErro ao criar a thread.\x1b[0m\n");
						return 1;
					}

					printf("Pressione Enter para parar a contagem.\n");
					getchar(); // Aguarda a entrada do usuário

					// Define a variável 'parar' como verdadeira para encerrar a thread de sensoriamento contínuo de temperatura
					data.parar = 1;
					
					sleep(5);

					//Manda a requisição de desligamento do sensoriamento contínuo de temperatura
					sprintf(dados.bufferRxTx, "%c%c", 0x41, 0x05);
					escreve_Porta_Serial(dados.arquivoSerial, dados.bufferRxTx, dados.tam);
					break;
				case 0x0E:
					// Cria a thread de sensoriamento contínuo de temperatura e passa os dados como argumento
					if (pthread_create(&thread, NULL, sensoriamento_Umidade, &dados) != 0) {
						fprintf(stderr, "\x1b[31mErro ao criar a thread.\x1b[0m\n");
						return 1;
					}

					printf("Pressione Enter para parar a contagem.\n");
					getchar(); // Aguarda a entrada do usuário

					// Define a variável 'parar' como verdadeira para encerrar a thread de sensoriamento contínuo de umidade
					data.parar = 1;
					
					sleep(5);

					//Manda a requisição de desligamento do sensoriamento contínuo de umidade
					sprintf(dados.bufferRxTx, "%c%c", 0x41, 0x06);
					escreve_Porta_Serial(dados.arquivoSerial, dados.bufferRxTx, dados.tam);
					break;
				case 0x0F:
					printf("\x1b[31mComando inválido.\x1b[0m"); 
					sleep(5);
					break;
				case 0xFF:
					printf("\x1b[31mComando inválido devido a ativação do sensoriamento contínuo.\x1b[0m"); 
					sleep(5);
					break;
				case 0xAA:
					printf("\x1b[31mComando inválido pois o sensoriamento contínuo não foi ativado.\x1b[0m"); 
					sleep(5);
					break;
				case 0xAB:
					printf("\x1b[31mErro na máquina de estados.\x1b[0m"); 
					sleep(5);
					break;	
				default:
					printf("\x1b[31mResposta desconhecida.\x1b[0m\033[0m\n"); 
					sleep(5);
					break;					
			}

		}
		
		close(dados.arquivoSerial);
	return 0;
}

void tabela(){

	 printf("\033[32m------------------------------------------------------------------------------\n");
    printf("|                                   Tabela                                   |\n");
    printf("------------------------------------------------------------------------------\n");
    printf("|                                                                            |\n");
    printf("| 0x00: Situação atual do sensor.                                            |\n");
    printf("| 0x01: Medida de temperatura atual.                                         |\n");
    printf("| 0x02: Medida de umidade atual.                                             |\n");
    printf("| 0x03: Ativa sensoriamento contínuo de temperatura.                         |\n");
    printf("| 0x04: Ativa sensoriamento contínuo de umidade.                             |\n");
    printf("| 0x05: Desativa sensoriamento contínuo de temperatura.                      |\n");
    printf("| 0x06: Desativa sensoriamento contínuo  de umidade.                         |\n");
    printf("| 0x10: Envia solicitação para requisição (start).                           |\n");
    printf("------------------------------------------------------------------------------\n");

}

void ler_Porta_Serial( unsigned bufferRxTx, int arquivoSerial, int tam){
	memset(bufferRxTx, 0, 255);
	tam = read(arquivoSerial, bufferRxTx, 255);
	printf("Recebeu %d bytes\n", tam);
	printf("Recebeu string: %s\n", bufferRxTx);
}

void escreve_Porta_Serial(int arquivoSerial, unsigned char bufferRxTx, int tam){
			dados.tam = strlen(dados.bufferRxTx);
			dados.tam = write(dados.arquivoSerial, dados.bufferRxTx, dados.tam);
			printf("Escreveu %d bytes em UART\n", dados.tam);
			printf("Você tem 2s para me enviar alguns dados de entrada...\n");

			sleep(2);
}