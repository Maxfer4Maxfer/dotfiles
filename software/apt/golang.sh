#!/bin/bash
set -x

echo "----------------golang----------------"

export gopackage="go1.23.3.linux-arm64.tar.gz"
curl -fsSLO https://go.dev/dl/${gopackage}
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf ${gopackage}
rm -f ${gopackage}
