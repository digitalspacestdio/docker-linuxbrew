FROM djocker/debian
LABEL maintainer="Sergey Cherepanov <s@cherepanov.co>"
LABEL name="djocker/linuxbrew"
ARG DEBIAN_FRONTEND=noninteractive
ARG BREW_VERSION=2.1.9
RUN apt-get update \
	&& apt-get install -y --no-install-recommends ca-certificates git curl file systemtap-sdt-dev g++ make uuid-runtime
RUN useradd -m -s /bin/bash linuxbrew
USER linuxbrew
WORKDIR /home/linuxbrew
ENV LANG=en_US.UTF-8 \
	PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH \
	SHELL=/bin/bash

RUN git clone --branch ${BREW_VERSION} https://github.com/Homebrew/brew /home/linuxbrew/.linuxbrew/Homebrew \
    && mkdir -p /home/linuxbrew/.linuxbrew/etc \
    /home/linuxbrew/.linuxbrew/include \
    /home/linuxbrew/.linuxbrew/lib \
    /home/linuxbrew/.linuxbrew/opt \
    /home/linuxbrew/.linuxbrew/sbin \
    /home/linuxbrew/.linuxbrew/share \
    /home/linuxbrew/.linuxbrew/var/homebrew/linked \
    /home/linuxbrew/.linuxbrew/Cellar \
	/home/linuxbrew/.linuxbrew/bin \
	&& ln -s ../Homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/ \
	&& brew config \
	&& brew doctor

RUN brew tap djocker/common \
    && brew install openssl curl git
