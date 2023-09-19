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

/*
*Código que faz a configuração UART e envio dos dados pela porta serial ttyS0.
*/

struct ThreadData {
    int arquivoSerial;
    int tam;
    unsigned char *bufferRxTx;
    int parar;
};

//função que mostra as opções disponíveis para o leitor
void tabela();

void limparBufferEntrada();

//função para escrever na porta serial
void escrever_Porta_Serial(int, unsigned char[], int);

//função para ler da porta serial
void ler_Porta_Serial(int, unsigned char[], int);

//Thread para o Sensoriamento Contínuo de temperatura
void *sensoriamento_Temp(void *arg);

//Thread para o Sensoriamento Contínuo de umidade
void *sensoriamento_Umid(void *arg);

int main() {
		int arquivoSerial, tam;
		unsigned int requisicao;
		unsigned int endereco_sensor;
		unsigned char bufferRxTx[255]; 
		struct termios options; /* Configuração das portas seriais */

		arquivoSerial = open("/dev/ttyS0", O_RDWR | O_NDELAY | O_NOCTTY); //O endereço é por convenção a primeira porta serial disponível
		
		if (arquivoSerial < 0) { //Não conseguiu abrir o arquivo por algum motivo.
			perror("\x1b[31mErro ao abrir porta serial\x1b[0m");
			return -1;
		}
		
		/* Configurando a porta serial */
		options.c_cflag = B9600 | CS8 | CLOCAL | CREAD; //Baud: 9600, CS8: tamanho do envio de dados.
		options.c_iflag = IGNPAR;
		options.c_oflag = 0;
		options.c_lflag = 0;

		/* Aplicando as configurações */
		tcflush(arquivoSerial, TCIFLUSH); //Limpa o buffer do arquivoSerial
		tcsetattr(arquivoSerial, TCSANOW, &options); //Aplique agora, neste instante

		while(1){
			//Criando a thread
			pthread_t thread, thread1;
			//Criando a struct dos argumentos que vao no thread
			struct ThreadData data;
			data.arquivoSerial = arquivoSerial;
			data.bufferRxTx = bufferRxTx;
			data.tam = tam;
			data.parar = 0;
      
			//Chamando a tabela de requisições
			tabela();
			//Recebendo a requisição
			scanf("%d %d", &requisicao, &endereco_sensor);
			while(requisicao < 1 || requisicao > 5 || endereco_sensor < 1 || endereco_sensor > 32){
				printf("Escolha uma requisição e sensor valido!");
				scanf("%d %d", &requisicao, &endereco_sensor);
				system("clear");
			}

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
				default:
				break;
			}

			switch (endereco_sensor)
			{
			case 1:
				endereco_sensor = 0x01;
				break;
			default:
				printf("Esse sensor não está em funcionamento!");
				break;
			}
			
			limparBufferEntrada();
			//juntando e convertendo para string 
			sprintf(bufferRxTx, "%c%c", requisicao, endereco_sensor);

			//Requisições válidas
			switch (requisicao)
			{
			case 0x01:
				escrever_Porta_Serial(arquivoSerial, bufferRxTx, tam);
				break;
			case 0x02:
				escrever_Porta_Serial(arquivoSerial, bufferRxTx, tam);
				break;
			case 0x03:
				escrever_Porta_Serial(arquivoSerial, bufferRxTx, tam);
				break;
			case 0x04:
				escrever_Porta_Serial(arquivoSerial, bufferRxTx, tam);
				break;
			case 0x05:
				escrever_Porta_Serial(arquivoSerial, bufferRxTx, tam);
				break;
			default:
				printf("\x1b[31mRequisição inválida, por favor escolha uma requisição válida da próxima vez.\x1b[0m\n");
				break;
			}

			ler_Porta_Serial(arquivoSerial, bufferRxTx, tam);

			/*Fazendo casting da resposta para hexadecimal para usar no switch abaixo*/
			unsigned int resposta = (unsigned int) bufferRxTx[0];
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
					printf("\nMedida de umidade: %02d %% RH.\n",bufferRxTx[1]); 
					sleep(5);
					break;
				case 0x09:
					printf("\nMedida de temperatura: %02d °C.\n",bufferRxTx[1]); 
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
				case 0x0D:
					// Cria a thread de sensoriamento de temperatura e passa os dados como argumento
					if (pthread_create(&thread, NULL, sensoriamento_Temp, &data) != 0) {
						fprintf(stderr, "Erro ao criar a thread.\n");
						return 1;
					}

					printf("Pressione Enter para parar sair do Sensoriamento Contínuo.\n");
					getchar(); // Aguarda a entrada do usuário

					// Define a variável 'parar' como verdadeira para encerrar a thread de sensoriamento de temperatura
					data.parar = 1;
				
					// Aguarda a thread de sensoriamento de temperatura terminar
					if (pthread_join(thread, NULL) != 0) {
						fprintf(stderr, "Erro ao esperar pela thread.\n");
						return 1;
					}
				
					printf("Sensoriamento Contínuo encerrado.\n");
				
					//Envia a requisição para sair do sensoriamento contínuo de temperatura      
					memset(bufferRxTx, 0, 255);
					sprintf(bufferRxTx, "%c%c", 0x05,endereco_sensor);
					escrever_Porta_Serial(arquivoSerial, bufferRxTx, tam);
					limparBufferEntrada();
					sleep(1);
					break;
				case 0x0E:
					// Cria a thread de sensoriamento de umidade e passa os dados como argumento
					if (pthread_create(&thread1, NULL, sensoriamento_Umid, &data) != 0) {
						fprintf(stderr, "Erro ao criar a thread.\n");
						return 1;
					}
					
					printf("Pressione Enter para parar sair do Sensoriamento Contínuo.\n");
					getchar(); // Aguarda a entrada do usuário
				
					// Define a variável 'parar' como verdadeira para encerrar a thread de sensoriamento de umidade
					data.parar = 1;
				
					// Aguarda a thread de sensoriamento de umidade terminar
					if (pthread_join(thread1, NULL) != 0) {
						fprintf(stderr, "Erro ao esperar pela thread.\n");
						return 1;
					}
				
					printf("Sensoriamento Contínuo encerrado.\n");

					//Envia a requisição para sair do sensoriamento contínuo de umidade
					memset(bufferRxTx, 0, 255);
					sprintf(bufferRxTx, "%c%c", 0x06, endereco_sensor);
					escrever_Porta_Serial(arquivoSerial, bufferRxTx, tam);
					limparBufferEntrada();
					sleep(1);
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
					printf("\x1b[31mResposta desconhecida. - %X\x1b[0m\033[0m\n", bufferRxTx[0]); 
					sleep(5);
					break;					
			}

			system("clear");
		}
		
		close(arquivoSerial);
	return 0;
}

	//////////////////LEMBRAR DE PEDIR O ENDEREÇO!!!!!!!!!!!!!!!!!!!!!!!!!!! SÃO 32 POSICOES -> A PARTIR DO 0X01!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

void tabela(){
printf("\033[32m------------------------------------------------------------------------------------------------------\n");
    printf("|                Tabela Requisição                 |                Endereço Sensor                  |\n");
    printf("------------------------------------------------------------------------------------------------------\n");
    printf("|                                                  | DHT11 => 1: 0x01  9:  0x09  17: 0xAB  25: 0xBD  |\n");
    printf("| 1: Situação atual do sensor.                     |          2: 0x02  10: 0x0A  18: 0xAC  26: 0xBE  |\n");
    printf("| 2: Medida de temperatura atual.                  |          3: 0x03  11: 0x0B  19: 0xAD  27: 0xBF  |\n");
    printf("| 3: Medida de umidade atual.                      |          4: 0x04  12: 0x0C  20: 0xAE  28: 0xCA  |\n");
    printf("| 4: Ativa sensoriamento contínuo de temperatura.  |          5: 0x05  13: 0x0D  21: 0xAF  29: 0xCB  |\n");
    printf("| 5: Ativa sensoriamento contínuo de umidade.      |          6: 0x06  14: 0x0E  22: 0xBA  30: 0xCC  |\n");
    printf("|                                                  |          7: 0x07  15: 0x0F  23: 0xBB  31: 0xCD  |\n");
    printf("|                                                  |          8: 0x08  16: 0xAA  24: 0xBC  32: 0xCE  |\n");
    printf("|                                                  |                                                 |\n");
    printf("------------------------------------------------------------------------------------------------------\n");
}

void escrever_Porta_Serial(int arquivoSerial, unsigned char bufferRxTx[], int tam){
  tam = strlen(bufferRxTx);
  tam = write(arquivoSerial, bufferRxTx, tam);
  //printf("Escreveu %d bytes em UART\n", tam);
  printf("Você tem 3s para me enviar alguns dados de entrada...\n");
  sleep(3);
}

void ler_Porta_Serial(int arquivoSerial, unsigned char bufferRxTx[], int tam){
  memset(bufferRxTx, 0, 255);
  tam = read(arquivoSerial, bufferRxTx, 2);
  //printf("Recebeu %d bytes\n", tam);
  //printf("Recebeu a string: %s\n", bufferRxTx);
}

void *sensoriamento_Temp(void *arg){
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
