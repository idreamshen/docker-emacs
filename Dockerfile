FROM silex/emacs:29.4-ci

SHELL ["/bin/bash", "-c"]

RUN apt update \
    && apt install -y net-tools \
                      build-essential \
    # gvm
    && apt install -y \
                      bsdmainutils \
                      bison \
    && bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer) && \
    gvm install go1.22.7 && \
    gvm use go1.22.7 --default
