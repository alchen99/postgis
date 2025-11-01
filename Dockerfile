FROM postgis/postgis:17-3.5

USER root

# Configure apt caching for use with BuildKit.
# The default Debian Docker image has special apt config to clear caches,
# but if we are using --mount=type=cache, then we want to keep the files.
# https://github.com/debuerreotype/debuerreotype/blob/master/scripts/debuerreotype-minimizing-config
RUN set -exu && \
    rm -f /etc/apt/apt.conf.d/docker-clean && \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache && \
    echo 'Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/99use-gzip-compression

RUN --mount=type=cache,id=apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=apt-lib,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,id=debconf,target=/var/cache/debconf,sharing=locked \
    apt-get update && apt-get upgrade && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get -y install -y -qq --no-install-recommends postgis && rm -rf /var/lib/apt/lists/*

