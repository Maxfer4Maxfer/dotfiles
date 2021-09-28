#!/bin/sh
set -x

echo "----------------krew----------------"
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.tar.gz" &&
  tar zxvf krew.tar.gz &&
  KREW=./krew-"${OS}_${ARCH}" &&
  "$KREW" install krew
)

echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> /.zshrc

kubectl krew upgrade
kubectl krew update 

kubectl krew install ctx
kubectl krew install ns


echo "----------------go----------------"
go get -u github.com/jnewmano/grpc-json-prox
go get -u github.com/jesseduffield/lazygit
go get -u github.com/tsenart/vegeta
env GO111MODULE=on go get github.com/cortesi/modd/cmd/modd
