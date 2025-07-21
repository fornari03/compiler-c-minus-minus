# Projeto de Compilador Didático

Este é um projeto de um compilador para uma linguagem de programação simples e didática.
O compilador foi desenvolvido em C, utilizando as ferramentas Flex para a análise léxica e
Bison para a análise sintática. Ele traduz o código-fonte para um conjunto de instruções
de uma Máquina Virtual (VM) específica.

## Estrutura do Projeto
parser.y: Definição da gramática da linguagem (Bison).

scanner.l: Definição dos tokens da linguagem (Flex).

tradutor.c / geracode.c: Módulos em C para geração e tradução do código para a VM.

run_tests.sh: Script de shell que gera o menu de testes interativo.

Makefile: Orquestra a compilação e a execução dos testes.

teste_*.lang: Ficheiros de exemplo com código-fonte para o compilador


## Pré-requisitos

Para compilar e executar este projeto em um ambiente Linux (como Debian/Ubuntu),
você precisará das seguintes ferramentas:

* `build-essential` (que inclui `make` e o compilador C `gcc`)
* `flex`
* `bison`

Você pode instalar tudo com um único comando:
```bash
sudo apt-get update && sudo apt-get install build-essential flex bison


O Makefile está configurado para automatizar todo o processo de compilação.
Para gerar o executável meucompilador, execute o seguinte comando no terminal.

Como Compilar e Executar Passo a Passo:

	1 - Para Compilar: make;

	2 - Para Executar os Testes Interativos: make menu;
	    2.a) - Seguindo as instrucoes no menu teste.

	4 - Para Limpar o Executável e Ficheiros Gerados: make clean.