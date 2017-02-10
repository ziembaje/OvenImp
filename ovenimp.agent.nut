#require "Twilio.class.nut:1.0.0"
#require "Rocky.class.nut:1.3.0"

/************************************************
 *               Jack Ziemba
 *               Oven Imp
 *               Agent Code
 ************************************************/

// GLOBALS
local api = null;

//Web page 
local savedData = null;
savedData = {};
savedData.temp <- "TBD";
savedData.voltage <- "TBD";
savedData.preheat_temp <- "TBD";


twilioNumber <- "6474901582";
accountSID <- "AC2fc6eed5cf7350f0a017de07a192c1e4";
authToken <- "06ab7b31877d703fa252e76b08cab4bd";

twilio <- Twilio(accountSID, authToken, twilioNumber);

number <- "4165221186";
oven_on <- "Oven is on!";
preheat <- "Oven is preheated";


//CONSTANTS
const htmlString = @"
<!DOCTYPE html>
<html>
    <head>
    
        <title>Oven Imp</title>
        <link rel='stylesheet' href='https://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css'>
        <meta name='viewport' content='width=device-width, initial-scale=1.0'>
        <style>
            
    
            .center { margin-left: auto; margin-right: auto; margin-bottom: auto; margin-top: auto; }
        </style>
    </head>
    <body>
        <style>
        
        </style>
        <div class='container'>
            <h2 class='text-center'>Oven Imp</h2>
            <div class='current-status'>
                <h4 class='temp-status'>Oven Temperature: <span></span>&deg;C</h4>
                <h4 class='volt-status'>Battery Voltage: <span></span> Volts</h4>
    
            </div>
        
            <br>
            <div class='controls'>
                <div class='update-button'>
                    <form id='name-form'>
                        <label>Pre-Heat Temperature &deg;C:</label>&nbsp;<input id='preheat_temp'></input>
                        <button type='submit' id='location-button'>Set</button>
                    </form>
                </div>
            <br>
            <small>From: %s</small>
        </div>  <!-- container -->
        
        <div id='myProgress'>
             <div id='myBar'></div>
        </div>
        
        <script src='https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js'></script>
        <script>
            var agenturl = '%s';
            getState(updateReadout);
            $('.update-button button').on('click', getStateInput);
            function getStateInput(e){
                e.preventDefault();
                var place = document.getElementById('preheat_temp').value;
                setLocation(place);
                $('#name-form').trigger('reset');
            }
            function updateReadout(data) {
                $('.temp-status span').text(data.temp);
                $('.volt-status span').text(data.voltage);
                setTimeout(function() {
                    getState(updateReadout);
                }, 1);
            }
            function getState(callback) {
                $.ajax({
                    url : agenturl + '/state',
                    type: 'GET',
                    success : function(response) {
                        if (callback && ('temp' in response)) {
                            callback(response);
                        }
                    }
                });
            }
            function setLocation(place) {
                $.ajax({
                    url : agenturl + '/preheat_temp',
                    type: 'POST',
                    data: JSON.stringify({ 'preheat_temp' : place }),
                    success : function(response) {
                        if ('preheat_temp' in response) {
                            $('.preheat_temp-status span').text(response.preheat_temp);
                        }
                    }
                });
            }
        </script>
        
        
    </body>
    

</html>


";

//functions

function get_data(sendData){
    
    savedData.temp = sendData.temp;
    savedData.voltage = format("%.1f", sendData.voltage);
    
}

function send_alert(message){
    
    local text; 
    
    if (message == "oven_on"){
        text = oven_on;
    }
    
    else {
        text = preheat;
    }
    
    local response = twilio.send(number, text);
    server.log(response.statuscode + ": " + response.body);
}

api = Rocky();

// Set up the app's API
api.get("/", function(context){
    // Root request: just return standard web page HTML string
    context.send(200, format(htmlString, http.agenturl(), http.agenturl()));
});

api.get("/state", function(context){
    // Request for data from /state endpoint
    context.send(200, { temp = savedData.temp, voltage = savedData.voltage});
});

api.post("/preheat_temp", function(context) {
    // Sensor location string submission at the /location endpoint
    local data = http.jsondecode(context.req.rawbody);
    if ("preheat_temp" in data) {
        if (data.preheat_temp != "") {
            // We have a non-zero string, so save it
            savedData.preheat_temp = data.preheat_temp;
            server.log(savedData.preheat_temp);
            context.send(200, { preheat_temp = data.preheat_temp });
            device.send("preheat", savedData.preheat_temp);
            return;
        }
    }

    context.send(200, "OK");
});

device.on("text_message", send_alert);
device.on("data", get_data);

