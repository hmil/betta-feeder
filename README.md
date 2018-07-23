DIY IoT Feeder for my Betta Fish
================================

![Feeder picture](https://raw.githubusercontent.com/hmil/betta-feeder/master/resources/pic01.jpg)
![CAD model rendering](https://raw.githubusercontent.com/hmil/betta-feeder/master/resources/cad.png)
<img src="https://raw.githubusercontent.com/hmil/betta-feeder/master/resources/web-interface.png" alt="web control interface" width="500">

## Features

- precise quantities, food is delivered in predefined increments
- Large autonomy: The system works as long as there is food left in the reservoir.
- Robust design with only one moving part.


## What you need

- An arduino board OR a NodeMCU / ESP-12 or any esp8266-based board supported by NodeMCU
- A servomotor
- An AC adapter for the arduino / MCU
- A 3d printer


## Setup

Print and assemble all parts according to the cad model. Make sure to leverage the base plate of your printer to get smooth surfaces for the inside of the case and the base of the rotor (this will prevent food from getting caught between the rotor and the case).
Mount the servomotor on top and connect it to the arduino's VCC (red wire), Gnd (black wire) and pin 9 (remaining wire). I found that the capacitors on the board are sufficient to operate the servo without loss of power. If you do lose power when the servo moves, connect the servo's red and black wire through a breadboard and put one or two capacitors of more than 100uF in between.


## How it works

![Cut view](https://raw.githubusercontent.com/hmil/betta-feeder/master/resources/screenshot.png)

A hole on a rotating disk alternatively aligns with a food reservoir on top and a dispensing hole at the bottom. The disk is actionned by a servomotor at scheduled times.


## Hardware

The CAD is [hosted at onshape](https://cad.onshape.com/documents/9ce24f0eb68b5dfcb29f30d2). You will probably need to modify it so that it fits your specific servo.

Be sure to print the surfaces that will be in contact with the rotor facing the bottom. This way you'll get the smoothest possible surfaces and prevent food from getting stuck into the mechanism.

Ready-to-print STL files are available under `hardware/`. Tested on a prusa i3 mk2; It took a little bit of grinding to get them all to fit together.


## Software

### Arduino

There is an arduino sketch providing basic functionality. It is a prototype and has major flaws:
- Programming the schedule requires to change the software code and flash the arduino with the new program.
- The schedule is relative to the boot time of the arduino. In the event of an AC outage, there is a risk for feeding too much or too little.

### NodeMCU

A NodeMCU project is available as well. It is safer and has more features than the arduino code, but is a little more complex to use.

Connect the servomotor to GPIO 12. Be careful that the board runs at 3.3v whereas a servo usually runs at 5v (You don't need a logic converter for the control signal... just beware not to connect the board's 3.3v to the servo's VCC). Make a copy of the `.example` files without the `.example` extension and replace the variables according to your environment.

The NodeMCU software must be configured to talk to an MQTT broker. A companion server (located in `/server`) provides a user interface and connects to the same broker to collect data and send commands to the device. Run the server with Node.JS and the proper environment variables (MQTT_HOST, MQTT_PORT, MQTT_USER, MQTT_PASSWORD).

The server lets you manually trigger the feeder and allows you to program the schedule using a cron-like syntax. It also lets you see historical data of the device.

Contrary to the Arduino sketch, the NodeMCU solution is more reliable as it uses NTP to keep track of wall clock time. There is no risk of over-delivery and little risk of missed deliveries.


## Known issues

- There is not enough play between the rotor and the carter and it requires quite a bit of grinding to get it to slide well.
- The top part is designed based on an unusual servomotor format. (I got a larger servo to fit using hot glue though).
- The reservoir is too narrow and is a real pain to refill.

**If you fix any of these issues, make sure to contribute your changes back!**
