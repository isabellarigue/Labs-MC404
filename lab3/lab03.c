int read(int __fd, const void *__buf, int __n){
  int bytes;
  __asm__ __volatile__(
    "mv a0, %1           # file descriptor\n"
    "mv a1, %2           # buffer \n"
    "mv a2, %3           # size \n"
    "li a7, 63           # syscall read (63) \n"
    "ecall \n"
    "mv %0, a0"
    : "=r"(bytes)  // Output list
    :"r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
  return bytes;
}
 
void write(int __fd, const void *__buf, int __n){
  __asm__ __volatile__(
    "mv a0, %0           # file descriptor\n"
    "mv a1, %1           # buffer \n"
    "mv a2, %2           # size \n"
    "li a7, 64           # syscall write (64) \n"
    "ecall"
    :   // Output list
    :"r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
}


unsigned long int potencia(int numero, int potencia) {
  unsigned long int resultado = 1; //numero elevado a zero
  for(int i = 1; i <= potencia; i++) {
    resultado *= numero;
  }
  return resultado;
}

int converteDecimalBinario(int num, int binario[35]) { //decimal positivo para binario
    int resto, k=0, i=0, numero, exp=0;
    int binario_invertido[35];
    while(num > 0) {
        resto = num % 2;
        num /= 2;
        binario_invertido[i] = resto;
        i++;
    }
    for(int j = i - 1; j >= 0; j--) {
        binario[k] = binario_invertido[j];
        k++;
    }
    return k-1; //tamanho do binario
}

int converteDecimalHexadecimal(int num, char hexadecimal[35]) {
    int resto, k=2, i=0;
    char restoChar;
    char hexadecimal_invertido[35];
    while(num > 0) {
        resto = num % 16;
        num /= 16;
        if(resto > 9) {
          restoChar = (char)(resto + 87); // letra
        } else {
          restoChar = (char)(resto + 48); //numero
        }
        hexadecimal_invertido[i] = restoChar;
        i++;
    }
    hexadecimal[0] = '0';
    hexadecimal[1] = 'x';
    for(int j = i - 1; j >= 0; j--) {
        hexadecimal[k] = hexadecimal_invertido[j];
        k++;
    } 
    hexadecimal[k] = '\n';
    return k-1;
}

int trocaEndianess(char hexadecimal[35], int tam, char trocado[35]) {
  int contador=0, i, j=0;
  trocado[0] = '0';
  trocado[1] = 'x';
  for(i = 2; (tam - j - 1) > 1; i += 2) {
    trocado[i] = hexadecimal[tam - j - 1];
    trocado[i + 1] = hexadecimal[tam - j];
    contador++; 
    j += 2;
  }
  if(((tam + 1) % 2) != 0) { //impar
    trocado[i] = '0';
    trocado[i + 1] = hexadecimal[tam - j];  
    trocado[i + 2] = '0'; 
    trocado[i + 3] = '0';  
  } else if(contador <= 3) {
    trocado[i] = '0';
    trocado[i + 1] = '0';
    if(contador == 1) {
      trocado[i + 2] = '0';
      trocado[i + 3] = '0';
      trocado[i + 4] = '0';
      trocado[i + 5] = '0';
    }     
  }
  trocado[10] = '\n';
  return 9; //sempre tem essa quantidade
}

unsigned long int converteHexadecimalDecimal(char str[35], int n) { 
  int exp=0, digito;
  unsigned long int numero=0;
  for(int i = n; i != 1; i--) {
    digito = (int)str[i];
    if(digito >= 97 && digito <= 102) { //letras minusculas
      digito -= 87;
    } else if(digito >= 65 && digito <= 70) { //letras maiusculas
      digito -= 55;
    } else { //numero
      digito -= 48;
    }
    numero += (digito * potencia(16, exp));
    exp++;
  } 
  return numero;
}

unsigned long int converteBinarioDecimal(int binario[35], int tam) {
  int exp=0, digito, i;
  unsigned long int numero=0;
  for(i = tam; i >= 0; i--) {
    digito = binario[i];
    numero += (digito * potencia(2, exp));
    exp++;
  }
  return numero; 
}

void colocaPrefixo(char string[35], char nova_string[35], int tam) {
  int k = 0, k_inicial = 0;
  while(string[k] == '0') { //retirando zeros a esquerda
    k++;
  }
  k_inicial = k;
  for(int i = 2; k <= tam; i++) {
    nova_string[i] = string[k];
    k++;
  }
  nova_string[0] = '0';
  nova_string[1] = 'b';
  nova_string[tam + 3 - k_inicial] = '\n'; 
}

void tiraSinal(char numero[35], char copia[35]) {
  int i;
  for(i = 0; numero[i] != '\n'; i++) {
    copia[i] = numero[i];
    numero[i] = numero[i + 1];
  }
  copia[i] = numero[i];
  copia[i+1] = '\n';
  numero[i] = '\n';
}

int complementoDeDois(int binario[35], int tam, int complemento[35]) {
  int exp=0;
  for(int j = 0; j < 35; j++) {
    complemento[j] = 1; //garantindo os 35 bits
  }
  for(int i = 0; i <= tam; i++) {
    if(binario[i] == 1)
      complemento[31 - tam + i] = 0;
    else 
      complemento[31 - tam + i] = 1;
  }
  if(complemento[31] == 0) 
    complemento[31] = 1; //somando 1
  
  else {
    int k = 0;
      while(complemento[31 - k] == 1) {
        complemento[31 - k] = 0;
        k++;
      }
      complemento[31 - k] = 1;
  }
  return 31;
}

int converteParaInt(char str[35], int tipo, int n) {
    int digito, numero=0, exp=0, teste;
    for(int i = n; i >= 0; i--) {
        digito = (int)str[i] - 48;
        teste = potencia(10, exp);
        numero += (digito * potencia(10, exp));
        exp++;
    }
    return numero;
}

int retornaTipo(char str[35]) { //0 para hexadecimal, 1 para decimal positivo, 2 para decimal negativo, 3 para hexadecimal negativo
    int tipo;
    if(str[0] == '0' && str[1] == 'x') {
        tipo = 0; //hexadecimal positivo
        if(str[2] == '8' || str[2] == '9' || str[2] == 'a' || str[2] == 'b' || str[2] == 'c' || str[2] == 'd' || str[2] == 'e' || str[2] == 'f' || str[2] == 'A' || str[2] == 'B' || str[2] == 'C' || str[2] == 'D' || str[2] == 'E' || str[2] == 'F')
          tipo = 3; //hexadecimal negativo
    } else {
        if(str[0] == '-')
            tipo = 2;
        else
            tipo = 1;
    }
    return tipo;
}

void listaIntParaChar(int inteiros[35], char caracteres[35], int tam) {
  for(int i = 0; i <= tam; i++) {
    caracteres[i] = (char)(inteiros[i] + 48);
  }
  caracteres[tam + 1] = '\n';
}

void intParaChar(unsigned long int numero, char string[35], int tam) {
  for(int i = tam; i >= 0; i--) {
    string[i] = (char)((numero % 10) + 48);
    numero /= 10;
  }
  string[tam + 1] = '\n';
}

void intParaCharNegativo(unsigned long int numero, char string[35], int tam) {
  for(int i = tam + 1; i > 0; i--) {
    string[i] = (char)((numero % 10) + 48);
    numero /= 10;
  }
  string[0] = '-';
  string[tam + 2] = '\n';
}

int tamanhoNumero(unsigned long int numero) {
  int digitos = 0;
  if(numero == 0)
    return 1;
  while(numero != 0) {
    digitos += 1;
    numero /= 10;
  }
  return digitos;
}

int converteBinarioHexadecimal(int binario[35], char hexadecimal[35], int tam_binario) {
  int tamanho = ((tam_binario + 1) / 4) + 1;
  int j = tamanho;
  for(int i = tam_binario; i >= 0; i-=4) {
    if(binario[i] == 0 && binario[i - 1] == 0 && binario[i - 2] == 0 && binario[i - 3] == 0)
      hexadecimal[j] = '0';
    else if(binario[i] == 1 && binario[i - 1] == 0 && binario[i - 2] == 0 && binario[i - 3] == 0)
      hexadecimal[j] = '1';
    else if(binario[i] == 0 && binario[i - 1] == 1 && binario[i - 2] == 0 && binario[i - 3] == 0)
      hexadecimal[j] = '2';
    else if(binario[i] == 1 && binario[i - 1] == 1 && binario[i - 2] == 0 && binario[i - 3] == 0)
      hexadecimal[j] = '3';
    else if(binario[i] == 0 && binario[i - 1] == 0 && binario[i - 2] == 1 && binario[i - 3] == 0)
      hexadecimal[j] = '4';
    else if(binario[i] == 1 && binario[i - 1] == 0 && binario[i - 2] == 1 && binario[i - 3] == 0)
      hexadecimal[j] = '5';
    else if(binario[i] == 0 && binario[i - 1] == 1 && binario[i - 2] == 1 && binario[i - 3] == 0)
      hexadecimal[j] = '6';
    else if(binario[i] == 1 && binario[i - 1] == 1 && binario[i - 2] == 1 && binario[i - 3] == 0)
      hexadecimal[j] = '7';
    else if(binario[i] == 0 && binario[i - 1] == 0 && binario[i - 2] == 0 && binario[i - 3] == 1)
      hexadecimal[j] = '8';
    else if(binario[i] == 1 && binario[i - 1] == 0 && binario[i - 2] == 0 && binario[i - 3] == 1)
      hexadecimal[j] = '9';
    else if(binario[i] == 0 && binario[i - 1] == 1 && binario[i - 2] == 0 && binario[i - 3] == 1)
      hexadecimal[j] = 'a';
    else if(binario[i] == 1 && binario[i - 1] == 1 && binario[i - 2] == 0 && binario[i - 3] == 1)
      hexadecimal[j] = 'b';
    else if(binario[i] == 0 && binario[i - 1] == 0 && binario[i - 2] == 1 && binario[i - 3] == 1)
      hexadecimal[j] = 'c';
    else if(binario[i] == 1 && binario[i - 1] == 0 && binario[i - 2] == 1 && binario[i - 3] == 1)
      hexadecimal[j] = 'd';
    else if(binario[i] == 0 && binario[i - 1] == 1 && binario[i - 2] == 1 && binario[i - 3] == 1)
      hexadecimal[j] = 'e';
    else if(binario[i] == 1 && binario[i - 1] == 1 && binario[i - 2] == 1 && binario[i - 3] == 1)
      hexadecimal[j] = 'f';
    j--;
  }
  hexadecimal[j] = 'x';
  hexadecimal[j-1] = '0';
  hexadecimal[tamanho + 1] = '\n';
  return tamanho;
}

int converteHexadecimalBinario(int binario[35], char hexadecimal[35], int tam_hexadecimal) {
  int k = ((tam_hexadecimal - 1) * 4) - 1;
  for(int i = tam_hexadecimal; i > 1; i--) {
    if(hexadecimal[i] == '0') {
      binario[k - 3] = 0;
      binario[k - 2] = 0;
      binario[k - 1] = 0;
      binario[k] = 0;
    } else if(hexadecimal[i] == '1') {
      binario[k - 3] = 0;
      binario[k - 2] = 0;
      binario[k - 1] = 0;
      binario[k] = 1;
    } else if(hexadecimal[i] == '2') {
      binario[k - 3] = 0;
      binario[k - 2] = 0;
      binario[k - 1] = 1;
      binario[k] = 0;
    } else if(hexadecimal[i] == '3') {
      binario[k - 3] = 0;
      binario[k - 2] = 0;
      binario[k - 1] = 1;
      binario[k] = 1;
    } else if(hexadecimal[i] == '4') {
      binario[k - 3] = 0;
      binario[k - 2] = 1;
      binario[k - 1] = 0;
      binario[k] = 0;
    } else if(hexadecimal[i] == '5') {
      binario[k - 3] = 0;
      binario[k - 2] = 1;
      binario[k - 1] = 0;
      binario[k] = 1;
    } else if(hexadecimal[i] == '6') {
      binario[k - 3] = 0;
      binario[k - 2] = 1;
      binario[k - 1] = 1;
      binario[k] = 0;
    } else if(hexadecimal[i] == '7') {
      binario[k - 3] = 0;
      binario[k - 2] = 1;
      binario[k - 1] = 1;
      binario[k] = 1;
    } else if(hexadecimal[i] == '8') {
      binario[k - 3] = 1;
      binario[k - 2] = 0;
      binario[k - 1] = 0;
      binario[k] = 0;
    } else if(hexadecimal[i] == '9') {
      binario[k - 3] = 1;
      binario[k - 2] = 0;
      binario[k - 1] = 0;
      binario[k] = 1;
    } else if(hexadecimal[i] == 'a' || hexadecimal[i] == 'A') {
      binario[k - 3] = 1;
      binario[k - 2] = 0;
      binario[k - 1] = 1;
      binario[k] = 0;
    } else if(hexadecimal[i] == 'b' || hexadecimal[i] == 'B') {
      binario[k - 3] = 1;
      binario[k - 2] = 0;
      binario[k - 1] = 1;
      binario[k] = 1;
    } else if(hexadecimal[i] == 'c' || hexadecimal[i] == 'C') {
      binario[k - 3] = 1;
      binario[k - 2] = 1;
      binario[k - 1] = 0;
      binario[k] = 0;
    } else if(hexadecimal[i] == 'd' || hexadecimal[i] == 'D') {
      binario[k - 3] = 1;
      binario[k - 2] = 1;
      binario[k - 1] = 0;
      binario[k] = 1;
    } else if(hexadecimal[i] == 'e' || hexadecimal[i] == 'E') {
      binario[k - 3] = 1;
      binario[k - 2] = 1;
      binario[k - 1] = 1;
      binario[k] = 0;
    } else if(hexadecimal[i] == 'f' || hexadecimal[i] == 'F') {
      binario[k - 3] = 1;
      binario[k - 2] = 1;
      binario[k - 1] = 1;
      binario[k] = 1;
    }
    k -= 4;
  }
  return ((tam_hexadecimal - 1) * 4)-1;
}

int tamanhoString(char string[35]) {
  int tamanho = 0;
  for(int i = 0; string[i] != '\n'; i++) {
    tamanho++;
  }
  return tamanho;
}

int main()
{
  char str[20], str_copia[35], hexadecimal[35], trocado[35], binario_char[35], binario_char2[35], decimal_char[35], decimal_char2[35];
  int binario[35], tam_decimal, tam_string, tam_binario, tam_complemento, num_binario, n, decimal, tam_hexadecimal, tam_trocado;
  unsigned long int num;

  n = read(0, str, 20);
  tam_string = tamanhoString(str) - 1;
  int tipo = retornaTipo(str); 
  if(tipo == 2) {
    tiraSinal(str, str_copia); 
    tam_string -= 1; //desconsiderando o sinal
  }
  if(tipo == 1 || tipo == 2)
    num = converteParaInt(str, tipo, tam_string);

  if(tipo == 1) { //decimal positivo
    tam_binario = converteDecimalBinario(num, binario);
    listaIntParaChar(binario, binario_char, tam_binario);
    colocaPrefixo(binario_char, binario_char2, tam_binario);
    write(1, binario_char2, 35);

    write(1, str, 20);

    decimal = converteBinarioDecimal(binario, tam_binario);
    tam_hexadecimal = converteDecimalHexadecimal(decimal, hexadecimal);
    write(1, hexadecimal, 20);

    tam_trocado = trocaEndianess(hexadecimal, tam_hexadecimal, trocado);
    num = converteHexadecimalDecimal(trocado, tam_trocado);
    intParaChar(num, decimal_char , tamanhoNumero(num) - 1);
    write(1, decimal_char, 20);

  } else if(tipo == 2) { //decimal negativo
    tam_binario = converteDecimalBinario(num, binario);
    int complemento[35];
    tam_complemento = complementoDeDois(binario, tam_binario, complemento);
    listaIntParaChar(complemento, binario_char, tam_complemento);
    colocaPrefixo(binario_char, binario_char2, tam_complemento);
    write(1, binario_char2, 35);

    write(1, str_copia, 20);

    tam_hexadecimal = converteBinarioHexadecimal(complemento, hexadecimal, tam_complemento);
    write(1, hexadecimal, 20);

    tam_trocado = trocaEndianess(hexadecimal, tam_hexadecimal, trocado);
    num = converteHexadecimalDecimal(trocado, tam_trocado);
    intParaChar(num, decimal_char, tamanhoNumero(num) - 1);
    write(1, decimal_char, 20);

  } else { //hexadecimal
    tam_binario = converteHexadecimalBinario(binario, str, tam_string);
    listaIntParaChar(binario, binario_char, tam_binario);
    colocaPrefixo(binario_char, binario_char2, tam_binario);
    write(1, binario_char2, 35);

    if(tipo == 3) { //hexadecimal negativo
      int complemento[35];
      tam_complemento = complementoDeDois(binario, tam_binario, complemento);
      num = converteBinarioDecimal(complemento, tam_complemento);
    } else {
      num = converteBinarioDecimal(binario, tam_binario);
    }
    tam_decimal = tamanhoNumero(num) - 1;
    if(tipo == 0) {
      intParaChar(num, decimal_char, tam_decimal);
      write(1, decimal_char, 20);
    } else {
      intParaCharNegativo(num, decimal_char, tam_decimal);
      write(1, decimal_char, 20);
    }

    write(1, str, 20);

    tam_trocado = trocaEndianess(str, tam_string, trocado);
    num = converteHexadecimalDecimal(trocado, tam_trocado);
    intParaChar(num, decimal_char2, tamanhoNumero(num) - 1);
    write(1, decimal_char2, 15);
  }

  return 0;
}
 
void _start(){
  main();
}
