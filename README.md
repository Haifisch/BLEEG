BLEEG, a wireless EEG that communicates over Bluetooth LE
=========================================================
This is a small tutorial going over how to setup a MineFlex toy into a portable, wireless, and low cost EEG.

## Parts
-----
- MindFlex toy (~$20 on eBay. All we need from this is the headband.)
- Philips Screw Driver
- Pinoccio Scout
- Bluetooth Backpack
- Soldering iron w/ solder
- Thin wire
- Multimeter if you want to explore power options

## How-to
---------

#### Step 1:
Start by opening the right module, a small philips screw driver will do the job, and open up the case to reveal the main board, and the daughter board.

![alt text](Images/board.JPG "Board inside MindFlex" )
#### Step 2:
Locate the "T" pin on the smaller (daughter) board, and solder a good length of wire to the "T" pin, make sure there's no bridging from other pins. Strip and connect the "T" to RX1 on your Scout.

Image below shows the "T" contact marked by a red dot.
![alt text](Images/tPin.JPG "Board inside MindFlex" )

#### Step 3:
Find the common ground, this was on the main board for me, next to a group of capacitors, and run another wire from ground on your MindFlex, to ground on your Scout.

*Optional: Use the ~4 in from the positive lead to power your Scout, just run a wire from the positive lead to VUSB on your Scout.*

Image below shows the common ground marked by a red dot.
![alt text](Images/ground.JPG "Board inside MindFlex" )

#### Step 4:
*Requirements: [Adafruit_nRF8001 library](https://github.com/adafruit/Adafruit_nRF8001), and the [Brain library](https://github.com/kitschpatrol/Brain)*

Use the Arduino project given, and compile and upload to your Scout, then open your serial monitor at 115200 baud.

#### Step 5:
Run the iOS project on your test device, this may require a iOS developer account to run on your iPhone / iPad / iPod Touch

#### Step 6:
Turn on both the Scout and the MindFlex, then run the iOS app to discover the Bluetooth device. Reading should start to load soon after the BTLE device connects.
