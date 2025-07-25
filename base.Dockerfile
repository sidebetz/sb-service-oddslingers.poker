# Base image
FROM ubuntu:22.04

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Configuration defaults
ENV PYTHON_VERSION="3.7"

# Setup system environment variables
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install dependencies, Python 3.7, and Doppler CLI
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg && \
    # Add Python PPA
    mkdir -p /etc/apt/keyrings && \
    curl -sSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xF23C5A6CF475977595C89F51BA6932366A755776" | gpg --dearmor -o /etc/apt/keyrings/deadsnakes-ppa.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/deadsnakes-ppa.gpg] http://ppa.launchpad.net/deadsnakes/ppa/ubuntu jammy main" > /etc/apt/sources.list.d/deadsnakes-ppa.list && \
    # Add Doppler repo
    curl -sLf --retry 3 --tlsv1.2 --proto "=https" 'https://packages.doppler.com/public/cli/gpg.DE2A644112345678.key' | gpg --dearmor -o /etc/apt/keyrings/doppler-cli.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/doppler-cli.gpg] https://packages.doppler.com/public/cli/deb/debian any-version main" > /etc/apt/sources.list.d/doppler-cli.list && \
    # Update package lists with new repos
    apt-get update && \
    # Install final packages
    apt-get install -y --no-install-recommends \
    python${PYTHON_VERSION} \
    python${PYTHON_VERSION}-venv \
    python${PYTHON_VERSION}-dev \
    libpq-dev \
    fish \
    gosu \
    build-essential \
    supervisor \
    doppler && \
    # Clean up
    rm -rf /var/lib/apt/lists/*

# Install pip
RUN curl -sS https://bootstrap.pypa.io/pip/3.7/get-pip.py | python${PYTHON_VERSION}

# Verify installation
RUN python${PYTHON_VERSION} --version

