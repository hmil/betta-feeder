DIY Feeder for my Betta Fish
============================

![Feeder picture](https://raw.githubusercontent.com/hmil/betta-feeder/master/resources/pic01.jpg)
![CAD model rendering](https://raw.githubusercontent.com/hmil/betta-feeder/master/resources/cad.png)

## Features

- precise quantities, there is never a continuous flow between the reservoir and the dispenser
- Large autonomy: The system works as long as there is food left in the reservoir.
- Robust design with only one moving part.

## What you need

- An arduino board
- A servomotor
- An AC adapter for the arduino
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

## Known issues

- Programming the schedule requires to change the software code and flash the arduino with the new program.
- The schedule is relative to the boot time of the arduino. In case of AC outage, there is a risk for feeding too much or too little.
- There is not enough play between the rotor and the carter and it requires quite a bit of grinding to get it to slide well.
- The top part is designed based on an unusual servomotor format. (I got a larger servo to fit using hot glue though).
- The reservoir is too narrow and is a real pain to refill.

**If you fix any of these issues, make sure to contribute your changes back!**
