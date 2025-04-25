# Diretórios
SCANNER_DIR = src/scanner_module
BUILD_DIR = build

# Arquivos
LEX_FILE = $(SCANNER_DIR)/scanner.l
C_FILE = $(BUILD_DIR)/lex.yy.c
EXEC = $(BUILD_DIR)/scanner

# Regra padrão
all: $(EXEC)

# Compila lex.yy.c para gerar o executável
$(EXEC): $(C_FILE)
	gcc $(C_FILE) -o $(EXEC) -lfl

# Gera lex.yy.c a partir de scanner.l
$(C_FILE): $(LEX_FILE)
	mkdir -p $(BUILD_DIR)
	cd $(SCANNER_DIR) && flex -o ../../$(C_FILE) scanner.l

# Limpa os arquivos gerados
clean:
	rm -rf $(BUILD_DIR)
