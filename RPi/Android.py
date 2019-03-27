import bluetooth as bt
import RPi.GPIO as GPIO
import bluetooth
import socket
import time
import os
import sys

#Declares pins and disables error message
GPIO.setwarnings(False)
GPIO.setmode(GPIO.BOARD) 
GPIO.setup(32, GPIO.IN)
GPIO.setup(8, GPIO.OUT) # alarm
GPIO.setup(31, GPIO.OUT) 
GPIO.setup(3, GPIO.OUT) # LED
GPIO.setup(12, GPIO.OUT)
GPIO.output(12, GPIO.HIGH)

#Set the frequency and GPIO pin. Keep pin to 12.
#Frequency has limited effect on the voltage. 
pwm = GPIO.PWM(12, 1000) 

GPIO.add_event_detect(32,GPIO.RISING)

#Sets alarm to off by default
GPIO.output(8, GPIO.LOW)

#Bluetooth Socket Setup
server_sock = bt.BluetoothSocket( bt.RFCOMM )
server_sock.bind(("",bt.PORT_ANY))
server_sock.listen(1)
port = server_sock.getsockname()[1]
uuid = "6f1a48fb-a2bc-4b96-9819-ce7d6a68609d"
    
def detection():
	cpm = 0
	endtime = time.time() + 1 #Change the number in this line to change time (Seconds)
	while time.time() < endtime:
		if GPIO.event_detected(32):
			cpm = cpm + 1
	return cpm   

bt.advertise_service(server_sock, "RaspiBtSrv",
					   service_id=uuid,
					   service_classes=[uuid, bt.SERIAL_PORT_CLASS],
					   profiles=[bt.SERIAL_PORT_PROFILE])

while True:
					   
	print("Android - beginning of script")

	try:
		client_sock, client_info = server_sock.accept()
		print("Android - connected")
		
		x=1
		while x==1:
			# Read the data sent by the client
			data = client_sock.recv(1024)
	 
			# Handle the request
			
			if str(data) == "b'Start'":
				print("Android - Starting detection")

				pwm.start(60) #Set duty cycle. Higher the number, higher the voltage

				y = 0
				while x==1:
					response = str(detection())
					#print()
					client_sock.send(response)
			else:
				response = "msg:Not supported"
				print ("Sent back [%s]", response)
				client_sock.close()
				break  
			
	except IOError:
		pass
	except KeyboardInterrupt:
		if client_sock is not None:
			client_sock.close()
			
	#server_sock.close()
	pwm.stop()
	print("Android - disconnected")
