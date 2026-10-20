#!/bin/sh
# CONTRATO (não mude): escreva na saída padrão só o nome da réplica que
# respondeu e termine com código 0; ou escreva INDISPONIVEL e termine com 1.
# Nunca demore mais que 5 segundos, mesmo com tudo fora do ar.
#
# ---- Entrega 3: cliente com failover ----
# Tenta as três réplicas, uma por vez, e devolve a primeira que RESPONDER.
# Cada tentativa tem teto de 1 s (curl -m 1): pior caso 3 x 1 s = 3 s.
# Só imprime o que a réplica DISSE; sem resposta válida, nunca inventa nome.
REPLICAS="${REPLICAS:-10.0.20.21 10.0.20.22 10.0.20.23}"
PORTA="${PORTA:-8080}"
TETO="${TETO:-1}"

set -- $REPLICAS
n=$#
ini=$(( $(date +%s) % n ))
i=0
while [ "$i" -lt "$n" ]; do
  pos=$(( (ini + i) % n + 1 ))
  j=1
  for ip in "$@"; do
    if [ "$j" -eq "$pos" ]; then
      r=$(curl -s -m "$TETO" "http://$ip:$PORTA/" 2>/dev/null)
      case "$r" in
        replica[0-9]*)
          case "$r" in *[!a-zA-Z0-9]*) ;; *) echo "$r"; exit 0;; esac ;;
      esac
    fi
    j=$((j+1))
  done
  i=$((i+1))
done

echo INDISPONIVEL
exit 1
