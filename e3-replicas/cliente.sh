#!/bin/sh
# CONTRATO (não mude): escreva na saída padrão só o nome da réplica que
# respondeu e termine com código 0; ou escreva INDISPONIVEL e termine com 1.
# Nunca demore mais que 5 segundos, mesmo com tudo fora do ar.
#
# ---- versão ingênua: uma réplica só. Seu trabalho é substituir isto. ----
REPLICAS="10.0.20.21"

for ip in $REPLICAS; do
  r=$(curl -s -m 1 "http://$ip:8080/" 2>/dev/null)
  if [ -n "$r" ]; then echo "$r"; exit 0; fi
done
echo INDISPONIVEL
exit 1
