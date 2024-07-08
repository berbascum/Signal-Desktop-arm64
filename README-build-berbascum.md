# Signal Desktop compilation for arm64 devices with small screens

## References
[GitHub Signal-Desktop](https://github.com/signalapp/Signal-Desktop)
[Andrea Fortuna](https://andreafortuna.org/2019/03/27/how-to-build-signal-desktop-on-linux/)
[Adam Teide](https://gitlab.com/adamthiede/signal-desktop-builder/-/blob/master/patches/0001-Remove-no-sandbox-patch.patch?ref_type=heads)
[Bernardo Giordano](https://github.com/BernardoGiordano/signal-desktop-pi4)
[Tianon](https://github.com/tianon/dockerfiles/blob/master/signal-desktop/Dockerfile)

## Build environment
The tested build environment is a standard Debian Bookworm arm64 chroot installed with debootstrap with the apt requisites installed

### Apt prerquisites
```
apt-get install rsync build-essential libssl-dev curl git git-lfs wget vim fuse-overlayfs python3-full locales dialog libcrypto++-dev libcrypto++8 libgtk-3-dev libvips42 libxss-dev snapd bc screen libffi-dev libglib2.0-0 libnss3 libatk1.0-0 libatk-bridge2.0-0 libx11-xcb1 libgdk-pixbuf-2.0-0 libgtk-3-0 libdrm2 libgbm1 ruby ruby-dev curl clang llvm lld clang-tools generate-ninja ninja-build pkg-config tcl
```

### fpm
```
gem install fpm
export USE_SYSTEM_FPM=true ## Should be defined for yarn build
```

### set PATH (not sure if required)
```
export PATH="/Signal-Desktop/node_modules/.bin:/root/.cargo/bin:/opt/node/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"
```

### Install nvm
```
curl -o- https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
```

NOTE: source /root/.bashrc required or session restart

## Prepare signal desktop source
```
git clone  https://github.com/signalapp/Signal-Desktop.git && cd Signal-Desktop
git-lfs install
```

### Config git user info if needed
```
git config --global user.name <user>
git config --global user.email <email>
```

### Select a version to build
```
git checkout <version_tag>
```

### Apply droidian patches
Apply the patches in patches/droidian dir using git apply

### Prepare nvm
```
nvm use
nvm install
nvm use
```

### Install yarn
```
npm install --global yarn
```

### Ensure system fpm
```
export USE_SYSTEM_FPM=true
```

## Configure
In this step, the patches are applied
```
yarn install --frozen-lockfile
```
Disable --no-sandbox

```
sed -i 's/^                exec += \" --no-sandbox %U\";/                exec += " %U";/g' node_modules/app-builder-lib/out/targets/LinuxTargetHelper.js 
```

## Compilation
```
## Compilation
yarn generate
yarn build
```

## Compilation errors
There is some known compilation errors

### Error: node-abi
> Error: Could not detect abi for version 30.0.9 and runtime electron: Is not a trouble for the compilation.

## GUI errors

### Droidian scale 300
When using Phosh with scale 300, the scale needs to be adjusted to 75% in the signal desktop settings

