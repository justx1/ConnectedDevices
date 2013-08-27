// Publish temperature to MQTT broker

// MQTT Arduino PubSubClient by Nick O'Leary
// http://knolleary.net/arduino-client-for-mqtt/

#include <SPI.h>
#include <Ethernet.h>
#include <PubSubClient.h>

// Set MAC address. Look for it on a sticket at the bottom of the shield. Old Arduino Ethernet Shields or clones may not have a dedicated MAC address. Set any hex values here.
byte mac[]    = {  0xFE, 0xED, 0xDE, 0xAD, 0xBE, 0xEF };
// IP address of MQTT broker
byte broker[] = { 192, 168, 1, 115 };
// Static IP address of Ethernet shield. Comment out for DHCP. See note below at begin(mac).
//byte ip[]     = { 192, 168, 1, 1 };

void callback(char* topic, byte* payload, unsigned int length) {
  // handle message arrived
}

EthernetClient ethClient;
PubSubClient client(broker, 1883, callback, ethClient);

void setup()
{
//  Ethernet.begin(mac, ip); // Uncomment in case of static IP
  Ethernet.begin(mac);
  if (client.connect("arduinoClient")) {
    client.publish("outTopic","hello world");
    client.subscribe("inTopic");
  }
}

void loop()
{
  client.loop();
}


/*



// Pins
const int temperaturePin = A0;

// Variables
float voltage, degreesC;

// Update these with values suitable for your network.
byte mac[]    = {  0xDE, 0xED, 0xBA, 0xFE, 0xFE, 0xED };
byte server[] = { 192, 168, 1, 115 };
//byte ip[]     = { 172, 16, 0, 100 };

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
