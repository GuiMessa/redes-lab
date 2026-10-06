# Imagem única do laboratório. Pequena de propósito: a VM do Cloud Shell é
# efêmera e recicla o cache de imagens — imagem grande = aula perdida no pull.
FROM alpine:3.20

RUN apk add --no-cache \
      iproute2 \
      iputils \
      tcpdump \
      curl \
      busybox-extras \
      openssl \
      netcat-openbsd \
 && mkdir -p /srv /lab \
 # O applet `httpd` NÃO vem no busybox principal do Alpine: ele está no
 # busybox-extras. Fixamos um nome estável e conferimos AQUI — se faltar, a
 # imagem não é construída, em vez de o contêiner morrer em silêncio na aula.
 && ln -sf /usr/bin/busybox-extras /usr/local/bin/httpd \
 && httpd --help 2>&1 | grep -qi 'usage: httpd'

CMD ["sleep", "infinity"]
