FROM digitalspacestudio/debian:gcc-11-ruby-2.6-bullseye as builder
LABEL maintainer="Sergey Cherepanov <sergey@digitalspace.studio>"
LABEL name="digitalspacestudio/linuxbrew"
ARG DEBIAN_FRONTEND=noninteractive
ARG BREW_VERSION=3.3.9
RUN useradd -m -s /bin/bash linuxbrew
USER linuxbrew
SHELL ["/bin/bash", "-c"]
WORKDIR /home/linuxbrew
ENV PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH \
    LANG=en_US.UTF-8 \
    HOMEBREW_NO_AUTO_UPDATE=1 \
    HOMEBREW_NO_INSTALL_CLEANUP=1 \
    HOMEBREW_BOTTLE_SOURCE_FALLBACK=1

RUN git clone --branch ${BREW_VERSION} --single-branch --depth 1 https://github.com/Homebrew/brew /home/linuxbrew/.linuxbrew/Homebrew \
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

RUN git clone --single-branch --depth 1 https://github.com/Homebrew/homebrew-core /home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/homebrew/homebrew-core

# Fix developer tool lookup
RUN cd /home/linuxbrew/.linuxbrew/Homebrew && curl https://github.com/digitalspacestdio/brew/commit/e6cc879a79ab05fdb750968430c86b9f76fee833.diff | patch  -p1

# Fix outdated checksum
RUN sed -i 's/6c434a3be59f8f62425b2e3c077e785c9ce30ee5874ea1c270e843f273ba71ee/2303a6acfb6cc533e0e86e8a9d29f7e6079e118b9de3f96e07a71a11c082fa6a/g' /home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/homebrew/homebrew-core/Formula/jpeg.rb

# Fix incorrect condition
RUN sed -i 's/if Hardware::CPU.arm?/if Hardware::CPU.arm? \&\& OS.mac?/g' /home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/homebrew/homebrew-core/Formula/nettle.rb

# Remove gcc dependency (the system gcc will be used)
RUN sed -i 's/depends_on "gcc"/# depends_on "gcc"/g' /home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/homebrew/homebrew-core/Formula/*.rb

# Pcre fix
RUN sed -i 's/ftp.pcre.org/www.mirrorservice.org\/sites\/ftp.exim.org/g' /home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/homebrew/homebrew-core/Formula/pcre.rb

RUN brew install digitalspacestdio/docker-linuxbrew/docker-linuxbrew
RUN brew-build-recursive util-linux coreutils gnu-sed gpatch git unzip bzip2 jq neovim
RUN ln -s $(brew --prefix neovim)/bin/nvim $(brew --prefix)/bin/vim

RUN brew autoremove \
    && brew cleanup \
    && rm -rf /home/linuxbrew/.cache/Homebrew \
    && rm -rf /home/linuxbrew/.linuxbrew/Homebrew/Library/Homebrew/vendor/portable-ruby

FROM digitalspacestudio/debian:gcc-11-ruby-2.6-bullseye
RUN useradd -m -s /bin/bash linuxbrew
USER linuxbrew
WORKDIR /home/linuxbrew
RUN rm -rf /home/linuxbrew/.linuxbrew
COPY --from=builder --chown=linuxbrew:linuxbrew /home/linuxbrew/.linuxbrew /home/linuxbrew/.linuxbrew
RUN echo 'export PATH="/home/linuxbrew/.linuxbrew/sbin:$PATH"' >> /home/linuxbrew/.profile
ENV PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH \
    SHELL=/bin/bash \
    LANG=en_US.UTF-8 \
    EDITOR=micro \
    HOMEBREW_NO_AUTO_UPDATE=1 \
    HOMEBREW_NO_ENV_HINTS=1 \
    HOMEBREW_NO_INSTALL_CLEANUP=1 \
    HOMEBREW_FORCE_BREWED_CURL=1 \
    HOMEBREW_FORCE_BREWED_GIT=1

CMD ["bash"]
