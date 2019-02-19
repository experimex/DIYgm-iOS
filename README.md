# DIYgm-iOS
iOS app for DIY Geiger Muller technology outreach project at the University of Michigan

APIs: Create a Keys.plist in the DIYgm-iOS folder. Add an entry with the key being "GoogleAPI" and value being your Google Cloud Platform API key.

Color Scale: The saturation of each marker is based on how high its measured count rate is, compared to a specified high value. This high value was set to 100, meaning a value of 0 is the least saturated and a value of 100 and above is the most saturated. To change the high value, modify the value of the highValue variable in setCountRate().

The RPi folder contains the files used on the Raspberry Pi to allow this app to work. 
- GeigerAuto_iOS.py (Python 3) gets the count rate from the radiation detector and prepares it for transfer. 
- main.js (node.js) simulates a peripheral on the Raspberry Pi to transfer the count rate data to this app.
Run both of these files in order to connect to the Raspberry Pi and receive count rate data from it.
