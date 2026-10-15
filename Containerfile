ARG ALPINE_VERSION=edge

FROM alpine:${ALPINE_VERSION}

# Install base packages
RUN apk add --no-cache \
    alsa-lib-dev \
    bash \
    bubblewrap \
    socat \
    curl \
    pkgconf \
    python3 \
    rustup \
    sudo \
    uv

# Install additional dev packages
COPY packages.txt /opt/packages.txt
RUN apk add --no-cache $(cat /opt/packages.txt)

# Create user and group
ARG UID=1000
ARG GID=1000
RUN addgroup -g "${GID}" vibe \
    && adduser -u "${UID}" -G vibe -D vibe
COPY sudoers /etc/sudoers.d/vibe

# Install Rust toolchain using rustup
USER root
RUN su - vibe -c "rustup-init -y --default-toolchain stable --profile default" \
    && su - vibe -c "source /home/vibe/.cargo/env && rustup component add rustfmt clippy"
USER ${UID}:${GID}

ENV PATH="/home/vibe/.local/bin:/home/vibe/.cargo/bin:${PATH}"

# Install mistral-vibe using uv
RUN export RUSTFLAGS="-C target-feature=-crt-static"; uv tool install mistral-vibe

ENV BASH_ENV=/home/vibe/.bash_environment
COPY environment $BASH_ENV
RUN mkdir -p /home/vibe/.config /home/vibe/.vibe
WORKDIR /projects
ENTRYPOINT ["/home/vibe/.local/bin/vibe"]
