FROM silex/emacs:29.4-ci

SHELL ["/bin/bash", "-c"]

RUN apt update \
    # base-dep
    && apt install -y net-tools \
                      build-essential \
                      procps \
                      iputils-ping \
                      dnsutils \
                      openssh-server \
    # gvm-dep
    && apt install -y \
                      bsdmainutils \
                      bison \
    # utf8
    && apt install -y locales \
    && locale-gen en_US.UTF-8 \
    && localedef -i en_US -f UTF-8 en_US.UTF-8 \
    # vim
    && apt install -y vim \
    # clangd clang
    && apt install -y clangd clang \
    # hugo
    && apt install -y hugo \ 
    # pip3
    && apt install -y python3-pip \
    # clean apt
    && rm -rf /var/lib/apt/lists/* \
    # nodejs
    && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash \
    && export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && nvm install 22 && nvm install 16.20.2 \
    && nvm use 16.20.2 && npm install -g yarn

# kubectl    
RUN apt-get update && apt-get install -y curl \
  && curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" \
  && chmod +x kubectl && mv kubectl /usr/local/bin/

# gvm
RUN bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer) \
    && source /root/.gvm/scripts/gvm \
    && gvm install go1.23.9 -B \
    && gvm use go1.23.9 --default \
    # gopls
    && go install golang.org/x/tools/gopls@latest \
    # goimports
    && go install golang.org/x/tools/cmd/goimports@latest

RUN apt update && apt install -y gawk

# ledger
RUN apt update && apt install -y ledger

# aider
RUN apt update && echo 3 && curl -LsSf https://aider.chat/install.sh | sh

# vue-language-server
RUN export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && npm install -g @vue/language-server
    
# vscode-langservers-extracted
RUN export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && npm install -g vscode-langservers-extracted

ENV LC_CTYPE="en_US.UTF-8"
ENV LANG="en_US.UTF-8"

RUN curl -L 'https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64' -o /usr/bin/ttyd \
    && chmod +x /usr/bin/ttyd

EXPOSE 22 7681    
CMD bash -ic "emacs --daemon && ttyd -w /root -t macOptionIsMeta=true -T xterm-direct -W bash"
