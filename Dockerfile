FROM silex/emacs:29.4-ci

RUN apt update && apt install -y net-tools