FROM greycubesgav/slackware-docker-base:latest AS builder

# Set our prepended build artifact tag and build dir
ENV TAG='_GG'

# Install the dependancies binaries for the build
ARG JOSE_VESION=jose-12-x86_64-1_GG.tgz
WORKDIR /root/jose/
RUN wget --no-check-certificate https://github.com/greycubesgav/slackbuild-jose/releases/download/main/${JOSE_VESION}
RUN upgradepkg --install-new --reinstall ${JOSE_VESION}

#WORKDIR /root/jq/
#RUN wget --no-check-certificate http://www.slackware.com/~alien/slackbuilds/jq/pkg64/15.0/jq-1.6-x86_64-1alien.txz && \
#wget --no-check-certificate http://www.slackware.com/~alien/slackbuilds/jq/pkg64/15.0/jq-1.6-x86_64-1alien.txz.md5 && \
#md5sum -c jq-1.6-x86_64-1alien.txz.md5
# RUN upgradepkg --install-new --reinstall jq-1.6-x86_64-1alien.txz

#--------------------------------------------------------------
# Build Slackware Package
#--------------------------------------------------------------
# Copy over the build files
COPY LICENSE *.info *.SlackBuild README slack-desc /root/build/

# Grab the source and check the md5
WORKDIR /root/build/
RUN wget --no-check-certificate $(sed -n 's/DOWNLOAD="\(.*\)"/\1/p' *.info)
RUN export pkgname=$(grep 'DOWNLOAD=' *.info| sed 's|.*/||;s|"||g') \
&& export pkgmd5sum=$(sed -n 's/MD5SUM="\(.*\)"/\1/p' *.info) \
&& echo "$pkgmd5sum  $pkgname" > "${pkgname}.md5" \
&& md5sum -c "${pkgname}.md5"

# Build the package
RUN ./*.SlackBuild

#ENTRYPOINT [ "bash" ]

# Create a clean image with only the artifact
FROM scratch AS artifact
COPY --from=builder /tmp/*.tgz .