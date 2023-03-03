.data

abort_invalid_ap_txt: .asciiz "O apartamento informado  invalido\n"
abort_exceeding_tenant_txt: .asciiz "Voce excedeu o maximo de moradores possiveis neste apartamento\n"
unexpected_error1_ap_txt: .asciiz "Log: espaco vazio nao encontrado (morador)\n"
ap_morador_conclusion_txt: .asciiz "Morador adicionado com sucesso!\n"
invalid_auto_out: .asciiz "As opcoes de tipo sao apenas 'c' (carro) e 'm' (moto)\n"
no_space_auto_out: .asciiz "Nao ha mais vagas na sua garagem\n"


.text
.globl abort_invalid_ap, abort_exceeding_tenant, unexpected_error1_ap, ap_morador_conclusion, invalid_auto, no_space_auto

abort_invalid_ap:
    la $a0, abort_invalid_ap_txt
    jal print_str
    j start

abort_exceeding_tenant:
    la $a0, abort_exceeding_tenant_txt
    jal print_str
    j start

unexpected_error1_ap:
    la $a0, unexpected_error1_ap_txt
    jal print_str
    j start

ap_morador_conclusion:
    la $a0, ap_morador_conclusion_txt
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