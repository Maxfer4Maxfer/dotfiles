# Clean Ubuntu with a sudo user. `make test` installs the dotfiles into a throwaway container
# from this image and runs the smoke test; nothing is left on disk afterwards.
FROM ubuntu:24.04

RUN apt-get update -qq && apt-get install -y -qq sudo git curl ca-certificates && \
    rm -rf /var/lib/apt/lists/* && \
    userdel -r ubuntu && \
    useradd -m -s /bin/bash maxim && echo 'maxim ALL=(ALL) NOPASSWD:ALL' >/etc/sudoers.d/maxim

USER maxim
ENV USER=maxim HOME=/home/maxim
WORKDIR /home/maxim
COPY --chown=maxim run.sh /usr/local/bin/dotfiles-test
CMD ["dotfiles-test"]
