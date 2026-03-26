import rclpy
from rclpy.node import Node
from turtlesim.msg import Pose
from visualization_msgs.msg import Marker
from geometry_msgs.msg import TransformStamped
import tf2_ros
import math

class Turtle3D(Node):
    def __init__(self):
        super().__init__('turtle_3d')

        self.sub = self.create_subscription(
            Pose, '/turtle1/pose', self.callback, 10)

        self.marker_pub = self.create_publisher(
            Marker, '/turtle_marker', 10)

        self.tf_broadcaster = tf2_ros.TransformBroadcaster(self)

    def callback(self, msg):
        now = self.get_clock().now().to_msg()

        # ---- TF ----
        t = TransformStamped()
        t.header.stamp = now
        t.header.frame_id = "world"
        t.child_frame_id = "turtle1"

        t.transform.translation.x = msg.x
        t.transform.translation.y = msg.y
        t.transform.translation.z = 0.0

        # yaw → quaternion
        t.transform.rotation.z = math.sin(msg.theta / 2.0)
        t.transform.rotation.w = math.cos(msg.theta / 2.0)

        self.tf_broadcaster.sendTransform(t)

        # ---- Marker (arrow) ----
        marker = Marker()
        marker.header.frame_id = "world"
        marker.header.stamp = now
        marker.ns = "turtle"
        marker.id = 0

        marker.type = Marker.ARROW   # shows direction
        marker.action = Marker.ADD

        marker.pose.position.x = msg.x
        marker.pose.position.y = msg.y
        marker.pose.position.z = 0.0

        marker.scale.x = 1.0   # length
        marker.scale.y = 0.2
        marker.scale.z = 0.2

        marker.color.r = 0.0
        marker.color.g = 1.0
        marker.color.b = 0.0
        marker.color.a = 1.0

        self.marker_pub.publish(marker)

def main():
    rclpy.init()
    node = Turtle3D()
    rclpy.spin(node)
    rclpy.shutdown()

if __name__ == '__main__':
    main()