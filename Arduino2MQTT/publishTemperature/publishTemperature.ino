// Publish temperature to MQTT broker

// MQTT Arduino PubSubClient by Nick O'Leary
// http://knolleary.net/arduino-client-for-mqtt/

#include <SPI.h>
#include <Ethernet.h>
#include <PubSubClient.h>
#include <stdlib.h>
#include <string.h>

// Pins
//
const int tempPin = A0;

// Variables
//
float temp = 0;
float oldTemp = 0;
int len;
char tempstr[7];
char MQTTbuffer[120];

// Network Settings
//
// Set MAC address of ethernet shield. Look for it on a sticket at the bottom of the shield. Old Arduino Ethernet Shields or clones may not have a dedicated MAC address. Set any hex values here.
byte mac[] = {  0xFE, 0xED, 0xDE, 0xAD, 0xBE, 0xEF };
// Set IP address of MQTT server
byte server[] = { 192, 168, 1, 115 };
// Set static IP address of Ethernet shield. Comment out for DHCP. See note below at begin(mac).
//byte ip[]     = { 192, 168, 1, 1 };

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
    client.publish("outTopic","hello world!");
    client.subscribe("inTopic");
  }
}

void loop()
{
  client.loop();
  temp = analogRead(tempPin);
  temp *= 5;
  temp /= 1023;
  temp -= 0.5;
  temp *= 100;
  dtostrf(temp, 6, 2, tempstr);
  if (temp != oldTemp) {
    len = sprintf (MQTTbuffer, "Temp: %s , Light: %d ", tempstr);
    Serial.println(MQTTbuffer);
    client.publish("outTopic",MQTTbuffer);
    oldTemp = temp;
  }
  delay(1000); 
}


/*





void callback(char* topic, byte* payload, unsigned int length) {
  // handle message arrived
}

EthernetClient ethClient;
PubSubClient client(server, 1883, callback, ethClient);

void setup()
{
  Ethernet.begin(mac);
  if (client.connect("arduinoClient")) {
    client.publish("outTopic","hello world");
    //client.subscribe("inTopic");
  }
  Serial.begin(9600);
  pinMode(temperaturePin, INPUT);
}

void loop()
{
  client.loop();
//  printTemperature(temperaturePin);
  client.publish("outTopic",analogRead(temperaturPin));
}


*/
