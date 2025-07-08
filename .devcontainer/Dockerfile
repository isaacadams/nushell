ARG VARIANT
FROM ubuntu:$VARIANT

# Metadata labels (required for validation)
LABEL Name="nushell" \
      Version="1.0" \
      Description="A nushell environment with nupm and polars installed" \
      Maintainer="Isaac Adams"

# Set noninteractive mode to avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update and install necessary packages
RUN apt update && apt upgrade -y && \
    apt install -y

# Install dependencies
RUN apt update && apt install -y \
    curl wget git \
    xz-utils unzip rsync sudo \
    build-essential gcc make libssl-dev pkg-config \
    && rm -rf /var/lib/apt/lists/*

# install duckdb
# releases: https://github.com/duckdb/duckdb/releases
ARG DUCKDB_VERSION=v1.2.0
RUN curl -L "https://github.com/duckdb/duckdb/releases/download/${DUCKDB_VERSION}/duckdb_cli-linux-amd64.zip" -o /tmp/duckdb.zip \
    && unzip /tmp/duckdb.zip -d /usr/local/bin \
    && rm -rf /tmp/duckdb.zip

# Create a non-root user for Homebrew
RUN useradd -m -s /bin/bash linuxbrew && \
    mkdir -p /etc/sudoers.d && \
    echo 'linuxbrew ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/linuxbrew && \
    chmod 440 /etc/sudoers.d/linuxbrew

# Switch to the linuxbrew user
USER linuxbrew
WORKDIR /home/linuxbrew

# download nupm (Nu package manager)
RUN mkdir -p /home/linuxbrew/source/nupm && \
    git clone https://github.com/nushell/nupm.git /home/linuxbrew/source/nupm

# download nutest
RUN mkdir -p /home/linuxbrew/source/nutest && \
    git clone https://github.com/vyadh/nutest.git /home/linuxbrew/source/nutest

# Install Homebrew
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add Homebrew to PATH
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"

# Install rustup via Homebrew
RUN brew install rustup-init
RUN rustup-init -y
ENV PATH="/home/linuxbrew/.cargo/bin:${PATH}"

# Install Nushell using Homebrew
RUN brew install nushell

# Make nupm and nutest available globally by adding it to config.nu
#USER root
RUN mkdir -p ~/.config/nushell/nupm
RUN echo 'use /home/linuxbrew/source/nupm/nupm' >> ~/.config/nushell/config.nu
RUN echo 'use /home/linuxbrew/source/nutest/nutest' >> ~/.config/nushell/config.nu
#USER linuxbrew

# Set Nushell as the default shell (optional)
SHELL ["/home/linuxbrew/.linuxbrew/bin/nu", "-c"]

RUN use /home/linuxbrew/source/nupm/nupm ; nupm install --path /home/linuxbrew/source/nupm -f

# register the polars plugin
RUN plugin add /home/linuxbrew/.linuxbrew/bin/nu_plugin_polars

# Start an interactive Nushell session by default
CMD ["/home/linuxbrew/.linuxbrew/bin/nu"]
