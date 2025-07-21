# ====================================================================
# Variáveis de Configuração
# ====================================================================
CC = gcc
# ALTERADO: CFLAGS agora inclui todos os submódulos para os ficheiros .h
CFLAGS = -Wall -Wextra -g -Wno-unused -Isrc/code_module -Isrc/parser_module -Isrc/scanner_module
LEX = flex
YACC = bison
YFLAGS = -d -Wno-counterexamples

# --- ESTRUTURA DE PASTAS ---
# ALTERADO: VPATH agora inclui todos os submódulos dentro de src
VPATH = src/code_module:src/parser_module:src/scanner_module:build

BUILD_DIR = build
TEST_DIR = teste_module

# --- FICHEIROS E EXECUTÁVEL ---
TARGET = meucompilador
OBJ_NAMES = parser.tab.o lex.yy.o tradutor.o geracode.o
OBJ = $(addprefix $(BUILD_DIR)/, $(OBJ_NAMES))

# --- TESTES ---
TEST_FILES = $(wildcard $(TEST_DIR)/*.lang)
TEST_FILE ?= $(TEST_DIR)/teste.lang

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

# ALTERADO: Caminho explícito para parser.y
$(BUILD_DIR)/parser.tab.c $(BUILD_DIR)/parser.tab.h: src/parser_module/parser.y | $(BUILD_DIR)
	$(YACC) $(YFLAGS) $< -o $(BUILD_DIR)/parser.tab.c

# ALTERADO: Caminho explícito para scanner.l
$(BUILD_DIR)/lex.yy.c: src/scanner_module/scanner.l $(BUILD_DIR)/parser.tab.h | $(BUILD_DIR)
	$(LEX) -o $(BUILD_DIR)/lex.yy.c $<

$(BUILD_DIR)/%.o: %.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

# ====================================================================
# Alvos Utilitários
# ====================================================================
clean:
	rm -rf $(BUILD_DIR)
	rm -f $(TARGET)

.PHONY: all clean test run menu