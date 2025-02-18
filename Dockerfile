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
    # esp-idf-dep
    && apt install -y git wget flex bison gperf python3 python3-pip python3-venv python3-virtualenv cmake ninja-build ccache libffi-dev libssl-dev dfu-util libusb-1.0-0 \
    # clangd clang
    && apt install -y clangd clang \
    # hugo
    && apt install -y hugo \ 
    # clean apt
    && rm -rf /var/lib/apt/lists/* \
    # nodejs
    && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash \
    && export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && nvm install 22


# gvm
RUN bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer) \
    && source /root/.gvm/scripts/gvm \
    && gvm install go1.22.7 -B \
    && gvm use go1.22.7 --default \
    # gopls
    && go install golang.org/x/tools/gopls@latest \
    # goimports
    && go install golang.org/x/tools/cmd/goimports@latest

# aider
RUN python3 -m pip install aider-install \
    && aider-install

RUN mkdir -p /root/esp

# esp-idf-4.4.7
RUN cd /root/esp && git clone -b v4.4.7 --recursive https://github.com/espressif/esp-idf.git esp-idf-v4.4.7 \
    && cd /root/esp/esp-idf-v4.4.7 && ./install.sh all \
    && echo -e "alias get_idf_v4.4.7='. $HOME/esp/esp-idf-v4.4.7/export.sh'" >> /root/.bashrc

# esp-idf-5.3.1
RUN cd /root/esp && git clone -b v5.3.1 --recursive https://github.com/espressif/esp-idf.git esp-idf-v5.3.1 \
    && cd /root/esp/esp-idf-v5.3.1 && ./install.sh all \
    && echo -e "alias get_idf_v5.3.1='. $HOME/esp/esp-idf-v5.3.1/export.sh'" >> /root/.bashrc

# vue-language-server
RUN export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && npm install -g @vue/language-server
    
# vscode-langservers-extracted
RUN export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && npm install -g vscode-langservers-extracted

ENV LC_CTYPE="en_US.UTF-8"
ENV LANG="en_US.UTF-8"

RUN curl -L 'https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64' -o /usr/bin/ttyd \
    && chmod +x /usr/bin/ttyd

EXPOSE 22 7681    
CMD bash -ic "source /root/esp/esp-idf-v5.3.1/export.sh && emacs --daemon && ttyd -w /root -t macOptionIsMeta=true -T xterm-direct -W bash"
