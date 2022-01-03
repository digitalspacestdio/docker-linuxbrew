FROM digitalspacestudio/debian:buster as builder
LABEL maintainer="Sergey Cherepanov <sergey@digitalspace.studio>"
LABEL name="digitalspacestudio/linuxbrew"
ARG DEBIAN_FRONTEND=noninteractive
ARG BREW_VERSION=3.3.9
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates git curl file systemtap-sdt-dev g++ make uuid-runtime procps gnupg2 \
    && apt-get clean \
    && rm -rf /var/cache/apt \
    && rm -rf /var/lib/apt/lists/*
RUN useradd -m -s /bin/bash linuxbrew

RUN gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB \
&& curl -sSL https://get.rvm.io | bash \
&& echo 'progress-bar' >> ~/.curlrc \
&& echo 'source /usr/local/rvm/scripts/rvm' >> /home/linuxbrew/.profile

USER linuxbrew
WORKDIR /home/linuxbrew
RUN rvm install ruby-2.6

ENV PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH \
    SHELL=/bin/bash \
    LANG=en_US.UTF-8 \
    HOMEBREW_NO_AUTO_UPDATE=1 \
    HOMEBREW_NO_INSTALL_CLEANUP=1

RUN git clone --branch ${BREW_VERSION} --depth 1 https://github.com/Homebrew/brew /home/linuxbrew/.linuxbrew/Homebrew \
    && mkdir -p /home/linuxbrew/.linuxbrew/etc \
    /home/linuxbrew/.linuxbrew/include \
    /home/linuxbrew/.linuxbrew/lib \
    /home/linuxbrew/.linuxbrew/opt \
    /home/linuxbrew/.linuxbrew/sbin \
    /home/linuxbrew/.linuxbrew/share \
    /home/linuxbrew/.linuxbrew/var/homebrew/linked \
    /home/linuxbrew/.linuxbrew/Cellar \
    /home/linuxbrew/.linuxbrew/bin \
    /home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/homebrew/ \
    && ln -s ../Homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/

RUN git clone --depth 1 https://github.com/Homebrew/linuxbrew-core /home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/homebrew/homebrew-core

RUN brew install curl
RUN brew install git
RUN brew install gpatch

RUN brew list | grep 'perl\|python@2\|autoconf\|binutils\|gcc' | xargs --no-run-if-empty brew remove \
    && brew cleanup \
    && rm -rf /home/linuxbrew/.cache/Homebrew \
    && rm -rf /home/linuxbrew/.linuxbrew/Homebrew/Library/Homebrew/vendor/portable-ruby

FROM digitalspacestudio/debian:buster
RUN useradd -m -s /bin/bash linuxbrew
USER linuxbrew
RUN echo 'export PATH="/home/linuxbrew/.linuxbrew/sbin:$PATH"' >> /home/linuxbrew/.profile
WORKDIR /home/linuxbrew
ENV PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH \
    SHELL=/bin/bash \
    LANG=en_US.UTF-8 \
    HOMEBREW_NO_AUTO_UPDATE=1 \
    HOMEBREW_NO_INSTALL_CLEANUP=1 \
    HOMEBREW_FORCE_BREWED_CURL=1 \
    HOMEBREW_FORCE_BREWED_GIT=1

COPY --from=builder --chown=linuxbrew:linuxbrew /home/linuxbrew /home/linuxbrew
