#!/bin/sh
set -x

echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc

echo "----------------fzf----------------"
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --key-bindings --completion --update-rc

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

echo "----------------go----------------"
go install github.com/jnewmano/grpc-json-prox@latest
go install github.com/jesseduffield/lazygit@latest
go install github.com/jesseduffield/lazydocker@latest
go install github.com/tsenart/vegeta@latest
go install github.com/cortesi/modd/cmd/modd@latest
