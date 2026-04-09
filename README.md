# ROS2 Docker
ROS2 Gazebo and Foxglove in Docker container

```
docker compose down
docker compose --profile dev build --no-cache
docker compose --profile dev up
```
OR 

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
