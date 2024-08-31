# slackbuild-clevis
Slackware Builds script to build a slackware package of the clevis application, require by tang luks remote disk decryption


## Application description
Clevis is a framework for automated decryption. It allows you to encrypt
data using sophisticated unlocking policies which enable decryption to
occur automatically.

The clevis package provides basic encryption/decryption policy support.
Users can use this directly; but most commonly, it will be used as a
building block for other packages. For example, see the clevis-luks
and clevis-dracut packages for automatic root volume unlocking of LUKSv1
volumes during early boot.

## Docker Based Build Instructions

The following instructions show how to build this package using the included Dockerfile.

Docker needs to be installed and running before running the make command.

The final artifact will be copied to a new ./pkgs directory

```bash
# Clone the git repo
git clone https://github.com/greycubesgav/slackbuild-clevis
cd slackbuild-clevis
make docker-artifact-build
# Slackware package will be created in ./pkgs
```

## Manual Build Instructions Under Slackware

The following instructs show how to build the package locally under Slackware.

```bash
# Clone the git repo
git clone https://github.com/greycubesgav/slackbuild-clevis
cd slackbuild-clevis
# Grab the url from the .info file and download it
wget $(sed -n 's/DOWNLOAD="\(.*\)"/\1/p' clevis.info)
./clevis.SlackBuild
# Slackware package will be created in /tmp
```

## Install instructions

Once the package is built, it can be installed with

```bash
upgradepkg --install-new --reinstall /pkgs/clevis-*.tgz
```