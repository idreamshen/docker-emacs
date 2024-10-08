FROM silex/emacs:29.4-ci

SHELL ["/bin/bash", "-c"]

RUN apt update \
    && apt install -y net-tools \
                      build-essential \
                      procps \
                      iputils-ping \
                      dnsutils \
                      openssh-server \
    # gvm
    && apt install -y \
                      bsdmainutils \
                      bison \
    && bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer) \
    && source /root/.gvm/scripts/gvm \
    && gvm install go1.22.7 -B \
    && gvm use go1.22.7 --default \
    # utf8
    && apt install -y locales \
    && locale-gen en_US.UTF-8 \
    && localedef -i en_US -f UTF-8 en_US.UTF-8 \
    # vim
    && apt install -y vim \
    # gopls
    && go install golang.org/x/tools/gopls@latest \
    # goimports
    && go install golang.org/x/tools/cmd/goimports@latest \
    # esp-idf
    && apt-get install -y git wget flex bison gperf python3 python3-pip python3-venv cmake ninja-build ccache libffi-dev libssl-dev dfu-util libusb-1.0-0 \
    && mkdir -p /root/esp && cd /root/esp && git clone -b v5.3.1 --recursive https://github.com/espressif/esp-idf.git \
    && cd /root/esp/esp-idf && ./install.sh all \
    && echo -e "alias get_idf='. $HOME/esp/esp-idf/export.sh'" >> /root/.bashrc


ENV LC_CTYPE="en_US.UTF-8"
ENV LANG="en_US.UTF-8"

RUN curl -L 'https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64' -o /usr/bin/ttyd \
    && chmod +x /usr/bin/ttyd

EXPOSE 22 7681    
CMD bash -ic "emacs --daemon && ttyd -w /root -t macOptionIsMeta=true -T xterm-direct -W bash"