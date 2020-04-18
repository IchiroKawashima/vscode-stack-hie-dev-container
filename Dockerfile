FROM mcr.microsoft.com/vscode/devcontainers/base:0-debian-10

ARG STACK_VERSION=2.1.3
ARG HIE_VERSION=8.6.5

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
   #
   # For stack
   && apt-get -y install --no-install-recommends netbase build-essential \
   # For hie
   && apt-get -y install --no-install-recommends libicu-dev libncurses-dev libgmp-dev zlib1g-dev \
   # Clean up
   && apt-get autoremove -y \
   && apt-get clean -y \
   && rm -rf /var/lib/apt/lists/*
ENV DEBIAN_FRONTEND=dialog

# Install stack
RUN wget "https://github.com/commercialhaskell/stack/releases/download/v${STACK_VERSION}/stack-${STACK_VERSION}-linux-x86_64.tar.gz" \
    && tar xf "stack-${STACK_VERSION}-linux-x86_64.tar.gz" \
    && rm "stack-${STACK_VERSION}-linux-x86_64.tar.gz" \
    && mv "stack-${STACK_VERSION}-linux-x86_64/stack" "/usr/local/bin" \
    && rm -rf "stack-${STACK_VERSION}-linux-x86_64"

# Install hie & hspec-discover
RUN git clone https://github.com/haskell/haskell-ide-engine --recurse-submodules \
    && cd haskell-ide-engine \
    #
    # Install hie
    && stack ./install.hs hie-${HIE_VERSION} && mv /root/.local/bin/* /usr/local/bin \
    && stack ./install.hs data && mv /root/.hoogle /usr/local/share/hoogle \
    && ln -s /usr/local/share/hoogle /root/.hoogle && ln -s /usr/local/share/hoogle /home/${USERNAME}/.hoogle \
    && cd ../ && rm -rf haskell-ide-engine \
    #
    # Install hspec-discover
    && stack --resolver=ghc-${HIE_VERSION} --local-bin-path="/usr/local/bin" install hspec-discover \
    #
    # Clean up
    && rm -rf /root/.stack
