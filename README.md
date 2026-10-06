# Minha pequena internet

Laboratório do trabalho semestral de **Redes e Sistemas Distribuídos** —
Prof. Me. Luiz Ricardo Mantovani da Silva.

Uma topologia só, que cresce ao longo do semestre: começa com duas redes que
não se falam e termina com um serviço replicado, roteamento que se refaz
sozinho e a demonstração de por que uma senha não deve viajar sem proteção.

Tudo roda no **Google Cloud Shell**, que é gratuito, não pede cartão de crédito
e dá a cada aluno uma máquina Linux com root só dela.

---

## Começando

Construa a imagem do laboratório — uma vez por sessão do Cloud Shell:

```bash
make base
```

Suba a topologia da primeira entrega:

```bash
make up E=1
```

Rode as provas:

```bash
make verificar E=1
```

`make verificar` **começa vermelho de propósito**. O laboratório vem
incompleto: o roteiro de verificação é o enunciado de verdade, e o trabalho é
levá-lo ao verde.

Enunciado de cada entrega em [`entregas/`](entregas/).

---

## As cinco entregas

| # | Semana | Tema | Vale |
|---|---|---|---|
| [E1](entregas/E1.md) | 6 | Dois segmentos e um serviço | 0,8 |
| [E2](entregas/E2.md) | 9 | O roteador e o encapsulamento | 1,4 |
| [E3](entregas/E3.md) | 11 | O serviço não pode cair | 1,2 |
| [E4](entregas/E4.md) | 12 | A rota se refaz sozinha | 1,2 |
| — | 14 | Apresentação | 1,4 |
| [E5](entregas/E5.md) | 13 | O pacote entrega o segredo · **Cartilha** | **2,0 (Extensão)** |

E1–E4 e a apresentação compõem os 6,0 de avaliação prática. E5 é a atividade
de extensão, com nota escalonada em 1,2 / 1,7 / 2,0.

---

## Regras do jogo

**A entrega é o repositório, nunca o ambiente.** A correção é feita clonando o
repositório do grupo numa Cloud Shell limpa e rodando `make up` e
`make verificar`. Se não subir lá, não entregou.

**Evidência é obrigatória.** `make evidencias E=<n>` grava a saída da
verificação; os `.pcap` das entregas 2 e 5 vão junto. Isso é versionado — nunca
apaguem a pasta `evidencias/`.

**Imagem pequena.** A máquina do Cloud Shell é efêmera e recicla o cache de
imagens: só a pasta pessoal (5 GB) sobrevive. Por isso a base é Alpine.

**Nada de varredura de rede.** Os termos de uso do Cloud Shell proíbem
explicitamente varredura, e a conta que descumprir é desligada. Todo o trabalho
aqui é captura passiva dentro da rede virtual do próprio grupo — o que é outra
coisa, e é permitido.

---

## Para o professor

Antes de liberar para a turma, uma vez, numa Cloud Shell limpa:

```bash
make autoteste
```

Confere as quatro coisas de que o laboratório depende e que documentação
nenhuma garante: criação de bridge com sub-rede própria, `tcpdump` com
`NET_RAW` efetivo, `net.ipv4.ip_forward` por contêiner, e o pacote `bird` no
Alpine (só a E4 depende dele).

### Botão "Abrir no Cloud Shell"

Para cada entrega, na página do trabalho:

```
https://shell.cloud.google.com/cloudshell/editor
  ?cloudshell_git_repo=https://github.com/LuizRMSilva1973/redes-lab
  &cloudshell_tutorial=entregas/E1.md
  &show=ide%2Cterminal
```

O aluno cai no terminal com o repositório clonado e o enunciado aberto como
roteiro guiado ao lado. Trocar `E1.md` pela entrega da vez.

O repositório precisa estar em **GitHub ou Bitbucket**, público.

### Correção

```bash
git clone <repo-do-grupo> && cd <repo> && make up E=2 && make verificar E=2
```

Os roteiros imprimem o valor observado em cada ponto, não só passou/falhou —
dá para corrigir lendo a saída.

---

## Entrega 2 — O roteador e o encapsulamento

**Topologia** (`e2-roteador/docker-compose.yml`): `host-a1` (10.0.10.10) e
`host-a2` (10.0.10.11) no segmento A; `host-b1` (10.0.20.10) no segmento B; o
`router` tem uma perna em cada segmento (10.0.10.254 e 10.0.20.254) e
`net.ipv4.ip_forward=1`.

**Rotas** (declaradas no `command` do próprio `docker-compose.yml`, nada digitado no terminal):

| Host | Rota |
|---|---|
| `host-a1` | `ip route add 10.0.20.0/24 via 10.0.10.254` |
| `host-b1` | `ip route add 10.0.10.0/24 via 10.0.20.254` |
| `host-a2` | **nenhuma** — é o grupo de controle e continua isolado de B |

**Evidências:** `e2-roteador/perna-a.pcap` e `e2-roteador/perna-b.pcap`
(capturas do mesmo ping nas duas pernas do roteador) e o print do Wireshark em
`e2-roteador/evidencias/wireshark.png`.

### Por que o MAC muda e o IP não

O endereço IP é um endereço **fim a fim** (camada 3): identifica quem enviou o
pacote (origem) e quem deve recebê-lo (destino), e por isso precisa chegar
intacto ao destino — se o roteador trocasse o IP de origem, o `host-b1` não
saberia a quem responder. O endereço MAC, ao contrário, é um endereço **salto a
salto** (camada 2): só tem significado dentro de um único segmento Ethernet,
onde diz qual placa de rede enviou o quadro e qual deve recebê-lo. Quando
`host-a1` quer falar com `host-b1`, ele percebe que o destino não está na sua
sub-rede, então monta um quadro com o IP de destino de `host-b1`, mas com o MAC
de destino do **roteador** (a interface 10.0.10.254). O roteador recebe o
quadro, descarta o cabeçalho Ethernet, decrementa o TTL (64 → 63), consulta a
tabela de rotas e **encapsula o mesmo pacote IP em um quadro novo** no segmento
B, agora com o MAC de origem da perna B do roteador e o MAC de destino de
`host-b1`. Resultado, visível nas duas capturas: o **IP de origem e o IP de
destino são idênticos** nas duas pernas, e os **MACs de origem e de destino
mudam** — o quadro é refeito a cada enlace, enquanto o pacote IP atravessa a
rede inteira. O `host-a2`, sem rota, nunca chega a gerar esse tráfego: ele
continua falhando com `Network is unreachable`, o que prova que foi a rota, e
só ela, que fez `host-a1` atravessar.
