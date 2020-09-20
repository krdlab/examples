FROM ubuntu

RUN apt-get update && apt-get -y upgrade

RUN apt-get -y install xz-utils curl man less

RUN useradd -m student

RUN mkdir -m 0755 /nix && chown student /nix

USER student
ENV USER=student
ENV HOME=/home/student
WORKDIR $HOME

RUN ["/bin/bash", "-c", "sh <(curl -L https://nixos.org/nix/install)"]

RUN echo "if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi" >> .bashrc
