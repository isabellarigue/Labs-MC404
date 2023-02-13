#include <fcntl.h>
#include <unistd.h>

int potencia(int numero, int potencia) {
  int resultado = 1; //numero elevado a zero
  for(int i = 1; i <= potencia; i++) {
    resultado *= numero;
  }
  return resultado;
}

int converteDecimalHexadecimal(int num, char hexadecimal[30]) {
    int resto, k=0, i=0;
    char restoChar;
    char hexadecimal_invertido[30];
    if (num > 0) {
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
      for(int j = i - 1; j >= 0; j--) {
          hexadecimal[k] = hexadecimal_invertido[j];
          k++;
      } 
      if (k == 1) { // se for um digito, acrescenta um zero a esquerda
        hexadecimal[k] = hexadecimal[0];
        hexadecimal[0] = '0';
        k++;
      }
      hexadecimal[k] = '\0';
    } else { // se for zero
      hexadecimal[0] = '0';
      hexadecimal[1] = '0';
      hexadecimal[2] = '\0';
    }
    return k-1;
}

int converteHexadecimalDecimal(char str[30], int n) { 
  int exp=0, digito;
  int numero=0;
  for(int i = n; i >= 0; i--) {
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

void concatena(char string1[30], char string2[30], char string3[30], char string4[30]) {
  string1[2] = string2[0];
  string1[3] = string2[1];
  string1[4] = string3[0];
  string1[5] = string3[1];
  string1[6] = string4[0];
  string1[7] = string4[1];
  string1[8] = '\0';
}

void trocaEndianess(int aux1, char string1[30], char string2[30], char string3[30], char string4[30], unsigned char file_bytes[1000000]) { //cuidado tamanho file_bytes
  int aux;
  aux = file_bytes[aux1]; //da pra otimizar e ver quando é igual a 0, que nao precisa converter
  converteDecimalHexadecimal(aux, string4);
  aux = file_bytes[aux1 + 1];
  converteDecimalHexadecimal(aux, string3);
  aux = file_bytes[aux1 + 2];
  converteDecimalHexadecimal(aux, string2);
  aux = file_bytes[aux1 + 3];
  converteDecimalHexadecimal(aux, string1);
  concatena(string1, string2, string3, string4);  
}

void trocaEndianess2(int aux1, char string1[30], char string2[30], unsigned char file_bytes[1000000]) { //cuidado tamanho file_bytes
  int aux;
  aux = file_bytes[aux1]; //da pra otimizar e ver quando é igual a 0, que nao precisa converter
  converteDecimalHexadecimal(aux, string2);
  aux = file_bytes[aux1 + 1];
  converteDecimalHexadecimal(aux, string1);
  string1[2] = string2[0];
  string1[3] = string2[1];
  string1[4] = '\0';
}

void strcopy(char copia[30], char original[30]) {
  int i = 0;
  while(original[i] != '\0') {
    copia[i] = original[i];
    i++;
  }
  copia[i] = '\0';
}

void strcopy2(char copia[30], char *original) {
  int i = 0;
  while(original[i] != '\0') {
    copia[i] = original[i];
    i++;
  }
  copia[i] = '\0';
}

int strlen1(char string[30]) {
  int i = 0;
  while(string[i] != '\0') {
    i++;
  }
  return i;
}

int strcompare(char string1[30], char string2[30]) {
  int i = 0;
  while(string1[i] != '\0' && string2[i] != '\0') {
    if(string1[i] != string2[i]) {
      return 0;
    }
    i++;
  }
  if(string1[i] != string2[i]) {
    return 0;
  }
  return 1;
}

void concatena_d(char string1[30], char string2[30], char string3[30], char string4[30], char string5[30]) {
  int t = strlen1(string1);
  string1[t] = ':'; 
  string1[t + 1] = '\t';
  string1[t + 2] = string2[0];
  string1[t + 3] = string2[1];
  string1[t + 4] = '\t';
  string1[t + 5] = string3[0];
  string1[t + 6] = string3[1];
  string1[t + 7] = '\t';
  string1[t + 8] = string4[0];
  string1[t + 9] = string4[1];
  string1[t + 10] = '\t';
  string1[t + 11] = string5[0];
  string1[t + 12] = string5[1];
  string1[t + 13] = '\0';
}

void concatena_d2(char string1[30], char string2[30]) {
  string1[0] = string2[0];
  string1[1] = string2[1];
  string1[2] = string2[2];
  string1[3] = string2[3];
  string1[4] = string2[4];
  string1[5] = string2[5];
  string1[6] = string2[6];
  string1[7] = string2[7];
  string1[8] = '\t';
  string1[9] = '<';
  string1[10] = '\0'; 
}

void retiraZerosEsquerda(char string[30]) {
  int i = 0;
  while(string[i] == '0') {
    i++;
  }
  if(i > 0) {
    int j = 0;
    while(string[i] != '\0') {
      string[j] = string[i];
      i++;
      j++;
    }
    string[j] = '\0';
  }
}


int main(int argc, char *argv[]) {
  char letraTipo[30]; 
  //strcopy(letraTipo, "-d\0");
  strcopy2(letraTipo, argv[1]);
  char nomeArquivo[30];
  //strcopy(nomeArquivo, "test-03.x"); 
  strcopy2(nomeArquivo, argv[2]); 


  char vma[1000][30], size[1000][30], nome[1000][30], size_sym[1000][30], type_sym[1000][30], nomes_sym[1000][30], value_sym[1000][30], secao_sym[1000][30]; 
  int file_descriptor = open(nomeArquivo, O_RDONLY); 
  if (file_descriptor == -1) 
    return -1;
  unsigned char file_bytes[1000000]; 
  ssize_t file_size = read(file_descriptor, file_bytes, 10000);

  char string1[30], string2[30], string3[30], string4[30], string5[30];
  int aux1, indiceSecao, indiceShstrtab, endereco, offset1, header1, e_shstrndx, idx_symtab, ultima, idx_text;
  trocaEndianess(32, string1, string2, string3, string4, file_bytes); //vendo o e_shoff

  string2[0] = string1[5]; string2[1] = string1[6]; string2[2] = string1[7];
  aux1 = converteHexadecimalDecimal(string2, 2);
  indiceSecao = aux1;
  aux1 += 40; //primeiro numero da primeira seção
  ultima = aux1;
  int num_secoes = (file_size - aux1)/40; //40 eh o tamanho de cada seção

  strcopy(vma[0], "00000000\0aaaaaaaaaaaaaaaaaaaa"); 
  strcopy(size[0], "00000000\0aaaaaaaaaaaaaaaaaaaa");
  strcopy(nome[0], "00000000\0aaaaaaaaaaaaaaaaaaaa");

  for(int k = 1; k <= num_secoes; k++) { //para fazer as coisas do -h
    trocaEndianess(aux1, string1, string2, string3, string4, file_bytes);
    offset1 = converteHexadecimalDecimal(string1, 7);
    aux1 += 12; //vma seção
    trocaEndianess(aux1, string1, string2, string3, string4, file_bytes);
    strcopy(vma[k], string1);

    aux1 += 8; //primeiro numero do size da seção
    trocaEndianess(aux1, string1, string2, string3, string4, file_bytes);
    strcopy(size[k], string1);

    e_shstrndx = 50; //indice da seção de nomes
    trocaEndianess2(e_shstrndx, string1, string2, file_bytes);
    e_shstrndx = converteHexadecimalDecimal(string1, 3);
    indiceShstrtab = indiceSecao + (e_shstrndx * 40); 
    endereco = indiceShstrtab + 16; //primeiro numero do endereco da string table
    trocaEndianess(endereco, string1, string2, string3, string4, file_bytes);
    endereco = converteHexadecimalDecimal(string1, 7);
    header1 = offset1 + endereco; //primeiro numero do header da secao
    int i;
    for(i = header1; file_bytes[i] != 0; i++) {
      int decimal = file_bytes[i];
      nome[k][i - header1] = (char)decimal; 
    }
    nome[k][i - header1] = '\0';  
    if(strcompare(nome[k], ".symtab\0aaaaaaaaaaaaaaaaaaaaa")) {
      idx_symtab = k;
    } else if(strcompare(nome[k], ".text\0aaaaaaaaaaaaaaaaaaaaaaa")) {
      idx_text = k;
    }
    aux1 = ultima + 40; //primeiro numero da proxima seção 
    ultima = aux1;
  }

  int num;
  if(strcompare(letraTipo, "-h\0aaaaaaaaaaaaaaaaaaaaaaaaaa")) {
    write(1, "\n", 1);
    num = strlen1(nomeArquivo);
    write(1, nomeArquivo, num);
    write(1, ": file format elf32-littleriscv\n\n", 33);
    write(1, "Sections:\n", 10);
    write(1, "Idx Name Size VMA\n", 18);
    write(1, "0 00000000 00000000\n", 20);
    for(int k = 1; k <= num_secoes; k++) {
      char auxNum[30];
      auxNum[0] = (char)(k + 48);
      auxNum[1] = '\0';
      num = strlen1(auxNum);
      write(1, auxNum, num);
      write(1, "\t", 1);
      num = strlen1(nome[k]);
      write(1, nome[k], num);
      write(1, "\t", 1);
      num = strlen1(size[k]);
      write(1, size[k], num);
      write(1, "\t", 1);
      num = strlen1(vma[k]);
      write(1, vma[k], num);
      write(1, "\n", 1);
    }
    write(1, "\n", 1);
    return 0;
  }

  int offset_symtab = indiceSecao + (idx_symtab * 40) + 16;
  trocaEndianess(offset_symtab, string1, string2, string3, string4, file_bytes);
  offset_symtab = converteHexadecimalDecimal(string1, 7); //indice do primeiro numero da seção symtab
  int size_symtab = converteHexadecimalDecimal(size[idx_symtab], 7); //tamanho da seção symtab
  int qtd_simbolos = (size_symtab/16)-1; //16 eh o tamanho de cada simbolo
  offset_symtab += 16; //primeira linha é nula
  int i_nome = header1 + 9; //indice do primeiro numero do nome do simbolo
  for(int j = 0; j < qtd_simbolos; j++) {
    trocaEndianess(offset_symtab, string1, string2, string3, string4, file_bytes);
    int c;
    for(c = i_nome; file_bytes[c] != 0; c++) {
      int decimal = file_bytes[c];
      nomes_sym[j][c - i_nome] = (char)decimal; 
    }
    nomes_sym[j][c - i_nome] = '\0';  
    i_nome += ((c - i_nome) + 1);

    offset_symtab += 4; 
    trocaEndianess(offset_symtab, string1, string2, string3, string4, file_bytes);
    strcopy(value_sym[j], string1);
    
    offset_symtab += 4;
    trocaEndianess(offset_symtab, string1, string2, string3, string4, file_bytes);
    strcopy(size_sym[j], string1);

    offset_symtab += 4; //primeiro numero do st_info
    int st_info = file_bytes[offset_symtab];
    if((st_info >> 4) == 0 )
      strcopy(type_sym[j], "l\0aaaaaaaaaaaaaaaaaaaaaaaaaaa");
    else 
      strcopy(type_sym[j], "g\0aaaaaaaaaaaaaaaaaaaaaaaaaaa");

    offset_symtab += 2; //primeiro numero do st_shndx
    trocaEndianess2(offset_symtab, string1, string2, file_bytes);
    int idx = converteHexadecimalDecimal(string1, 3);
    if(idx <= num_secoes && idx > 0) {
      strcopy(secao_sym[j], nome[idx]);
    } else {
      strcopy(secao_sym[j], "*ABS*\0aaaaaaaaaaaaaaaaaaaaaaa");
    }

    offset_symtab += 2; 
  }

  if(strcompare(letraTipo, "-t\0aaaaaaaaaaaaaaaaaaaaaaaaaa")) {
    write(1, "\n", 1);
    num = strlen1(nomeArquivo);
    write(1, nomeArquivo, num);
    write(1, ": file format elf32-littleriscv\n\n", 33);
    write(1, "SYMBOL TABLE:\n", 14);
    for(int k = 0; k < qtd_simbolos; k++) {
      num = strlen1(value_sym[k]);
      write(1, value_sym[k], num);
      write(1, " ", 1);
      num = strlen1(type_sym[k]);
      write(1, type_sym[k], num);
      write(1, " ", 1);
      num = strlen1(secao_sym[k]);
      write(1, secao_sym[k], num);
      write(1, " ", 1);
      num = strlen1(size_sym[k]);
      write(1, size_sym[k], num);
      write(1, " ", 1);
      num = strlen1(nomes_sym[k]);
      write(1, nomes_sym[k], num);
      write(1, "\n", 1);
    }
    return 0;
  }

  int endereco_text = indiceSecao + (idx_text * 40) + 16; 
  trocaEndianess(endereco_text, string1, string2, string3, string4, file_bytes);
  endereco_text = converteHexadecimalDecimal(string1, 7); //indice do primeiro numero da seção text
  int qtd_instrucoes = converteHexadecimalDecimal(size[1], 7)/4; 
  char valueStr[30];
  strcopy(valueStr, vma[idx_text]);
  char vma_text[30];
  strcopy(vma_text, valueStr);
  retiraZerosEsquerda(valueStr);
  int value;

  write(1, "\n", 1);
  num = strlen1(nomeArquivo);
  write(1, nomeArquivo, num);
  write(1, ": file format elf32-littleriscv\n\n", 33);
  write(1, "\n", 1);
  write(1, "Disassembly of section .text:\n\n", 31);
  num = strlen1(vma_text);
  write(1, vma_text, num);
  write(1, " ", 1);

  for(int j = 0; j < qtd_simbolos; j++) {
    char strCopia[30];
    strcopy(strCopia, value_sym[j]);
    retiraZerosEsquerda(strCopia);
    if(strcompare(strCopia, valueStr)) {
        char nomeRotulo[30];
        strcopy(nomeRotulo, nomes_sym[j]);
        num = strlen1(nomeRotulo);
        write(1, "<", 1);
        write(1, nomeRotulo, num);
        write(1, ">:\n", 2);
        write(1, "\n", 1);
    }
  }  

  for(int k = 0; k < qtd_instrucoes; k++) {
    strcopy(string1, valueStr);
    int digito = file_bytes[endereco_text];
    converteDecimalHexadecimal(digito, string2); 
    digito = file_bytes[endereco_text + 1];
    converteDecimalHexadecimal(digito, string3);
    digito = file_bytes[endereco_text + 2];
    converteDecimalHexadecimal(digito, string4);
    digito = file_bytes[endereco_text + 3];
    converteDecimalHexadecimal(digito, string5);
    concatena_d(string1, string2, string3, string4, string5);
    num = strlen1(string1);
    write(1, string1, num);
    write(1, "\n", 1);

    value = converteHexadecimalDecimal(valueStr, 4);
    value += 4;
    endereco_text += 4;
    converteDecimalHexadecimal(value, valueStr);
    for(int j = 0; j < qtd_simbolos; j++) {
      char strCopia[30];
      strcopy(strCopia, value_sym[j]);
      retiraZerosEsquerda(strCopia);
      if(strcompare(strCopia, valueStr)) {
          char nomeRotulo[30];
          strcopy(nomeRotulo, nomes_sym[j]);
          concatena_d2(string1, value_sym[j]);
          write(1, "\n", 1);
          num = strlen1(string1);
          write(1, string1, num);
          num = strlen1(nomeRotulo);
          write(1, nomeRotulo, num);
          write(1, ">:\n", 2);
          write(1, "\n", 1);
      }
    }  
    
  }

  return 0;
}
