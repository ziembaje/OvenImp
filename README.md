# OvenImp
This is a hardware application for the electric imp 001 module. OvenImp is a device designed to easily interface with your oven.

![OvenImp](OvenImp.jpg)

This is a device for those who can't remember to turn their oven or stove off. The imp will monitor the state of these elements and using the Twilio API it will send a text reminder to turn them off after a set period of time. 

Many low end ovens have horribly innacurate temperature control. The OvenImp provides an accurate temperature measurement using a thermocouple and will notify you when the oven is preheated. This will let you cook the perfect pizza everytime.

Pizza before OvenImp
![Pizza before](pizza_before.JPG)

Pizza after OvenImp
![Pizza after](pizza_after.jpg)

I wanted this project to be as close to a sellable product as possible. This is why I chose to build it on a PCB instead of a breadboard or perf board. I designed the board using Altium Designer and got it manufactured at AP Circuits in Alberta Canada due to their reasonable pricing and extremely fast turnaround time. The altium files are in a zip file in the repo for those interested.

Schematic
![Schematic](OvenImp_SCH.PNG)

PCB layout
![PCB](OvenImp_PCB.PNG)


