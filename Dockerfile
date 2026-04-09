# -----------------------------
# Base Image
# -----------------------------
FROM ros:jazzy

ENV DEBIAN_FRONTEND=noninteractive

# -----------------------------
# Use bash + pipefail
# -----------------------------
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# -----------------------------
# Base dependencies (cached)
# -----------------------------
RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update && apt-get install -y --no-install-recommends \
    curl \
    gnupg \
    lsb-release \
    software-properties-common \
    supervisor \
    git \
    neovim \
    ripgrep \
    fd-find \
    clangd \
    python3-pip \
    build-essential \
    cmake \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------
# Install Node.js (with npm)
# -----------------------------
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs

# -----------------------------
# Install Node tools (LSP)
# -----------------------------
RUN npm install -g pyright bash-language-server

# -----------------------------
# Gazebo repo
# -----------------------------
RUN mkdir -p /etc/apt/keyrings && \
    curl -sSL https://packages.osrfoundation.org/gazebo.key \
    | gpg --dearmor -o /etc/apt/keyrings/gazebo.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/gazebo.gpg] \
    http://packages.osrfoundation.org/gazebo/ubuntu-stable \
    $(lsb_release -cs) main" \
    > /etc/apt/sources.list.d/gazebo-stable.list

# -----------------------------
# Gazebo + ROS bridge
# -----------------------------
RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update && apt-get install -y --no-install-recommends \
    gz-harmonic \
    ros-jazzy-ros-gz \
    ros-jazzy-ros-gz-bridge \
    ros-jazzy-ros-gz-sim \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------
# ROS tools
# -----------------------------
RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update && apt-get install -y --no-install-recommends \
    ros-jazzy-rmw-cyclonedds-cpp \
    ros-jazzy-slam-toolbox \
    ros-jazzy-nav2-bringup \
    ros-jazzy-foxglove-bridge \
    ros-jazzy-turtlebot3 \
    ros-jazzy-turtlebot3-simulations \
    python3-colcon-common-extensions \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------
# LazyVim install
# -----------------------------
RUN git clone https://github.com/LazyVim/starter /root/.config/nvim && \
    rm -rf /root/.config/nvim/.git

# Allow override via volume
RUN mkdir -p /root/.config/nvim/lua/plugins

# -----------------------------
# Environment
# -----------------------------
ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
ENV LIBGL_ALWAYS_SOFTWARE=1
ENV QT_QPA_PLATFORM=offscreen
ENV GZ_SIM_RENDER_ENGINE=ogre2

# -----------------------------
# ROS auto-source
# -----------------------------
RUN echo "source /opt/ros/jazzy/setup.bash" >> /root/.bashrc

# -----------------------------
# Workspace
# -----------------------------
WORKDIR /workspace

# -----------------------------
# Supervisor config
# -----------------------------
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# -----------------------------
# Default command
# -----------------------------
CMD ["/usr/bin/supervisord"]