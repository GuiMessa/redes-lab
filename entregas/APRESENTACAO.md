# Apresentação — Semana 14

## O formato

<walkthrough-tutorial-duration duration="6"></walkthrough-tutorial-duration>

**Seis minutos por grupo, cronometrados.** Não são slides: é a **rede subindo ao
vivo**, projetada, a partir do repositório de vocês. Quem fez o trabalho
demonstra em seis minutos; quem não fez não tem o que projetar.

**Vale 1,4** · última semana · todos os integrantes falam.

A semana 14 também tem revisão geral e a Avaliação 2. Por isso o tempo é curto
e o relógio é levado a sério: aos 6 minutos, encerra.

## Os quatro momentos

**1 · A rede sobe (30 s).** Abram o Cloud Shell projetado, clonem o repositório
do grupo e rodem uma entrega à escolha de vocês:

```bash
make up E=2 && make verificar E=2
```

Enquanto sobe, apresentem o grupo e digam qual entrega escolheram. O verde na
tela é a prova de que o trabalho é reproduzível fora da máquina de vocês — que
é a diferença entre ter feito e conseguir mostrar.

**2 · A evidência (2 min).** Escolham **uma** prova e expliquem-na de verdade:
os dois `.pcap` da Entrega 2 abertos no Wireshark, o serviço sobrevivendo à
queda de duas réplicas, a rota se refazendo pelo desvio, ou a senha aparecendo
em letras legíveis dentro do pacote. Uma só, bem explicada, vale mais que as
cinco citadas de passagem.

**3 · A cartilha (2 min).** O que produziram, **para quem**, onde apresentaram
e o que ouviram de volta. Se mudaram o material depois do retorno, mostrem o
antes e o depois — é o que separa 1,7 de 2,0 na nota de Extensão.

**4 · Uma pergunta (1,5 min).** O professor sorteia uma pergunta da lista
abaixo. Ela é pública desde a semana 6: dá para estudar, e a resposta certa não
depende de memorizar nada — depende de ter entendido o que vocês mesmos
mediram. Responde quem for sorteado no grupo.

## A lista de perguntas

Nenhuma delas pede decoreba. Todas têm resposta nas medições que vocês fizeram.

1. Por que `Network is unreachable` é diferente de tempo esgotado? O que cada
   um diz sobre **onde** está o problema?
2. Numa `/24` cabem 256 endereços, mas só 254 máquinas. Por quê?
3. O pacote atravessou o roteador: o que mudou nele, o que não mudou, e por quê?
4. Para que serve o TTL? O que aconteceria numa rede sem ele?
5. O cliente de vocês consegue distinguir uma réplica **morta** de uma
   **particionada**? Se não consegue, como ele decide o que fazer?
6. Por que um cliente que espera para sempre é pior que um que desiste?
7. A rota estática funcionava. Por que trocá-la por um protocolo de roteamento?
8. Vocês mediram a convergência com 3 roteadores. O que muda com 50?
9. Por que o enlace precisa cair nas **duas** pontas para a rede convergir
   depressa? O que acontece se cair só de um lado?
10. Vocês capturaram no roteador. Por que não daria para capturar de um
    computador qualquer da rede?
11. O que exatamente o cadeado do navegador protege — e o que ele **não**
    protege?
12. Por que o navegador reclama de um certificado que vocês mesmos assinaram?

## Como é corrigido

| O quê | Pontos |
|---|---|
| A rede sobe ao vivo e a verificação fica verde | 0,5 |
| A evidência escolhida é **explicada**, não lida | 0,4 |
| A cartilha: para quem foi, onde, e o que voltou | 0,3 |
| A resposta à pergunta sorteada | 0,2 |

<walkthrough-footnote>
Se o Cloud Shell falhar por motivo alheio ao grupo — rede da faculdade, conta
bloqueada —, mostrem o repositório e as evidências gravadas: a nota da primeira
linha cai pela metade, não a zero. O que não recupera ponto é chegar sem
repositório.
</walkthrough-footnote>

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>
