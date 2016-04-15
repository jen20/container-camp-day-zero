#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y curl sqlite3

echo "Downloading PowerDNS .deb..."
curl -O https://downloads.powerdns.com/releases/deb/pdns-static_3.4.7-1_amd64.deb
echo "Installing PowerDNS .deb..."
dpkg -i pdns-static_3.4.7-1_amd64.deb
echo "Deleting PowerDNS .deb..."
rm pdns-static_3.4.7-1_amd64.deb

echo "Creating PowerDNS database..."
mkdir -p /var/lib/powerdns
sqlite3 /var/lib/powerdns/pdns.db < /tmp/powerdns.sql
