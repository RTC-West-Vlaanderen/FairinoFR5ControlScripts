import os
import sys
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from fairino import Robot

robot = Robot.RPC("192.168.20.55")
print(robot.GetSDKVersion())
print(robot.GetControllerIP())
robot.CloseRPC()
