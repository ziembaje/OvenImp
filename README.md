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

The oven/stove on reminder works by detecting the ovens three built in lights which show when the oven or stove is on. The light is detected using three photoresistors each feeding in to a comparator circuit whose outputs are connected to the inputs of an OR gate. The output of this is connected to the Wakeup pin on the Imp 001. This is how the imp will wake up from deepsleep and know that the oven or stove is on. The imp will send a text notification after 30 minutes of it being on and every 10 minutes after that. (these values can be easily changed in the device code to whatever best suits your needs).

![PCB](wakeup_circuit.PNG)

The photoresistors need to extend quite far from the imp. Because of this the photoresistors were spliced with wire and connected to the OvenImp connector.


![installed](imp_installed.PNG)





