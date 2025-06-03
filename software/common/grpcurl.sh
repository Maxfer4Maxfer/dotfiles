#!/bin/sh
set -x

echo "----------------grpcurl----------------"

curl -sSL "https://github.com/fullstorydev/grpcurl/releases/download/v1.9.2/grpcurl_1.9.2_linux_arm64.tar.gz" | sudo tar -xz -C /usr/local/bin
