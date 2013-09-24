// Publish temperature to MQTT broker

// MQTT Arduino PubSubClient by Nick O'Leary
// http://knolleary.net/arduino-client-for-mqtt/

// To Do: 
// 1. Automatic reconnect attempt of arduino client if connection to MQTT server is lost (e.g. if server restarts)

#include <SPI.h>
#include <Ethernet.h>
#include <PubSubClient.h>
#include <stdlib.h>
#include <string.h>

// Pins
//
const int tempPinIn = 0; // Analog 0 is the input pin

// Variables
//
char* tempC;
char buffer[10];



// Network Settings
//
// Set MAC address of ethernet shield. Look for it on a sticket at the bottom of the shield. Old Arduino Ethernet Shields or clones may not have a dedicated MAC address. Set any hex values here.
byte MAC_ADDRESS[] = {  0xFE, 0xED, 0xDE, 0xAD, 0xBE, 0xEF };
// Set IP address of MQTT server
byte SERVER[] = { 192, 168, 1, 115 };
// Set static IP address of Ethernet shield. Comment out for DHCP. See note below at begin(mac).
//byte IP[]     = { 192, 168, 1, 1 };

void callback(char* topic, byte* payload, unsigned int length) {
  // handle message arrived
  Serial.println("Callback");
  Serial.print("Topic:");
  Serial.println(topic);
  Serial.print("Length:");
  Serial.println(length);
  Serial.print("Payload:");
  Serial.write(payload,length);
  Serial.println();
}

EthernetClient ethClient;
PubSubClient client(server, 1883, callback, ethClient);

void setup()
{
  Serial.begin(9600);
  //  Ethernet.begin(mac, ip); // Uncomment in case of static IP
  Ethernet.begin(mac);
  if (client.connect("arduinoClient")) {
    // client.publish("SFO/Arduino/Inside/Temperature","Hello World!");
    client.publish("SFO/Arduino/Inside/Temperature",tempC);    
    // client.subscribe("inTopic");
  }
}

void loop()
{
  tempC = dtostrf(((((analogRead(tempPin) * 5.0) / 1024) - 0.5) * 100), 5, 2, buffer); // TMP36 sensor calibration
  Serial.println(tempC);
  client.publish("SFO/Arduino/Inside/Temperature",tempC);
  client.loop();
  delay(60000); 
}
