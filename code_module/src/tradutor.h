#ifndef TRADUTOR_H
#define TRADUTOR_H
#include "geracode.h"
// Inclui geracode.h para ter acesso à definição da struct CodeGenerator,
// que é usada como parâmetro na função abaixo.
#include "geracode.h"

/**
 * @brief Traduz o código de três endereços contido no CodeGenerator para
 * o código de máquina da VM, imprimindo o resultado na saída padrão.
 *
 * Esta função percorre o código intermediário linha por linha,
 * converte cada instrução para o formato da VM e a imprime.
 *
 * @param cg O ponteiro para o CodeGenerator que contém o código a ser traduzido.
 */
void translate_to_vm(CodeGenerator* cg);

#endif // TRADUTOR_H
