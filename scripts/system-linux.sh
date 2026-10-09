#!/usr/bin/env bash
# Headless dev VM (Ubuntu in UTM/QEMU, virtio disks, 8 GB RAM): memory, I/O and docker tuning,
# and removal of what a server VM never uses (packages/apt-purge.txt). Opt-in: ./install.sh system.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

# put <file> <content>: write a root-owned config file.
put() { sudo mkdir -p "${1%/*}" && printf '%s\n' "$2" | sudo tee "$1" >/dev/null; }

log "zram swap in front of the swap file"
sudo apt-get install -y -qq zram-tools
put /etc/default/zramswap 'ALGO=zstd
PERCENT=50
PRIORITY=100'
sudo systemctl restart zramswap

log "sysctl"
put /etc/sysctl.d/99-devstation.conf '# zram is cheap swap: move cold pages there early, read them back one page at a time
vm.swappiness = 150
vm.page-cluster = 0
# gopls, docker, file watchers across ~300 repos
fs.inotify.max_user_watches = 524288
fs.inotify.max_user_instances = 1024'
sudo sysctl --system >/dev/null

log "virtio disks: no I/O scheduler in the guest"
put /etc/udev/rules.d/60-virtio-scheduler.rules '# The host schedules the I/O; bfq in the guest only costs CPU
ACTION=="add|change", KERNEL=="vd[a-z]", ATTR{queue/scheduler}="none"'
sudo udevadm control --reload
sudo udevadm trigger --subsystem-match=block --action=change

log "docker: bounded logs and build cache (applies on the next docker restart)"
if [ -s /etc/docker/daemon.json ]; then
	warn "/etc/docker/daemon.json exists, left as is"
else
	put /etc/docker/daemon.json '{
  "log-driver": "local",
  "log-opts": { "max-size": "10m", "max-file": "3" },
  "builder": { "gc": { "enabled": true, "defaultKeepStorage": "10GB" } }
}'
fi
sudo dockerd --validate --config-file /etc/docker/daemon.json

log "journald capped at 300M"
put /etc/systemd/journald.conf.d/size.conf '[Journal]
SystemMaxUse=300M'
sudo systemctl restart systemd-journald

log "purge what a headless VM never uses"
mapfile -t purge < <(list "$DOTFILES/packages/apt-purge.txt" | installed)
if [ ${#purge[@]} -gt 0 ]; then
	# Their reverse deps include metapackages (ubuntu-server, ubuntu-desktop): pin what those pull in
	# and we keep (lvm2 holds the root fs, NetworkManager the network) so autoremove leaves it alone.
	mapfile -t keep < <({
		printf '%s\n' network-manager openssh-server systemd-oomd zip unzip software-properties-common
		apt-cache depends ubuntu-server 2>/dev/null | awk '/Depends:/{print $2}'
	} | grep -vxF -f <(list "$DOTFILES/packages/apt-purge.txt") | sort -u | installed)
	sudo apt-mark manual "${keep[@]}" >/dev/null
	sudo apt-get purge -y -qq --autoremove "${purge[@]}"
	sudo systemctl reset-failed
fi
mapfile -t leftovers < <(dpkg -l | awk '/^rc/{print $2}')
[ ${#leftovers[@]} -eq 0 ] || sudo dpkg --purge "${leftovers[@]}"
[ ! -d /etc/cloud ] || sudo touch /etc/cloud/cloud-init.disabled # installed already, nothing left for it
sudo apt-get clean

swapon --show
