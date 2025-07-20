COMPILADOR="./meucompilador"
TEST_DIR="teste_module" # Define o diretório dos testes

if [ ! -f "$COMPILADOR" ]; then
    echo "Erro: O executável '$COMPILADOR' não foi encontrado."
    echo "Por favor, compile o projeto primeiro com o comando 'make'."
    exit 1
fi

# Alterado: Procura os ficheiros de teste dentro da pasta TEST_DIR
arquivos_de_teste=($TEST_DIR/*.lang)

if [ ${#arquivos_de_teste[@]} -eq 0 ] || [ ! -f "${arquivos_de_teste[0]}" ]; then
    echo "Nenhum ficheiro de teste (*.lang) encontrado na pasta '$TEST_DIR'."
    exit 1
fi

opcoes=("${arquivos_de_teste[@]}" "Sair")

echo "--- Por favor, selecione o teste que deseja executar: ---"
PS3="Digite o número do teste (ou pressione Ctrl+C para sair): "

select opcao in "${opcoes[@]}"; do
    if [ "$opcao" == "Sair" ]; then
        echo "Saindo."
        break
    elif [ -n "$opcao" ]; then
        echo "-----------------------------------------------------"
        echo ">>> Executando teste: $opcao <<<"
        $COMPILADOR "$opcao"
        echo "-----------------------------------------------------"
        echo -e "\n--- Selecione o próximo teste: ---"
    else
        echo "Opção inválida: $REPLY. Por favor, tente novamente."
    fi
done