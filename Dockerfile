FROM mcr.microsoft.com/vscode/devcontainers/base:0-debian-10

ARG STACK_VERSION=2.1.3
ARG HIE_VERSION=8.6.5

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
   #
   # stack
   && apt-get -y install --no-install-recommends haskell-stack \
   # hie dependencies
   && apt-get -y install --no-install-recommends libicu-dev libncurses-dev libgmp-dev zlib1g-dev \
   # cleaning up
   && apt-get autoremove -y \
   && apt-get clean -y \
   && rm -rf /var/lib/apt/lists/*
ENV DEBIAN_FRONTEND=dialog

# Upgrading stack
RUN stack update \
    && stack upgrade

# Installing hie & hspec-discover
RUN git clone https://github.com/haskell/haskell-ide-engine --recurse-submodules \
    && cd haskell-ide-engine \
    #
    # hie
    && stack ./install.hs hie-${HIE_VERSION} && mv /root/.local/bin/* /usr/local/bin \
    && stack ./install.hs data && mv /root/.hoogle /usr/local/share/hoogle \
    && ln -s /usr/local/share/hoogle /root/.hoogle && ln -s /usr/local/share/hoogle /home/${USERNAME}/.hoogle \
    && cd ../ && rm -rf haskell-ide-engine \
    #
    # hspec-discover
    && stack --resolver=ghc-${HIE_VERSION} --local-bin-path="/usr/local/bin" install hspec-discover \
    #
    # cleaning up
    && rm -rf /root/.stack
