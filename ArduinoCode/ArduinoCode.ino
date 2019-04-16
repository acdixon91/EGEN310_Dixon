
#include <Arduino.h>
#include <SPI.h>
#include "Adafruit_BLE.h"
#include "Adafruit_BluefruitLE_SPI.h"
#include "Adafruit_BluefruitLE_UART.h"
#include <Servo.h>
#include "BluefruitConfig.h"

#if SOFTWARE_SERIAL_AVAILABLE
  #include <SoftwareSerial.h>
#endif

/*=========================================================================
    APPLICATION SETTINGS

    FACTORYRESET_ENABLE       Perform a factory reset when running this sketch
   
                              Enabling this will put your Bluefruit LE module
                              in a 'known good' state and clear any config
                              data set in previous sketches or projects, so
                              running this at least once is a good idea.
   
                              When deploying your project, however, you will
                              want to disable factory reset by setting this
                              value to 0.  If you are making changes to your
                              Bluefruit LE device via AT commands, and those
                              changes aren't persisting across resets, this
                              is the reason why.  Factory reset will erase
                              the non-volatile memory where config data is
                              stored, setting it back to factory default
                              values.
       
                              Some sketches that require you to bond to a
                              central device (HID mouse, keyboard, etc.)
                              won't work at all with this feature enabled
                              since the factory reset will clear all of the
                              bonding data stored on the chip, meaning the
                              central device won't be able to reconnect.
    MINIMUM_FIRMWARE_VERSION  Minimum firmware version to have some new features
    MODE_LED_BEHAVIOUR        LED activity, valid options are
                              "DISABLE" or "MODE" or "BLEUART" or
                              "HWUART"  or "SPI"  or "MANUAL"
    -----------------------------------------------------------------------*/
    #define FACTORYRESET_ENABLE         1
    #define MINIMUM_FIRMWARE_VERSION    "0.6.6"
    #define MODE_LED_BEHAVIOUR          "MODE"
/*=========================================================================*/

// Create the bluefruit object, either software serial...uncomment these lines

SoftwareSerial bluefruitSS = SoftwareSerial(BLUEFRUIT_SWUART_TXD_PIN, BLUEFRUIT_SWUART_RXD_PIN);

Adafruit_BluefruitLE_UART ble(bluefruitSS, BLUEFRUIT_UART_MODE_PIN,
                      BLUEFRUIT_UART_CTS_PIN, BLUEFRUIT_UART_RTS_PIN);


/* ...or hardware serial, which does not need the RTS/CTS pins. Uncomment this line */
//Adafruit_BluefruitLE_UART ble(Serial1, BLUEFRUIT_UART_MODE_PIN);

/* ...hardware SPI, using SCK/MOSI/MISO hardware SPI pins and then user selected CS/IRQ/RST */
//Adafruit_BluefruitLE_SPI ble(BLUEFRUIT_SPI_CS, BLUEFRUIT_SPI_IRQ, BLUEFRUIT_SPI_RST);

/* ...software SPI, using SCK/MOSI/MISO user-defined SPI pins and then user selected CS/IRQ/RST */
//Adafruit_BluefruitLE_SPI ble(BLUEFRUIT_SPI_SCK, BLUEFRUIT_SPI_MISO,
//                             BLUEFRUIT_SPI_MOSI, BLUEFRUIT_SPI_CS,
//                             BLUEFRUIT_SPI_IRQ, BLUEFRUIT_SPI_RST);


// A small helper
void error(const __FlashStringHelper*err) {
  Serial.println(err);
  while (1);
}


// function prototypes over in packetparser.cpp
uint8_t readPacket(Adafruit_BLE *ble, uint16_t timeout);
float parsefloat(uint8_t *buffer);
void printHex(const uint8_t * data, const uint32_t numBytes);

// the packet buffer
extern uint8_t packetbuffer[];

extern String leftTrigger;
extern String rightTrigger;
extern int leftTriggerInt;
extern int rightTriggerInt;
extern String leftThumbstick;
extern String rightThumbstick;
extern String inString;
String input;
int pastDegree;

// Create survo object
Servo servo;

// Motor A pins
int enA = 5;
int in1A = 13;
int in2A = 7;

//Motor B pins
int enB = 3;
int in1B = 2;
int in2B = 4;


/**************************************************************************/
/*!
    @brief  Sets up the HW an the BLE module (this function is called
            automatically on startup)
*/
/**************************************************************************/
void setup(void)
{
  //Set survo pin and set to center
  servo.attach(6);
  servo.write(90);
  pastDegree = 90;
  
  // Set motor A control pins to outputs
  pinMode(enA, OUTPUT);
  pinMode(in1A, OUTPUT);
  pinMode(in2A, OUTPUT);

  // Set motor B control pins to outputs
  pinMode(enB, OUTPUT);
  pinMode(in1B, OUTPUT);
  pinMode(in2B, OUTPUT);
  
  while (!Serial);  // required for Flora & Micro
  delay(500);

  Serial.begin(115200);
  Serial.println(F("Adafruit Bluefruit Command Mode Example"));
  Serial.println(F("---------------------------------------"));

  /* Initialise the module */
  Serial.print(F("Initialising the Bluefruit LE module: "));

  if ( !ble.begin(VERBOSE_MODE) )
  {
    error(F("Couldn't find Bluefruit, make sure it's in CoMmanD mode & check wiring?"));
  }
  Serial.println( F("OK!") );

//  if ( FACTORYRESET_ENABLE )
//  {
//    /* Perform a factory reset to make sure everything is in a known state */
//    Serial.println(F("Performing a factory reset: "));
//    if ( ! ble.factoryReset() ){
//      error(F("Couldn't factory reset"));
//    }
//  }

  /* Disable command echo from Bluefruit */
  ble.echo(false);

  Serial.println("Requesting Bluefruit info:");
  /* Print Bluefruit information */
  ble.info();

  Serial.println(F("Please use Adafruit Bluefruit LE app to connect in UART mode"));
  Serial.println(F("Then Enter characters to send to Bluefruit"));
  Serial.println();

  ble.verbose(false);  // debug info is a little annoying after this point!

  /* Wait for connection */
  while (! ble.isConnected()) {
      delay(500);
  }

  // LED Activity command is only supported from 0.6.6
  if ( ble.isVersionAtLeast(MINIMUM_FIRMWARE_VERSION) )
  {
    // Change Mode LED Activity
    Serial.println(F("******************************"));
    Serial.println(F("Change LED activity to " MODE_LED_BEHAVIOUR));
    ble.sendCommandCheckOK("AT+HWModeLED=" MODE_LED_BEHAVIOUR);
    Serial.println(F("******************************"));
  }

    // Set module to DATA mode
  Serial.println( F("Switching to DATA mode!") );
  ble.setMode(BLUEFRUIT_MODE_DATA);
  
  //pinMode(LED, OUTPUT);     // Set pin as an output
  //digitalWrite(LED, LOW);
}

/**************************************************************************/
/*!
    @brief  Constantly poll for new command or response data
*/
/**************************************************************************/
void loop(void)
{

//  servo.attach(6);
   
  /* Wait for new data to arrive */
  uint8_t len = readPacket(&ble, BLE_READPACKET_TIMEOUT);
  if (len == 0) return;

  Serial.println("incoming data");
  
    // App Data
    if (packetbuffer[1] == 'B') {
      
      Serial.println("Data from Computer App");
      Serial.println("Input String: " + inString);
      Serial.println("----------------------------");
  }

   // First part of Controller data -- takes in the left trigger(reverse) and right thumbstick(not being used)
  if (packetbuffer[1] == 'C') {
    
    Serial.println("Input String: " + inString);
    Serial.println("Left Trigger: " + leftTrigger);
    Serial.println("Right Thumbstick: " + rightThumbstick);
    Serial.println(leftTrigger.toInt());
    Serial.println("----------------------------");

    
    if(leftTriggerInt == 90)  // the application sends 090 when the trigger isn't pressed. If 090 is received, set the leftTrigger value to 000
    {
      leftTriggerInt = 0;
    }

    //motor A 
    digitalWrite(in1A, HIGH);
    digitalWrite(in2A, LOW);
    analogWrite(enA, leftTriggerInt);    

    //motor B 
    digitalWrite(in1B, HIGH);
    digitalWrite(in2B, LOW);
    analogWrite(enB, leftTriggerInt);    
  }

  //Second part of Controller data -- takes in the right trigger(forward) and left thumbstick(servo control - only x-axis input taken in)
  if (packetbuffer[1] == 'D') {
    Serial.println("Input String: "+ inString);
    Serial.println("Right Trigger: " + rightTrigger);
    Serial.println("Left Thumbstick: " + leftThumbstick); 
    Serial.println(rightTriggerInt);
    Serial.println("----------------------------");

    if(rightTriggerInt == 90) // the application sends 090 when the trigger isn't pressed. If 090 is received, set the leftTrigger value to 000
    {
      rightTriggerInt = 0;
    }
    
    //motor A 
    digitalWrite(in1A, LOW);
    digitalWrite(in2A, HIGH);
    analogWrite(enA, rightTriggerInt);    

    //motor B
    digitalWrite(in1B, LOW);
    digitalWrite(in2B, HIGH);
    analogWrite(enB, rightTriggerInt);
    
//    servo

    if(leftThumbstick.toInt() != pastDegree){
      servo.write(leftThumbstick.toInt());
      pastDegree = leftThumbstick.toInt();
    }
  }
}
