#James Seekamp, Jeffery Xiao, Issa El-Amir, Regina Tuey, Max Li
#2/7/2019
#DIY Geiger Kit for RPi Zero W and iOS


#Library Imports
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

def detection():
    cpm = 0
    endtime = time.time() + 1 #Change the number in this line to change time (Seconds)
    while time.time() < endtime:
        if GPIO.event_detected(32):
            cpm = cpm + 1
    return cpm    
    
while True:
	print("iOS - beginning of script")

	#Wait for iOS connection
	while not os.path.exists("transfer.txt"):
		time.sleep(0.1)

	#Start detection after iOS connection
	pwm.start(60)
	print("iOS - connected")
	file = open("transfer.txt","w")
	while os.path.exists("transfer.txt"):    
		count_rate = str(detection())

		#Place value in first line of transfer.txt    
		file.seek(0)
		file.write("new" + count_rate)
		file.truncate()
		
	print("iOS - finished, disconnected")
	pwm.stop()
	time.sleep(3)
