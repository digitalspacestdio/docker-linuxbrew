#!/bin/bash
cd $(dirname $0)
BREW_VERSION=$(curl -L --silent https://api.github.com/repos/Homebrew/brew/releases | jq -r '.[].tag_name' | head -1)
docker build --build-arg BREW_VERSION=${BREW_VERSION} -t digitalspacestudio/linuxbrew:${BREW_VERSION} .
docker tag "digitalspacestudio/linuxbrew:${BREW_VERSION}" "digitalspacestudio/linuxbrew:latest"
docker push "digitalspacestudio/linuxbrew:${BREW_VERSION}"
docker push "digitalspacestudio/linuxbrew:latest"