#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <termios.h>

/*
*Código que faz a configuração UART e envio dos dados pela porta serial ttyS0.
*/

int main() {
	int arquivoSerial, tam;
	char bufferRxTx[255]; 
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

	/* Escrevendo na porta serial */
	strcpy(bufferRxTx, "1P");
	tam = strlen(bufferRxTx);
	tam = write(arquivoSerial, bufferRxTx, tam);
	printf("Wrote %d bytes over UART\n", tam);

	printf("You have 2s to send me some input data...\n");
	sleep(2);

	/* Lendo da porta serial */
	memset(bufferRxTx, 0, 255);
	tam = read(arquivoSerial, bufferRxTx, 255);
	printf("Received %d bytes\n", tam);
	printf("Received string: %s\n", bufferRxTx);

	close(arquivoSerial);
	return 0;
}
