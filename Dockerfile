FROM debian:buster-slim

ENV LANG=de_DE.UTF-8 \
    # adding a sane default is needed since we're not erroring out via exec.
     CODER_PASSWORD="coder" \
     SHELL=/bin/bash

#Change this via --arg in Docker CLI
ARG CODER_VERSION=2.1692-vsc1.39.2

COPY exec-v2 /opt/exec

RUN apt-get update && \
    apt-get install -y  \
      sudo \
      apt-utils \
      openssl \
      net-tools \
      git \
      locales \
      curl \
      dumb-init \
      wget && \
    locale-gen de_DE.UTF-8 && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    cd /tmp && \
    wget -O - https://github.com/codercom/code-server/releases/download/${CODER_VERSION}/code-server${CODER_VERSION}-linux-x86_64.tar.gz | tar -xzv && \
    chmod -R 755 code-server${CODER_VERSION}-linux-x86_64/code-server && \
    mv code-server${CODER_VERSION}-linux-x86_64/code-server /usr/bin/ && \
    rm -rf code-server-${CODER_VERSION}-linux-x86_64 && \
    adduser --disabled-password --gecos '' coder   && \
    echo '%sudo ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd && \
    chmod g+rw /home/coder && \
    chmod a+x /opt/exec && \
    chgrp -R 0 /home/coder && \
    chmod -R g=u /home/coder && \
    chmod g=u /etc/passwd;

WORKDIR /home/coder

USER coder

RUN mkdir -p projects && mkdir -p certs && \
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash && \
    sudo chmod -R g+rw projects/ && \
    sudo chmod -R g+rw certs/ && \
    sudo chmod -R g+rw .nvm;

COPY entrypoint /home/coder

VOLUME ["/home/coder/projects"];

USER 10001

ENTRYPOINT ["/home/coder/entrypoint"]

EXPOSE 9000

CMD ["/opt/exec"]
