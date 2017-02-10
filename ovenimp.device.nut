
/************************************************
 *               Jack Ziemba
 *               Oven Imp
 *               Device Code
 ************************************************/

//assign pins
sp <- hardware.spi257;
cs <- hardware.pin7;
voltage <- hardware.pin9;
wake <- hardware.pin1;
alarm <- hardware.pin8;

//configure hardware
sp.configure(0, 1); //configure spi object for mode 0 (clock idle low) and 1 kHz frequency
cs.configure(DIGITAL_OUT, 1); //set chip select pin low
voltage.configure(ANALOG_IN);
alarm.configure(PWM_OUT, 1.0 / 200.0, 0.0);


state <- 0;
celcius <- 0;

alert_time <- time() + 1800; //Oven on alert, 1800 for 30 minutes

preheat_temp <- 0;
preheat_flag <- 0;

timer <- 0; 
alarmState <- 0.0;
alarmChange <- 0.05;
 
sendData <- {}; // data to be sent to the agent

function oven_on_off(){
    local state = wake.read();
    
    if (state == 1){
        server.log("im awake");
    } else{
        server.log("going to sleep");
        wake.configure(DIGITAL_IN_WAKEUP);
        imp.deepsleepfor(2419198);
    }
}

//If imp is not woken up for 28 days it will come out of deep sleep. 
//This function will put it back to deep sleep in that case.
function back_to_sleep(){
    if (wake.read() == 0){
        wake.configure(DIGITAL_IN_WAKEUP);
        imp.deepsleepfor(2419198);
        server.log("going to sleep");
    }
}

function read_temp(){ //Code taken from adafruit tutorial, https://github.com/joel-wehr/Tutorial_Electric_Imp_MAX31855/blob/master/device.nut
    cs.write(0);
    local temp32 = sp.readblob(4);
    cs.write(1);

    local tc = 0;
	local highbyte =(temp32[0]<<6); //move 8 bits to the left 6 places
	local lowbyte = (temp32[1]>>2);	//move to the right two places	
	tc = highbyte | lowbyte; //now have right-justifed 14 bits but the 14th digit is the sign    
	//Shifting the bits to make sure negative numbers are handled
    //Get the sign indicator into position 31 of the signed 32-bit integer
    //Then, scale the number back down, the right-shift operator of squirrel/impOS
    tc = ((tc<<18)>>18); 
    // Convert to Celcius
	celcius = (1.0* tc/4.0) - 5;
	
    server.log(celcius + "°C");
    sendData.temp <- celcius;
}

function send_alert(){ 
    if(time() >= alert_time){
        alert_time = time() + 600; //send every 10 minutes after the first message
        server.log("sending alert");
        agent.send("text_message", "oven_on");
    }
}

function read_voltage(){
    local voltage = voltage.read();
    voltage = (voltage*(3.3/65535))*3; //convert ADC value to volts and scale by 3 to compensate for voltage divider
    server.log(voltage);
    sendData.voltage <- voltage;
}

function set_preheat(temp){
    preheat_temp = temp.tointeger();
    server.log(preheat_temp);
    preheat_flag = 1;
}

function preheat_alert(){
    
    server.log("temp" + celcius);
    server.log("ptemp" + (preheat_temp - 5));
    
    if ( ( celcius >= (preheat_temp - 5)) && preheat_flag ){
        server.log("sending alert");

        agent.send("text_message", "preheat");
        preheat_flag = 0;
        
        timer = time() + 10; //set timer length for timer_control function
        timer_control();
    }  
}

function timer_control(){
    
    if(time() < timer){
    //server.log("timer");

        alarm.write(alarmState);
    	
        // Change the state value
        alarmState = alarmState + alarmChange;
    	
        // Check if we're out of bounds
        if (alarmState >= 1.0 || alarmState <= 0.0) {
            // Flip ledChange if we are
            alarmChange = alarmChange * -1.0
        }
    	
         // Schedule the loop to run again in 0.05 seconds
        imp.wakeup(0.001, timer_control);
        
    } else {
        alarm.write(0);
    }
}

// Configure the button to call buttonPress() when the pin's state changes

function main(){
    
    send_alert();

    read_temp(); 
    read_voltage();
    agent.send("data", sendData);
    
    preheat_alert();
    
    imp.wakeup(3, main);
    
}


// program starts here
main();
wake.configure(DIGITAL_IN_PULLUP, oven_on_off);
agent.on("preheat", set_preheat);
imp.onidle(back_to_sleep);
