
// To Do: 
// 1. Automatic reconnect attempt of arduino client if connection to MQTT server is lost (e.g. if server restarts)


#include <SPI.h>
#include <PubSubClient.h>
#include <Ethernet.h>

/*
 * Temperature Reading
 *
 * Reads sensor value and publishes through MQTT.
 * MQTT Arduino PubSubClient http://knolleary.net/arduino-client-for-mqtt/
 *
 */

// Pins
//
const int tempPinIn = 0; // Analog 0 is the input pin
const int ledPinOut = 9; // Analog 9 is the LED output pin

// Variables
//
char* tempC;
unsigned long time;
char message_buffer[100];

// Network Settings
//
// Set MAC address of ethernet shield. Look for it on a sticket at the bottom of the shield. Old Arduino Ethernet Shields or clones may not have a dedicated MAC address. Set any hex values here.
byte MAC_ADDRESS[] = {  0xFE, 0xED, 0xDE, 0xAD, 0xBE, 0xEF };

// Set IP address of MQTT server
byte MQTT_SERVER[] = { 192, 168, 1, 115 };

// Set static IP address of Ethernet shield. Comment out for DHCP. See note below at begin(mac).
//byte IP[]     = { 192, 168, 1, 1 };

// defines and variable for sensor/control mode
//#define MODE_OFF    0  // not sensing light, LED off
//#define MODE_ON     1  // not sensing light, LED on
//#define MODE_SENSE  2  // sensing light, LED controlled by software
//int senseMode = 0;

//EthernetClient ethClient;
//PubSubClient client(MQTT_SERVER, 1883, callback, ethClient);

  //PubSubClient client;
  //client = PubSubClient(MQTT_SERVER, 1883, callback);
  EthernetClient ethClient;
  PubSubClient client(MQTT_SERVER, 1883, callback, ethClient);

void setup()
{
  // initialize the digital pin as an output.
  pinMode(ledPinOut, OUTPUT);
  
  // init serial link for debugging
  Serial.begin(9600);
  
  if (Ethernet.begin(MAC_ADDRESS) == 0)
  {
      Serial.println("Failed to configure Ethernet using DHCP");
      return;
  }
}

void loop()
{
  if (!client.connected())
  {
      // clientID, username, MD5 encoded password
      //client.connect("arduino-mqtt", "john@m2m.io", "00000000000000000000000000000");
      client.connect("sfo-arduino");
      client.publish("sfo/arduino/alive", "I'm alive!");
      client.subscribe("sfo/arduino/switch");
  }
  
  tempC = dtostrf(((((analogRead(tempPinIn) * 5.0) / 1024) - 0.5) * 100), 5, 2, message_buffer); // TMP36 sensor calibration
  //Serial.println(tempC);
  //client.publish("SFO/Arduino/Inside/Temperature",tempC);

  //int tempRead = analogRead(tempPinIn);

  // publish temperature reading every 5 seconds
      if (millis() > (time + 5000)) {
        time = millis();
        //String pubString = "{\"report\":{\"light\": \"" + String(lightRead) + "\"}}";
        //pubString.toCharArray(message_buff, pubString.length()+1);
        //Serial.println(pubString);
        //client.publish("io.m2m/arduino/lightsensor", message_buff);
        client.publish("SFO/Arduino/Inside/Temperature",tempC);
      }  

  /*
  switch (senseMode) {
    case MODE_OFF:
      // light should be off
      digitalWrite(ledPin, LOW);
      break;
    case MODE_ON:
      // light should be on
      digitalWrite(ledPin, HIGH);
      break;
    case MODE_SENSE:
      // light is adaptive to light sensor
      
      // read from light sensor (photocell)
      int lightRead = analogRead(lightPinIn);

      // if there is light in the room, turn off LED
      // else, if it is "dark", turn it on
      // scale of light in this circit is roughly 0 - 900
      // 500 is a "magic number" for "dark"
      if (lightRead > 500) {
        digitalWrite(ledPin, LOW);
      } else {
        digitalWrite(ledPin, HIGH);
      }
      
      // publish light reading every 5 seconds
      if (millis() > (time + 5000)) {
        time = millis();
        String pubString = "{\"report\":{\"light\": \"" + String(lightRead) + "\"}}";
        pubString.toCharArray(message_buff, pubString.length()+1);
        //Serial.println(pubString);
        client.publish("io.m2m/arduino/lightsensor", message_buff);
      }  
  }
  */


  // MQTT client loop processing
  client.loop();
}

// handles message arrived on subscribed topic(s)
void callback(char* topic, byte* payload, unsigned int length) {

  /*
  int i = 0;

  //Serial.println("Message arrived:  topic: " + String(topic));
  //Serial.println("Length: " + String(length,DEC));
  
  // create character buffer with ending null terminator (string)
  for(i=0; i<length; i++) {
    message_buff[i] = payload[i];
  }
  message_buff[i] = '\0';
  
  String msgString = String(message_buff);
  
  //Serial.println("Payload: " + msgString);
  
  if (msgString.equals("{\"command\":{\"lightmode\": \"OFF\"}}")) {
    senseMode = MODE_OFF;
  } else if (msgString.equals("{\"command\":{\"lightmode\": \"ON\"}}")) {
    senseMode = MODE_ON;
  } else if (msgString.equals("{\"command\":{\"lightmode\": \"SENSE\"}}")) {
    senseMode = MODE_SENSE;
  }
  */
}
