# ROS2 Docker
ROS2 Gazebo and Foxglove in Docker container

```
git clone https://github.com/meanOtaku/gazebo_ros2_full.git
```

```
docker compose down
docker compose --profile dev build --no-cache
docker compose --profile dev up
```
OR 

Create this project.

```
/Ros_Project/
 ├── nvim
 ├── ros2_ws
    └── src
 ├── docker-compose.yml
 └── supervisord.conf
```
Inside Ros_Project copy:
1. docker-compose.yml
2. supervisord.conf
3. nvim

```
docker pull ghcr.io/meanotaku/gazebo_ros2_full:latest
docker compose --profile prod up
```

```
docker exec -it ros2_gz bash
```

inside container

```
supervisorctl status
```
