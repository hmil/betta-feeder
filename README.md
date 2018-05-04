DIY IoT Feeder for my Betta Fish
================================

![Feeder picture](https://raw.githubusercontent.com/hmil/betta-feeder/master/resources/pic01.jpg)
![CAD model rendering](https://raw.githubusercontent.com/hmil/betta-feeder/master/resources/cad.png)
<img src="https://raw.githubusercontent.com/hmil/betta-feeder/master/resources/web-interface.png" alt="web control interface" width="500">

## Features

- precise quantities, there is never a continuous flow between the reservoir and the dispenser
- Large autonomy: The system works as long as there is food left in the reservoir.
- Robust design with only one moving part.


## What you need

- An arduino board OR a NodeMCU / ESP-12 or any esp8266-based board supported by NodeMCU
- A servomotor
- An AC adapter for the arduino / MCU
- A 3d printer


## Setup

Print and assemble all parts according to the cad model. Make sure to leverage the base plate of your printer to get smooth surfaces inside the case (so that the rotor will slide more easily).
Mount the servomotor on top and connect it to the arduino's VCC (red wire), Gnd (black wire) and pin 9 (the third wire). I found that the capacitors on the board are sufficient to operate the servo without losing power. If you do lose power when the servo moves, connect the servo's red and black wire through a breadboard and put one or two capacitors of more than 100uF in between.


## How it works

![Cut view](https://raw.githubusercontent.com/hmil/betta-feeder/master/resources/screenshot.png)

A hole on a rotating disk alternatively aligns with a food reservoir and a dispensing hole at the bottom. The disk is actionned by a servomotor at scheduled times.


## Hardware

The CAD is [hosted at onshape](https://cad.onshape.com/documents/9ce24f0eb68b5dfcb29f30d2). You should probably adapt it to your specific servo.

Be sure to print with the surfaces in contact with the rotor at the bottom. This way you'll get the smoothest possible surfaces and prevent food from getting stuck into the mechanism.

Ready-to-print STL files are available under `hardware/`. Tested on a prusa i3 mk2; It took a little bit of grinding to get it all to fit.


## Software

### Arduino

There is an arduino sketch providing basic functionality. It does have the following issues:
- Programming the schedule requires to change the software code and flash the arduino with the new program.
- The schedule is relative to the boot time of the arduino. In case of AC outage, there is a risk for feeding too much or too little.

### NodeMCU

A NodeMCU project is available. Connect the servomotor to GPIO 12. Be careful that the board runs at 3.3v whereas the servo runs at 5v (but you don't need a logic converter for the control signal... just beware not to fry the board with 5v). Make a copy of the `.example` files without the `.example` extension and replace the variables according to your environment.

The NodeMCU software must be configured to talk to an MQTT broker. A companion server (located in `/server`) provides a user interface to the device through said broker. Run the server in Node.JS with the proper environment variables (MQTT_HOST, MQTT_PORT, MQTT_USER, MQTT_PASSWORD).

The server lets you manually trigger the feeder and allows you to program the schedule using a cron-like syntax. It also lets you see the history of the device.

Contrary to the Arduino sketch, the NodeMCU solution is more reliable as it uses NTP to keep track of wall clock time. There is no risk of over-delivery and little risk of missed deliveries.


## Known issues

- There is not enough play between the rotor and the carter and it requires quite a bit of grinding to get it to slide well.
- The top part is designed based on an unusual servomotor format. (I got a larger servo to fit using hot glue though).
- The reservoir is too narrow and is a real pain to refill.

**If you fix any of these issues, make sure to contribute your changes back!**
