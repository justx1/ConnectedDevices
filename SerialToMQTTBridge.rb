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

require 'rubygems'
require 'serialport'
require 'mqtt'

# Params for Serial Port
serial_port = "/dev/cu.linvor-DevB"
baud_rate = 9600
data_bits = 8
stop_bits = 1
parity = SerialPort::NONE

# Params for MQTT broker
mqtt_host = "localhost"
topic = "sensors/temperature"

# Open Connection
sp = SerialPort.new(serial_port, baud_rate, data_bits, stop_bits, parity)

# Read forever
while true do
	while (i = sp.gets.chomp) do
		MQTT::Client.connect(mqtt_host) do |c|
			c.publish(topic, i)
		end
		#puts i
		#puts i.class #String
	end
end
 
sp.close