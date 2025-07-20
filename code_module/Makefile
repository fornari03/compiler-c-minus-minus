# ====================================================================
# Variáveis de Configuração
# ====================================================================
CC = gcc
CFLAGS = -Wall -Wextra -g -Wno-unused -Isrc
LEX = flex
YACC = bison
YFLAGS = -d -Wno-counterexamples

# Estrutura de Pastas
SRC_DIR = src
TEST_DIR = teste_module
BUILD_DIR = obj

VPATH = $(SRC_DIR):$(BUILD_DIR)

# Ficheiros e Executável
TARGET = meucompilador
OBJ_NAMES = parser.tab.o lex.yy.o tradutor.o geracode.o
OBJ = $(addprefix $(BUILD_DIR)/, $(OBJ_NAMES))

# Testes
TEST_FILES = $(wildcard $(TEST_DIR)/*.lang)
TEST_FILE ?= $(TEST_DIR)/teste_01_declaracao_simples.lang

# ====================================================================
# Alvos Principais
# ====================================================================
all: $(BUILD_DIR) $(TARGET)

$(TARGET): $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^ -lfl

# ====================================================================
# Alvos de Automação e Testes
# ====================================================================
test: $(TARGET)
	@echo "--- Executando todos os testes automatizados ---"
	@for f in $(TEST_FILES); do \
		echo "\n>>> Testando: $$f <<<"; \
		./$(TARGET) $$f; \
	done
	@echo "\n--- Testes concluídos ---"

run: $(TARGET)
	@echo ">>> Executando teste individual: $(TEST_FILE) <<<"
	@./$(TARGET) $(TEST_FILE)

menu: $(TARGET)
	@echo "A iniciar o menu de testes interativo..."
	@chmod +x run_tests.sh
	@bash run_tests.sh

# ====================================================================
# Regras de Geração de Ficheiros
# ====================================================================
$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/parser.tab.c $(BUILD_DIR)/parser.tab.h: parser.y | $(BUILD_DIR)
	$(YACC) $(YFLAGS) $(SRC_DIR)/parser.y -o $(BUILD_DIR)/parser.tab.c

$(BUILD_DIR)/lex.yy.c: scanner.l $(BUILD_DIR)/parser.tab.h | $(BUILD_DIR)
	$(LEX) -o $(BUILD_DIR)/lex.yy.c $(SRC_DIR)/scanner.l

$(BUILD_DIR)/%.o: %.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

# ====================================================================
# Alvos Utilitários
# ====================================================================
# CORRIGIDO: O 'clean' agora apaga a pasta 'obj' inteira e o executável
clean:
	rm -rf $(BUILD_DIR)
	rm -f $(TARGET)

.PHONY: all clean test run menu