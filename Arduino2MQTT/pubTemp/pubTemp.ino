/*
 * Temperature Reading
 *
 * Reads sensor value and publishes through MQTT.
 * MQTT Arduino PubSubClient http://knolleary.net/arduino-client-for-mqtt/
 *
 */

#include <SPI.h>
#include <PubSubClient.h>
#include <Ethernet.h>

// Pins
const int tempPinIn = 0; // Analog 0 is the input pin

// Variables
char* tempC;
unsigned long time;
char message_buffer[100];

// Network Settings
// MAC address of ethernet shield
// Look for it on a sticket at the bottom of the shield. 
// Old Arduino Ethernet Shields or clones may not have a dedicated MAC address. Set any hex values here.
byte MAC_ADDRESS[] = {  0xFE, 0xED, 0xDE, 0xAD, 0xBE, 0xEF };

// IP address of MQTT server
byte MQTT_SERVER[] = { 192, 168, 1, 115 };
// #define MQTT_SERVER "q.sfo.example.com"

// Set static IP address of Ethernet shield. Comment out for DHCP. See note below at begin(mac).
// byte STATIC_IP[]     = { 192, 168, 1, 1 };

EthernetClient ethClient;
PubSubClient client(MQTT_SERVER, 1883, callback, ethClient);

void setup()
{  
  // Initilize serial link for debugging
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
    //client.connect("clientID", "mqtt_username", "mqtt_password");
    client.connect("sfo-arduino");
    client.publish("sfo/arduino/alive", "I'm alive!");
  }
  
  tempC = dtostrf(((((analogRead(tempPinIn) * 5.0) / 1024) - 0.5) * 100), 5, 2, message_buffer); // TMP36 sensor calibration
  //Serial.println(tempC);

  // Publish sensor reading every X milliseconds
    if (millis() > (time + 60000)) {
      time = millis();
      client.publish("sfo/arduino/inside/temperature",tempC);
    }
    
    // MQTT client loop processing
    client.loop();
}

// Handles messages arrived on subscribed topic(s)
void callback(char* topic, byte* payload, unsigned int length) {
}

// To Do: 
// 1. Automatic reconnect attempt of arduino client if connection to MQTT server is lost (e.g. if server restarts)
// 2. Move to static IP instead of DHCP. Saves binary sketch space.
// 3. Move to local domain q.sfo.*.*
