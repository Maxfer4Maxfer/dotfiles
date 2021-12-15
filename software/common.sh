#!/bin/sh
set -x

echo "----------------tldr----------------"
tldr --update

echo "----------------helm----------------"
helm repo add bitnami https://charts.bitnami.com/bitnami

echo "----------------krew----------------"
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)

echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> ~/.zshrc
echo 'export KUBECONFIG="$HOME/.kube/config"' >> ~/.zshrc

kubectl krew upgrade
kubectl krew update 

kubectl krew install ctx
kubectl krew install ns
kubectl krew install df-pv
kubectl krew install fuzzy
kubectl krew install images
kubectl krew install open-svc
kubectl krew install tree

echo "----------------git----------------"
git config --global --add url."git@github.com:".insteadOf "https://github.com/"

echo "----------------go----------------"
echo 'path=($HOME/go/bin $path)' >> ~/.zshrc
echo 'path=(/usr/local/go/bin $path)' >> ~/.zshrc
# echo 'export GOROOT="/usr/local/go"' >> ~/.zshrc
go get -u github.com/jnewmano/grpc-json-prox
go get -u github.com/jesseduffield/lazygit
go get github.com/jesseduffield/lazydocker
go get -u github.com/tsenart/vegeta
env GO111MODULE=on go get github.com/cortesi/modd/cmd/modd
