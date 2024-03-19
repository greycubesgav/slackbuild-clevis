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

## Build instructions

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
upgradepkg --install-new --reinstall /tmp/clevis-20-x86_64-1_SBo.tgz
```