#!/bin/sh
# Provas da Entrega 4. Mede a rede em três momentos: normal, com o trânsito 1
# derrubado, e restaurada. Convergência é diferença entre momentos — medir um
# só não diz nada.
falhas=0
ok()  { printf '  \033[32m OK \033[0m %s\n' "$1"; }
nok() { printf '  \033[31mNAO \033[0m %s\n' "$1"; falhas=$((falhas+1)); }
obs() { printf '        observado: %s\n' "$1"; }
via(){ docker exec e4-r1 sh -c "ip route get 10.0.20.10 2>/dev/null" | head -1; }
alcanca(){ docker exec e4-host-a ping -c1 -W2 10.0.20.10 >/dev/null 2>&1; }
esperar(){ i=0; while [ $i -lt "$1" ]; do alcanca && return 0; i=$((i+1)); sleep 2; done; return 1; }

echo; echo "=== ENTREGA 4 — a rota se refaz sozinha ==="; echo
# religa as DUAS pontas do trânsito 1
docker network connect --ip 10.0.30.11 e4_seg-t1 e4-r1 >/dev/null 2>&1
docker network connect --ip 10.0.30.12 e4_seg-t1 e4-r2 >/dev/null 2>&1
sleep 8

if alcanca; then ok "estado normal: host-a alcança host-b"; obs "$(via)"; else nok "estado normal já está quebrado"; obs "$(via)"; fi
ANTES=$(via)
case "$ANTES" in
  *10.0.30.12*) ok "o caminho normal é o CURTO: direto para r2 pelo trânsito 1"; obs "$ANTES";;
  *10.0.40.13*) nok "r1 está usando o DESVIO por r3 sem necessidade"; obs "o caminho curto pelo trânsito 1 devia vencer: $ANTES";;
  *) nok "não consegui ler o próximo salto em r1"; obs "${ANTES:-<vazio>}";; esac
echo

echo "  derrubando o trânsito 1 e cronometrando a recuperação..."
# Um enlace que cai, cai para as DUAS pontas. Derrubar só um lado deixaria o
# outro anunciando um caminho que não existe mais até o temporizador do RIP
# expirar (180 s) — é RIP legítimo, mas não é um cabo rompido.
docker network disconnect e4_seg-t1 e4-r1 >/dev/null 2>&1
docker network disconnect e4_seg-t1 e4-r2 >/dev/null 2>&1
I=$(date +%s)
if esperar 30; then
  F=$(date +%s); DEPOIS=$(via)
  ok "a rede se recuperou sozinha"; obs "levou $((F-I))s — esse é o custo da convergência"
  case "$DEPOIS" in
    *10.0.40.13*) ok "convergiu para o DESVIO por r3 (o caminho de 2 saltos)"; obs "antes: $ANTES / depois: $DEPOIS";;
    *) if [ "$DEPOIS" != "$ANTES" ]; then ok "o próximo salto MUDOU de caminho"; obs "antes: $ANTES / depois: $DEPOIS"
       else nok "o caminho é idêntico ao de antes — nada convergiu"; obs "$DEPOIS"; fi;;
  esac
else
  nok "60s depois a rede continua morta — nada se refez sozinho"
  v=$(via)
  obs "r1 agora diz: ${v:-nenhuma rota para 10.0.20.10 (a rota foi embora junto com a interface)}"
  obs "o desvio por r3 está de pé e ninguém o usa: é isto que o roteamento dinâmico resolve"
fi
echo

echo "  religando o trânsito 1..."
docker network connect --ip 10.0.30.11 e4_seg-t1 e4-r1 >/dev/null 2>&1
docker network connect --ip 10.0.30.12 e4_seg-t1 e4-r2 >/dev/null 2>&1
if esperar 20; then ok "a rede continua de pé com os dois caminhos"; obs "$(via)"
else nok "a rede não voltou nem depois de religar o cabo"
     obs "a rota estática sumiu junto com a interface e ninguém a recriou — quem escreveu à mão teria de voltar e escrever de novo"; fi

echo
[ "$falhas" -eq 0 ] && { printf '\033[32mENTREGA 4 COMPLETA\033[0m\n\n'; } || { printf '\033[31m%s prova(s) vermelha(s).\033[0m\n\n' "$falhas"; exit 1; }
