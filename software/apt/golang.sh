#!/bin/bash
set -x

echo "----------------golang----------------"

gopackage="go1.20.4.linux-amd64.tar.gz"
curl -fsSLO https://go.dev/dl/${gopackage}
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf ${gopackage}
rm -f ${gopackage}
