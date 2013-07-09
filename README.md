ConnectedDevices
================

Project to connect Arduino, Twine and other devices over Bluetooth LE/Serial or WiFi to an MQTT broker.


# Serial-to-MQTT-to-serial Bridge
#
# Listens on serial port and publishes MQTT topics
# Subscribes to MQTT topic and writes to serial port
#
# Example to use Arduino with Bluetooth (over serial)
# On your server, pair with Arduino's Bluetooth
# Once successfully paired, run command: ls /dev/cu.*
# Look for Arduino's Bluetooth device
# Test whether server receives, run command: screen /dev/cu.your_device_name_here
#
# More: http://playground.arduino.cc/interfacing/ruby
#
# MQTT client: https://github.com/njh/ruby-mqtt
