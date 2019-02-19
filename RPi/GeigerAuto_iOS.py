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

pwm = GPIO.PWM(12, 1000) #Set the frequency and GPIO pin. Keep pin to 12.
                         #Frequency has limited effect on the voltage.

GPIO.add_event_detect(32,GPIO.RISING)

#Sets alarm to off by default
GPIO.output(8, GPIO.LOW)

print("Running DIYgm-iOS Python script.")

#Remove previous transfer file if it still exists
if os.path.exists("transfer.txt"):
    os.remove("transfer.txt")

print("Connect iPhone to Raspberry Pi to continue...")

def detection():
    cpm = 100
    endtime = time.time() + 1 #Change the number in this line to change time (Seconds)
    while time.time() < endtime:
        if GPIO.event_detected(32):
            cpm = cpm + 1
    return cpm

def transfer():
    file = open("transfer.txt","w")
    while os.path.exists("transfer.txt"):    
        count_rate = str(detection())
    
        #Place value in first line of transfer.txt    
        file.seek(0)
        file.write("new" + count_rate)
        file.truncate()
    pwm.stop(12)
    print("DISCONNECTED - Reconnect to start detection again.")

while True:
    if os.path.exists("transfer.txt"):
        pwm.start(60)
        print("CONNECTED - Detection started.")
        transfer()
    time.sleep(0.1)

dose = int
#doserate = ttk.Entry(mainframe, width=5, textvariable=dose).grid(column=5, row=5)

for child in mainframe.winfo_children(): child.grid_configure(padx=5, pady=5)

root.mainloop()


pwm.stop(12)

GPIO.cleanup()
