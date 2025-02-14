ARG DOCKER_FULL_BASE_IMAGE_NAME=greycubesgav/slackware-docker-base:aclemons-current
FROM ${DOCKER_FULL_BASE_IMAGE_NAME} AS builder

ARG TAG='_SL-CUR_GG' VERSION=20 BUILD=1

# Install the dependancies binaries for the build

COPY src/jose/jose-*${TAG}.tgz /root/jose/
RUN installpkg /root/jose/jose-*${TAG}.tgz
RUN jose alg

COPY src/luksmeta/luksmeta-*.tgz /root/luksmeta/
RUN installpkg /root/luksmeta/luksmeta-*.tgz

# Copy over the build files
COPY src/clevis/ /root/build-clevis/
WORKDIR /root/build-clevis/
# Update the jose.info file to match the version we're building
RUN sed -i "s|VERSION=.*|VERSION=\"${VERSION}\"|" clevis.info && export MD5SUM=$(md5sum jose-${VERSION}.tar.xz | cut -d ' ' -f 1) && sed -i "s|_MD5SUM_|${MD5SUM}|" clevis.info
# Build the package
RUN VERSION="$VERSION" TAG="$TAG" BUILD="$BUILD" ./clevis.SlackBuild
RUN installpkg /tmp/clevis-${VERSION}*.tgz

ENTRYPOINT [ "bash" ]

# Create a clean image with only the artifact
FROM scratch AS artifact
COPY --from=builder /tmp/clevis-*.tgz .
