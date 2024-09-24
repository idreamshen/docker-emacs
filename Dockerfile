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
    && gvm use go1.22.7 --default

RUN curl -L 'https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64' -o /usr/bin/ttyd \
    && chmod +x /usr/bin/ttyd

COPY terminfo-24bit.src /root/terminfo-24bit.src
RUN tic -x -o /root/.terminfo /root/terminfo-24bit.src

EXPOSE 22 7681    
CMD emacs --daemon && ttyd -t macOptionIsMeta=true -T xterm-24bit -W bash