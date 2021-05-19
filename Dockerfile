FROM djocker/debian as builder
LABEL maintainer="Sergey Cherepanov <s@cherepanov.co>"
LABEL name="djocker/linuxbrew"
ARG DEBIAN_FRONTEND=noninteractive
ARG BREW_VERSION=3.1.7
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates git curl file systemtap-sdt-dev g++ make uuid-runtime \
    && apt-get clean \
    && rm -rf /var/cache/apt
RUN useradd -m -s /bin/bash linuxbrew
USER linuxbrew
WORKDIR /home/linuxbrew
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
RUN git clone --depth 1 https://github.com/djocker/homebrew-common /home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/djocker/homebrew-common

RUN brew install curl
RUN brew install git
RUN brew install gpatch

RUN brew list | grep 'perl\|python@2\|autoconf\|binutils\|gcc' | xargs --no-run-if-empty brew remove \
    && brew cleanup \
    && rm -rf /home/linuxbrew/.cache/Homebrew \
    && rm -rf /home/linuxbrew/.linuxbrew/Homebrew/Library/Homebrew/vendor/portable-ruby

FROM djocker/debian
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