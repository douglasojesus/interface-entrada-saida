#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <termios.h>
#include <string.h>
#include <sys/time.h>
#include <sys/types.h>
#include <pthread.h>

/*
*Código que faz a configuração UART e envio dos dados pela porta serial ttyS0.
*/

//função que mostra as opções disponíveis para o leitor
void tabela();

//função para escrever na porta serial
void escrever_Porta_Serial(int, unsigned char[], int);

//função para ler da porta serial
void ler_Porta_Serial(int, unsigned char[], int);

//Thread para o Sensoriamento Contínuo de temperatura
void *sensoriamento_Temp(void *arg);

//Thread para o Sensoriamento Contínuo de umidade
void *sensoriamento_Umid(void *arg);

struct ThreadData {
    int arquivoSerial;
    int tam;
    unsigned char *bufferRxTx;
    int parar;
};

int main() {
		int arquivoSerial, tam;
		unsigned int requisicao;
		unsigned char bufferRxTx[255]; 
		struct termios options; /* Configuração das portas seriais */

		arquivoSerial = open("/dev/ttyS0", O_RDWR | O_NDELAY | O_NOCTTY); //O endereço é por convenção a primeira porta serial disponível
		
		if (arquivoSerial < 0) { //Não conseguiu abrir o arquivo por algum motivo.
			perror("Error opening serial port");
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
			int num = scanf("%x", &requisicao);
			while(num != 1){
				int num = scanf("%x", &requisicao);
			}
			
			//juntando e convertendo para string 
			sprintf(bufferRxTx, "%c%c", 0x41,requisicao);

			//Requisições válidas
			switch (requisicao)
			{
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

			escrever_Porta_Serial(arquivoSerial, bufferRxTx, tam);

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
				case 0x11:
					printf("Confirmação de recebimento da requisição."); 
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
      
          printf("Sensoriamento Contínuo encerrado.");
      
          //Envia a requisição para sair do sensoriamento contínuo de temperatura      
          sprintf(bufferRxTx, "%c%c", 0x41,0x05);
          escrever_Porta_Serial(arquivoSerial, bufferRxTx, tam);
					sleep(5);
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
      
          printf("Sensoriamento Contínuo encerrado.");
      
          //Envia a requisição para sair do sensoriamento contínuo de umidade
          sprintf(bufferRxTx, "%c%c", 0x41,0x06);
          escrever_Porta_Serial(arquivoSerial, bufferRxTx, tam);
					sleep(5);
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
		
		close(arquivoSerial);
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

void escrever_Porta_Serial(int arquivoSerial, unsigned char bufferRxTx[], int tam){
  tam = strlen(bufferRxTx);
  tam = write(arquivoSerial, bufferRxTx, tam);
  printf("Wrote %d bytes over UART\n", tam);

  printf("You have 2s to send me some input data...\n");
  sleep(2);
}

void ler_Porta_Serial(int arquivoSerial, unsigned char bufferRxTx[], int tam){
  memset(bufferRxTx, 0, 255);
  tam = read(arquivoSerial, bufferRxTx, 255);
  printf("Received %d bytes\n", tam);
  printf("Received string: %s\n", bufferRxTx);
}

void *sensoriamento_Temp(void *arg){
  struct ThreadData *data = (struct ThreadData *)arg;
  while (!data->parar) {
    ler_Porta_Serial(data->arquivoSerial, data->bufferRxTx, data->tam);
    printf("Temperatura atual: %d °C", data->bufferRxTx[1]);
    sleep(1); 
    }
    return NULL;
}

void *sensoriamento_Umid(void *arg){
  struct ThreadData *data = (struct ThreadData *)arg;
  while (!data->parar) {
    ler_Porta_Serial(data->arquivoSerial, data->bufferRxTx, data->tam);
    printf("Umidade atual: %d %% RH", data->bufferRxTx[1]);
    sleep(1); 
    }
    return NULL;
}