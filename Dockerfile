FROM debian:stretch
LABEL maintainer="Sergey Cherepanov <s@cherepanov.co>"
LABEL name="djocker/linuxbrew"
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
	&& apt-get install -y --no-install-recommends ca-certificates file g++ locales make uuid-runtime git curl \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* \
	&& sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
	&& dpkg-reconfigure locales \
	&& update-locale LANG=en_US.UTF-8 \
	&& useradd -m -s /bin/bash linuxbrew

USER linuxbrew
WORKDIR /home/linuxbrew
ENV LANG=en_US.UTF-8 \
	PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH \
	SHELL=/bin/bash

RUN git clone --branch 2.1.9 https://github.com/Homebrew/brew /home/linuxbrew/.linuxbrew/Homebrew
RUN mkdir -p /home/linuxbrew/.linuxbrew/etc \
    /home/linuxbrew/.linuxbrew/include \
    /home/linuxbrew/.linuxbrew/lib \
    /home/linuxbrew/.linuxbrew/opt \
    /home/linuxbrew/.linuxbrew/sbin \
    /home/linuxbrew/.linuxbrew/share \
    /home/linuxbrew/.linuxbrew/var/homebrew/linked \
    /home/linuxbrew/.linuxbrew/Cellar \
	/home/linuxbrew/.linuxbrew/bin \
	&& ln -s ../Homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/ \
	&& brew config

RUN brew doctor

CMD ["/bin/bash"]