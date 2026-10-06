#!/bin/sh
# Provas da Entrega 3. Mede o serviço em quatro estados: tudo no ar, uma
# réplica fora, duas fora, e uma partição de rede. O último caso (nada no ar)
# existe para impedir que um cliente que responde qualquer coisa passe.
falhas=0
ok()  { printf '  \033[32m OK \033[0m %s\n' "$1"; }
nok() { printf '  \033[31mNAO \033[0m %s\n' "$1"; falhas=$((falhas+1)); }
obs() { printf '        observado: %s\n' "$1"; }
chamar(){ docker exec e3-cliente sh /lab/cliente.sh 2>/dev/null; }
cron(){ s=$(date +%s); r=$(chamar); e=$(date +%s); echo "$r|$((e-s))"; }

restaurar(){ for n in 1 2 3; do docker start e3-replica$n >/dev/null 2>&1; done
             docker network connect --ip 10.0.20.23 e3_seg-b e3-replica3 >/dev/null 2>&1
             sleep 2; }

echo; echo "=== ENTREGA 3 — o serviço não pode cair ==="; echo
restaurar

x=$(cron); r=${x%|*}; t=${x#*|}
case "$r" in replica[123]) ok "com 3 réplicas o serviço responde"; obs "respondeu $r em ${t}s";;
  *) nok "com 3 réplicas o serviço NÃO respondeu"; obs "${r:-<vazio>}";; esac

docker stop e3-replica1 >/dev/null 2>&1; sleep 1
x=$(cron); r=${x%|*}; t=${x#*|}
case "$r" in replica[23]) ok "réplica1 fora: o serviço continua"; obs "respondeu $r em ${t}s";;
  replica1) nok "respondeu 'replica1', que está parada — resposta falsa"; obs "$r";;
  *) nok "réplica1 fora: o serviço caiu"; obs "${r:-<vazio>} em ${t}s";; esac

docker stop e3-replica2 >/dev/null 2>&1; sleep 1
x=$(cron); r=${x%|*}; t=${x#*|}
case "$r" in replica3) ok "duas fora: a última réplica sustenta o serviço"; obs "respondeu $r em ${t}s";;
  *) nok "duas fora: o serviço caiu"; obs "${r:-<vazio>} em ${t}s";; esac

# partição: a réplica continua VIVA, mas inalcançável. Falha diferente de morte.
docker network disconnect e3_seg-b e3-replica3 >/dev/null 2>&1; sleep 1
x=$(cron); r=${x%|*}; t=${x#*|}
if [ "$r" = "INDISPONIVEL" ] && [ "$t" -le 5 ]; then
  ok "partição de rede: o cliente desiste com aviso claro e sem travar"; obs "INDISPONIVEL em ${t}s"
elif [ "$t" -gt 5 ]; then nok "o cliente travou (>5s) — cliente que pendura derruba quem chama"; obs "${t}s"
else nok "sem nenhuma réplica alcançável o cliente devia dizer INDISPONIVEL"; obs "${r:-<vazio>} em ${t}s"; fi

restaurar
x=$(cron); r=${x%|*}
case "$r" in replica[123]) ok "religadas as réplicas, o serviço volta sozinho"; obs "respondeu $r";;
  *) nok "o serviço não voltou após restaurar"; obs "${r:-<vazio>}";; esac

echo
[ "$falhas" -eq 0 ] && { printf '\033[32mENTREGA 3 COMPLETA\033[0m\n\n'; } || { printf '\033[31m%s prova(s) vermelha(s).\033[0m\n\n' "$falhas"; exit 1; }
