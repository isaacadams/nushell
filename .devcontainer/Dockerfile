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
    xz-utils unzip rsync \
    build-essential gcc make libssl-dev pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install Homebrew
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add Homebrew to PATH
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"

# Install Nushell using Homebrew
RUN brew install nushell

# install duckdb
# releases: https://github.com/duckdb/duckdb/releases
ARG DUCKDB_VERSION=v1.2.0
RUN curl -L "https://github.com/duckdb/duckdb/releases/download/${DUCKDB_VERSION}/duckdb_cli-linux-amd64.zip" -o /tmp/duckdb.zip \
    && unzip /tmp/duckdb.zip -d /usr/local/bin \
    && rm -rf /tmp/duckdb.zip

# download and install nupm (Nu package manager)
RUN mkdir -p /source/nupm && \
    git clone https://github.com/nushell/nupm.git /source/nupm

# Make nupm available globally by adding it to config.nu
RUN mkdir -p /root/.config/nushell/nupm
RUN echo 'use /source/nupm/nupm' >> /root/.config/nushell/config.nu

# install nutest
RUN mkdir -p /source/nutest && git clone https://github.com/vyadh/nutest.git /source/nutest
RUN echo 'use /source/nutest/nutest' >> /root/.config/nushell/config.nu

# Set Nushell as the default shell (optional)
SHELL ["/home/linuxbrew/.linuxbrew/bin/nu", "-c"]

RUN use /source/nupm/nupm ; nupm install /source/nupm --force --path

# register the polars plugin
RUN plugin add /home/linuxbrew/.linuxbrew/bin/nu_plugin_polars

# Start an interactive Nushell session by default
CMD ["/home/linuxbrew/.linuxbrew/bin/nu"]
