#!/bin/bash

## Script to compile signal-desktop from/for arm64 packaged for debian
#
## Version 1.0.1
#
# Upstream-Name: Signal-Desktop-arm64
# Source: https://github.com/berbascum/Signal-Desktop-arm64
#
# Copyright (C) 2024 Berbascum <berbascum@ticv.cat>
# All rights reserved.
#
# BSD 3-Clause License


## References:
# https://andreafortuna.org/2019/03/27/how-to-build-signal-desktop-on-linux/
# https://gitlab.com/adamthiede/signal-desktop-builder/-/blob/master/patches/0001-Remove-no-sandbox-patch.patch?ref_type=heads
# https://github.com/BernardoGiordano/signal-desktop-pi4/blob/master/install.sh
# https://github.com/tianon/dockerfiles/blob/master/signal-desktop/Dockerfile

v## System Tray
# apt-get install gnome-shell-extension-appindicator

## Requirements
apt-get install rsync build-essential libssl-dev curl git git-lfs wget vim fuse-overlayfs python3-full locales dialog libcrypto++-dev libcrypto++8 libgtk-3-dev libvips42 libxss-dev snapd bc screen libffi-dev libglib2.0-0 libnss3 libatk1.0-0 libatk-bridge2.0-0 libx11-xcb1 libgdk-pixbuf-2.0-0 libgtk-3-0 libdrm2 libgbm1 ruby ruby-dev curl clang llvm lld clang-tools generate-ninja ninja-build pkg-config tcl
# Optional:
# apt install podman flatpak elfutils slirp4netns rootlesskit binfmt-support flatpak-builder qemu-user-statica 

## Install fpm is required to avoud errors on yanr install
gem install fpm
export USE_SYSTEM_FPM=true ## Should be defined for yarn build
## set PATH
export PATH="/Signal-Desktop/node_modules/.bin:/root/.cargo/bin:/opt/node/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

## Install nvm
curl -o- https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
## source /root/.bashrc required or session restart

## Clone signal desktop
git clone  https://github.com/signalapp/Signal-Desktop.git
cd Signal-Desktop

git-lfs install

## Config sources
#git config --global user.name <user>
#git config --global user.email <email>

## Apply Droidian patches
git apply patches/droidian/7140-1_Fix-settings-window-size-small-screens.patch

<< "DEPRECATED?"
## PATCHES from "https://gitlab.com/adamthiede"
## 1 ## Deprecated? Remove manually Stories from
  ## vim Signal-Desktop/ts/components/NavTabs.tsx(270)
## 2 Patch Minimize-gutter-on-small-screens
  ## vim ts/state/selectors/items.ts
     ## const DEFAULT_PREFERRED_LEFT_PANE_WIDTH = 320>109;
     #git apply patches/arm64/7140_01-Fix-Minimize-gutter-on-small-screens.patch 
## 3 Patch MIN_WIDTH
  ## vim ts/components/LeftPane.stories.tsx
     ## preferredWidthFromStorage: 320>97,
  ## vim ts/util/leftPaneWidth.ts
     # +  return MIN_WIDTH;
  # if (requiresFullWidth || clampedWidth >= SNAP_WIDTH) {
   #  return Math.max(clampedWidth, MIN_FULL_WIDTH);
   #}
     # -  return MIN_WIDTH;
    #git apply atches/arm64/7140_01-Fix-Always-return-MIN_WIDTH-from-storage.patch 
#
# The mock tests are broken on custom arm builds
# Deprecated? sed -r '/mock/d' -i package.json
# Dry run
# Deprecated? sed -r 's#("better-sqlite3": ").*"#\1file:../better-sqlite3"#' -i package.json
DEPRECATED?

## Prepare nvm
nvm use
nvm install
nvm use

## Install yarn
npm install --global yarn

#npm install node-abi@latest

## Disable --no-sandbox on the desktop link
sed -i 's/^                exec += \" --no-sandbox %U\";/                exec += " %U";/g' node_modules/app-builder-lib/out/targets/LinuxTargetHelper.js 

## Ensure required vars export
export PATH="/Signal-Desktop/node_modules/.bin:/root/.cargo/bin:/opt/node/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"
export USE_SYSTEM_FPM=true

yarn install --frozen-lockfile
#### rm -rf ts/test-mock # also broken on arm64
yarn generate
yarn build
