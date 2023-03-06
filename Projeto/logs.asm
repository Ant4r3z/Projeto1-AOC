.data

abort_invalid_ap_txt: .asciiz "Falha: apartamento invalido\n"
abort_exceeding_tenant_txt: .asciiz "Falha: voce excedeu o maximo de moradores possiveis neste apartamento\n"
abort_no_tenant_txt: .asciiz "Este apartamento ja esta vazio\n"
abort_tenant_not_found_txt: .asciiz "Falha: Morador não encontrado\n"
unexpected_error1_ap_txt: .asciiz "Log: espaco vazio nao encontrado (morador)\n"
add_morador_conclusion_txt: .asciiz "Morador adicionado com sucesso!\n"
rm_morador_conclusion_txt: .asciiz "Morador removido com sucesso!\n"
invalid_auto_out: .asciiz "As opcoes de tipo sao apenas 'c' (carro) e 'm' (moto)\n"
no_space_auto_out: .asciiz "Nao ha mais vagas na sua garagem\n"
automovel_adicionado_txt: .asciiz "Automovel adicionado com sucesso!\n"
salvo_txt: .asciiz "Dados salvos com sucesso\n"
recarregado_txt: .asciiz "Dados recarregados com sucesso\n"


.text
.globl abort_invalid_ap, abort_exceeding_tenant, abort_no_tenant, abort_tenant_not_found, unexpected_error1_ap, add_morador_conclusion, rm_morador_conclusion, invalid_auto, no_space_auto, salvo, recarregado, auto_adicionado

abort_invalid_ap:
    la $a0, abort_invalid_ap_txt
    jal print_str
    j start

abort_exceeding_tenant:
    la $a0, abort_exceeding_tenant_txt
    jal print_str
    j start

abort_no_tenant:
    la $a0, abort_no_tenant_txt
    jal print_str
    j start

abort_tenant_not_found:
    la $a0, abort_tenant_not_found_txt
    jal print_str
    j start

unexpected_error1_ap:
    la $a0, unexpected_error1_ap_txt
    jal print_str
    j start

add_morador_conclusion:
    la $a0, add_morador_conclusion_txt
    jal print_str
    j start

rm_morador_conclusion:
    la $a0, rm_morador_conclusion_txt
    jal print_str
    j start

invalid_auto:
    la $a0, invalid_auto_out
    jal print_str
    j start

no_space_auto:
    la $a0, no_space_auto_out
    jal print_str
    j start

auto_adicionado:
    la $a0, automovel_adicionado_txt
    jal print_str
    j start

salvo:
    la $a0, salvo_txt
    jal print_str
    j start

recarregado:
    la $a0, recarregado_txt
    jal print_str
    j start