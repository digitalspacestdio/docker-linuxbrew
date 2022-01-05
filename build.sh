#!/bin/bash
cd $(dirname $0)
BREW_VERSION=$(curl -L --silent https://api.github.com/repos/Homebrew/brew/releases | jq -r '.[].tag_name' | head -1)
docker buildx build --push --platform linux/amd64,linux/arm64 --build-arg BREW_VERSION=${BREW_VERSION} -t "digitalspacestudio/linuxbrew:latest" -t digitalspacestudio/linuxbrew:${BREW_VERSION} .
