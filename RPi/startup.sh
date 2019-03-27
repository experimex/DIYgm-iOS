if [ -f transfer.txt ]
then
	rm -f transfer.txt
	echo transfer.txt deleted
fi

./discoverable.sh &
sudo node main.js &
sudo python3 iOS.py &
sudo python3 Android.py &
