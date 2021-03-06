# vscode-stack-hie-dev-container

![Docker](https://github.com/IchiroKawashima/vscode-stack-hie-dev-container/workflows/Docker/badge.svg)

A debian-based [vscode development container](https://github.com/microsoft/vscode-dev-containers) for haskell which includes ghc, [stack](https://docs.haskellstack.org/en/stable/README/) and [haskell-ide-engine](https://github.com/haskell/haskell-ide-engine).

See [microsoft/vscode-dev-containers](https://github.com/microsoft/vscode-dev-containers) for more information.

## Usage

### Ensure that your docker has loged in to GitHub Packages

You need to get a personal access token for your docker even for pulling images from GitHub!

Please check [About GitHub Packages](https://help.github.com/en/packages/publishing-and-managing-packages/about-github-packages#about-tokens).

### Put `.devcontainer/devcontainer.json` into your repository

The contents of the file is like this:

```json:.devcontainer/devcontainer.json
{
    "name": "<container name>",
    "image": "docker.pkg.github.com/ichirokawashima/vscode-stack-hie-dev-container/stack-hie-<hie-version>:latest",
    "runArgs": [],
    // "remoteUser": "vscode",
    "extensions": [
        "alanz.vscode-hie-server"
    ]
}
```

### Open a container in vscode

Open the command palette and execute the following command in vscode.

```text
>Remote-Containers:Rebuild and Reopen in Container
```

### Work on your project

Happy Haskell Hacking!!

## Note

- The container works for both of `root` and non-root user (i.e. `vscode`)
- All executables, such as `stack`, `hie` and `hspec-discover` are located in `/usr/local/bin` for sharing them between `root` and `vscode`
- All `stack` caches are eliminated for the reduction of the image size, so the image does not have even a ghc compiler.

## Alternatives

- [hmemcpy/haskell-hie-devcontainer](https://github.com/hmemcpy/haskell-hie-devcontainer) is a official image based on Nix.
