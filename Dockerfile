# syntax=docker/dockerfile:1.6

FROM ros:jazzy

ENV DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# -----------------------------
# Base dependencies (NO apt cache mount ❗)
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
# Neovim (arch-safe)
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
# Node + LSP tools
# -----------------------------
RUN set -eux; \
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -; \
    apt-get update; \
    apt-get install -y nodejs; \
    npm install -g pyright bash-language-server; \
    npm cache clean --force; \
    rm -rf /var/lib/apt/lists/*

# -----------------------------
# Gazebo repo
# -----------------------------
RUN set -eux; \
    mkdir -p /etc/apt/keyrings; \
    curl -sSL https://packages.osrfoundation.org/gazebo.key \
    | gpg --dearmor -o /etc/apt/keyrings/gazebo.gpg; \
    echo "deb [signed-by=/etc/apt/keyrings/gazebo.gpg] \
    http://packages.osrfoundation.org/gazebo/ubuntu-stable \
    $(lsb_release -cs) main" \
    > /etc/apt/sources.list.d/gazebo-stable.list

# -----------------------------
# ROS + Gazebo (single layer)
# -----------------------------
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        gz-harmonic \
        ros-jazzy-ros-gz \
        ros-jazzy-ros-gz-bridge \
        ros-jazzy-ros-gz-sim \
        ros-jazzy-rmw-cyclonedds-cpp \
        ros-jazzy-slam-toolbox \
        ros-jazzy-nav2-bringup \
        ros-jazzy-foxglove-bridge \
        ros-jazzy-turtlebot3 \
        ros-jazzy-turtlebot3-simulations \
        python3-colcon-common-extensions \
    ; \
    rm -rf /var/lib/apt/lists/*

# -----------------------------
# LazyVim install (cached safely)
# -----------------------------
RUN git clone https://github.com/LazyVim/starter /root/.config/nvim && \
    rm -rf /root/.config/nvim/.git

# -----------------------------
# Lazy plugins (SAFE cache mount)
# -----------------------------
RUN --mount=type=cache,target=/root/.local/share/nvim \
    --mount=type=cache,target=/root/.cache/nvim \
    nvim --headless "+Lazy! sync" +qa

# -----------------------------
# Environment
# -----------------------------
ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
ENV LIBGL_ALWAYS_SOFTWARE=1
ENV QT_QPA_PLATFORM=offscreen
ENV GZ_SIM_RENDER_ENGINE=ogre2

# -----------------------------
# ROS setup
# -----------------------------
RUN echo "source /opt/ros/jazzy/setup.bash" >> /root/.bashrc && \
    echo "source /workspace/install/setup.bash 2>/dev/null || true" >> /root/.bashrc

WORKDIR /workspace

# -----------------------------
# Supervisor
# -----------------------------
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord"]