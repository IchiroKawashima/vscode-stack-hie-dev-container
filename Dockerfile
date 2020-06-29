FROM mcr.microsoft.com/vscode/devcontainers/base:0-debian-10

ARG GHC_VERSION=8.8.3

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
   #
   # hls dependencies
   && apt-get -y install --no-install-recommends build-essential libicu-dev libncurses-dev libgmp-dev zlib1g-dev \
   # cleaning up
   && apt-get autoremove -y \
   && apt-get clean -y \
   && rm -rf /var/lib/apt/lists/*
ENV DEBIAN_FRONTEND=dialog

# installing stack
RUN wget https://get.haskellstack.org/stable/linux-x86_64.tar.gz \
    && tar xf linux-x86_64.tar.gz \
    && mv stack-2.3.1-linux-x86_64/stack /usr/local/bin

# Installing hls & hspec-discover
RUN git clone https://github.com/haskell/haskell-language-server --recurse-submodules \
    && cd haskell-language-server \
    #
    # hls
    && stack ./install.hs hls-${GHC_VERSION} && mv /root/.local/bin/* /usr/local/bin \
    # && stack ./install.hs data && mv /root/.hoogle /usr/local/share/hoogle \
    # && ln -s /usr/local/share/hoogle /root/.hoogle && ln -s /usr/local/share/hoogle /home/${USERNAME}/.hoogle \
    && cd ../ && rm -rf haskell-language-server \
    #
    # hspec-discover
    && stack --resolver=ghc-${GHC_VERSION} --local-bin-path="/usr/local/bin" install hspec-discover \
    #
    # cleaning up
    && rm -rf /root/.stack
