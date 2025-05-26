# Diretórios
SCANNER_DIR = src/scanner_module
PARSER_DIR = src/parser_module
BUILD_DIR = build

# Arquivos
LEX_FILE = $(SCANNER_DIR)/scanner.l
YACC_FILE = $(PARSER_DIR)/parser.y
LEX_C_FILE = $(BUILD_DIR)/lex.yy.c
YACC_C_FILE = $(BUILD_DIR)/parser.tab.c
YACC_H_FILE = $(BUILD_DIR)/parser.tab.h
EXEC = $(BUILD_DIR)/parser

# Regra padrão
all: $(EXEC)

# Compila os arquivos C para gerar o executável
$(EXEC): $(YACC_C_FILE) $(LEX_C_FILE)
	gcc $(YACC_C_FILE) $(LEX_C_FILE) -o $(EXEC) -lfl

# Gera parser.tab.c e parser.tab.h a partir de parser.y
$(YACC_C_FILE) $(YACC_H_FILE): $(YACC_FILE)
	mkdir -p $(BUILD_DIR)
	bison -d -o $(YACC_C_FILE) $(YACC_FILE)
	mv parser.tab.h $(BUILD_DIR)/parser.tab.h

# Gera lex.yy.c a partir de scanner.l
$(LEX_C_FILE): $(LEX_FILE)
	mkdir -p $(BUILD_DIR)
	flex -o $(LEX_C_FILE) $(LEX_FILE)

# Limpa os arquivos gerados
clean:
	rm -rf $(BUILD_DIR)
