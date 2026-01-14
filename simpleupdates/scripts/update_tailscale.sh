#!/bin/bash

# Update Tailscale to version 1.90.6

curl -O https://pkgs.tailscale.com/stable/tailscale_1.90.6_arm.tgz

tar -xzf tailscale_1.90.6_arm.tgz

rm tailscale_1.90.6_arm.tgz

cd /usrdata/tailscale_1.90.6_arm

# Clean up
rm -rf /usrdata/tailscale_1.90.6_arm
