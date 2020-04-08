FROM debian:buster-slim

ARG STACK_VERSION=2.1.3
ARG HIE_VERSION=8.6.5

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Set to false to skip installing zsh and Oh My ZSH!
ARG INSTALL_ZSH="true"

# Location and expected SHA for common setup script - SHA generated on release
ARG COMMON_SCRIPT_SOURCE="https://raw.githubusercontent.com/microsoft/vscode-dev-containers/master/script-library/common-debian.sh"
ARG COMMON_SCRIPT_SHA="dev-mode"

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Configure apt and install packages
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils dialog wget ca-certificates 2>&1 \
    #
    # Verify git, common tools / libs installed, add/modify non-root user, optionally install zsh
    && wget -q -O /tmp/common-setup.sh $COMMON_SCRIPT_SOURCE \
    && if [ "$COMMON_SCRIPT_SHA" != "dev-mode" ]; then echo "$COMMON_SCRIPT_SHA /tmp/common-setup.sh" | sha256sum -c - ; fi \
    && /bin/bash /tmp/common-setup.sh "$INSTALL_ZSH" "$USERNAME" "$USER_UID" "$USER_GID" \
    && rm /tmp/common-setup.sh \
    #
    # For stack
    && apt-get -y install --no-install-recommends netbase build-essential \
    # For hie
    && apt-get -y install --no-install-recommends libicu-dev libncurses-dev libgmp-dev zlib1g-dev \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog

# install stack
RUN wget "https://github.com/commercialhaskell/stack/releases/download/v${STACK_VERSION}/stack-${STACK_VERSION}-linux-x86_64.tar.gz" \
    && tar xf "stack-${STACK_VERSION}-linux-x86_64.tar.gz" \
    && rm "stack-${STACK_VERSION}-linux-x86_64.tar.gz" \
    && mv "stack-${STACK_VERSION}-linux-x86_64/stack" "/usr/local/bin" \
    && rm -rf "stack-${STACK_VERSION}-linux-x86_64" \
    && stack --resolver=ghc-${HIE_VERSION} setup

# install hie
RUN git clone https://github.com/haskell/haskell-ide-engine --recurse-submodules \
    && cd haskell-ide-engine \
    && stack ./install.hs hie-${HIE_VERSION} && mv /root/.local/bin/* /usr/local/bin \
    && stack ./install.hs data && mv /root/.hoogle /usr/local/share/hoogle \
    && ln -s /usr/local/share/hoogle /root/.hoogle && ln -s /usr/local/share/hoogle /home/${USERNAME}/.hoogle \
    && cd ../ && rm -rf haskell-ide-engine

RUN stack --resolver=ghc-${HIE_VERSION} --local-bin-path="/usr/local/bin" install hspec-discover

# clean up
RUN rm -rf /root/.stack
