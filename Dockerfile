# Dockerfile for Neovim Sandbox

# Use an official lightweight Linux distribution
FROM ubuntu:latest

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    curl \
    git \
    python3 \
    python3-pip \
    nodejs \
    npm \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Set root password
RUN echo 'root:root' | chpasswd

# Install Neovim from GitHub releases
RUN curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz && \
    tar xzf nvim-linux64.tar.gz -C /opt && \
    ln -s /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim && \
    rm nvim-linux64.tar.gz

# Set up a non-root user for running Neovim
RUN useradd -ms /bin/bash devuser && mkdir -p /home/devuser/.local/share/nvim/site/autoload && chown -R devuser:devuser /home/devuser

# Switch to the non-root user
USER devuser

# Install vim-plug plugin manager as non-root user
RUN curl -fLo /home/devuser/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Create config directory for Neovim
RUN mkdir -p /home/devuser/.config/nvim

# Copy initial configuration (optional)
COPY init.vim /home/devuser/.config/nvim/init.vim

# Set up entrypoint
# ENTRYPOINT ["nvim"]
