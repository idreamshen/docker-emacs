FROM silex/emacs:29.4-ci

RUN apt update && apt install -y net-tools \
                                    build-essential && \
                                    bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
