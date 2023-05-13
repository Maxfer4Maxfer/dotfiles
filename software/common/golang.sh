#!/bin/sh
set -x

echo "----------------golang----------------"

go install github.com/jnewmano/grpc-json-prox@latest
go install github.com/jesseduffield/lazygit@latest
go install github.com/jesseduffield/lazydocker@latest
go install github.com/tsenart/vegeta@latest
go install github.com/cortesi/modd/cmd/modd@latest
go install github.com/ktr0731/evans@latest
