#!/bin/sh
# Roda em r1, r2 e r3. A variável ROLE diz qual é.
ip route del default 2>/dev/null || true
sysctl -w net.ipv4.ip_forward=1 2>/dev/null || true

# ---------- ENTREGA 4: roteamento dinâmico (RIP, vetor de distância) ----------
# As rotas estáticas foram removidas: quem decide o caminho agora é o protocolo.
# Cada roteador publica as redes que conhece, ouve os vizinhos e, se o trânsito 1
# cair, recalcula sozinho e passa a usar o desvio por r3.
mkdir -p /run/bird && exec bird -f -c "/lab/bird-$ROLE.conf"
