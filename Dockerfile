# syntax=docker/dockerfile:1.6

# -----------------------------
# Base Image
# -----------------------------
FROM ros:jazzy

ENV DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# -----------------------------
# Base dependencies (CI SAFE)
# -----------------------------
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        curl \
        gnupg \
        lsb-release \
        software-properties-common \
        supervisor \
        git \
        ripgrep \
        clangd \
        python3-pip \
        build-essential \
        cmake \
        ca-certificates \
    ; \
    rm -rf /var/lib/apt/lists/*

# -----------------------------
# Neovim (latest, arch-safe)
# -----------------------------
RUN set -eux; \
    ARCH=$(uname -m); \
    if [ "$ARCH" = "x86_64" ]; then NVIM_ARCH="nvim-linux-x86_64"; \
    elif [ "$ARCH" = "aarch64" ]; then NVIM_ARCH="nvim-linux-arm64"; \
    else echo "Unsupported arch: $ARCH"; exit 1; fi; \
    curl -LO https://github.com/neovim/neovim/releases/latest/download/${NVIM_ARCH}.tar.gz; \
    tar -C /opt -xzf ${NVIM_ARCH}.tar.gz; \
    ln -s /opt/${NVIM_ARCH}/bin/nvim /usr/local/bin/nvim; \
    rm ${NVIM_ARCH}.tar.gz

# -----------------------------
# Node.js + LSP tools
# -----------------------------
RUN set -eux; \
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -; \
    apt-get update; \
    apt-get install -y nodejs; \
    npm install -g pyright bash-language-server; \
    npm cache clean --force; \
    rm -rf /var/lib/apt/lists/*

# -----------------------------
# ROS + Gazebo + tools
# -----------------------------
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ros-jazzy-ros-gz \
        ros-jazzy-ros-gz-sim \
        ros-jazzy-ros-gz-bridge \
        \
        ros-jazzy-rmw-cyclonedds-cpp \
        ros-jazzy-slam-toolbox \
        ros-jazzy-nav2-bringup \
        ros-jazzy-foxglove-bridge \
        \
        ros-jazzy-turtlebot3 \
        ros-jazzy-turtlebot3-simulations \
        ros-jazzy-turtlebot3-description \
        \
        ros-jazzy-teleop-twist-keyboard \
        python3-colcon-common-extensions \
    ; \
    rm -rf /var/lib/apt/lists/*

# -----------------------------
# LazyVim install (NO plugins)
# -----------------------------
RUN git clone https://github.com/LazyVim/starter /root/.config/nvim && \
    rm -rf /root/.config/nvim/.git

# Minimal init
RUN nvim --headless "+qall" || true

# Allow plugin overrides
RUN mkdir -p /root/.config/nvim/lua/plugins

# -----------------------------
# LazyVim bootstrap (AUTO INSTALL)
# -----------------------------
RUN printf '#!/usr/bin/env bash\n\
if [ ! -d "/root/.local/share/nvim/lazy" ]; then\n\
  echo "Installing LazyVim plugins (first run)..."\n\
  nvim --headless "+Lazy! sync" +qa || true\n\
else\n\
  echo "LazyVim plugins already installed."\n\
fi\n' > /usr/local/bin/nvim-bootstrap && chmod +x /usr/local/bin/nvim-bootstrap

# -----------------------------
# ROS + Python environment (CRITICAL)
# -----------------------------
RUN echo "source /opt/ros/jazzy/setup.bash" >> /root/.bashrc && \
    echo "source /workspace/install/setup.bash 2>/dev/null || true" >> /root/.bashrc && \
    echo "export PYTHONPATH=/opt/ros/jazzy/lib/python3.12/site-packages:\$PYTHONPATH" >> /root/.bashrc && \
    echo "export PYTHONPATH=/workspace/install/lib/python3.12/site-packages:\$PYTHONPATH" >> /root/.bashrc && \
    echo "/usr/local/bin/nvim-bootstrap" >> /root/.bashrc

# Also set globally (not just bash)
ENV PYTHONPATH=/opt/ros/jazzy/lib/python3.12/site-packages:/workspace/install/lib/python3.12/site-packages

# -----------------------------
# Runtime environment
# -----------------------------
ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
ENV LIBGL_ALWAYS_SOFTWARE=1
ENV QT_QPA_PLATFORM=offscreen
ENV GZ_SIM_RENDER_ENGINE=ogre2

# -----------------------------
# Workspace
# -----------------------------
WORKDIR /workspace

# -----------------------------
# Supervisor config
# -----------------------------
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# -----------------------------
# Start
# -----------------------------
CMD ["/usr/bin/supervisord"]