#include <string.h>
#include <Arduino.h>
#include <SPI.h>
#if not defined (_VARIANT_ARDUINO_DUE_X_) && not defined (_VARIANT_ARDUINO_ZERO_) && not defined(__SAMD51__)
  #include <SoftwareSerial.h>
#endif

#include "Adafruit_BLE.h"
#include "Adafruit_BluefruitLE_SPI.h"
#include "Adafruit_BluefruitLE_UART.h"

#include "BluefruitConfig.h"

#define PACKET_CONTROLLER_LEN           (40)


//    READ_BUFSIZE            Size of the read buffer for incoming packets
#define READ_BUFSIZE                    (100)


/* Buffer to hold incoming characters */
uint8_t packetbuffer[READ_BUFSIZE+1];




/* inputs */
String inString = "";
String leftTrigger;
String rightTrigger;
String leftThumbstick;
String rightThumbstick;

/*   Waits for incoming data and parses it */
uint8_t readPacket(Adafruit_BLE *ble, uint16_t timeout) 
{
  
  uint16_t origtimeout = timeout, replyidx = 0;

  memset(packetbuffer, 0, READ_BUFSIZE);
  inString = "";

  while (timeout--) {

    if (replyidx >= 40) break;
        
    if ((packetbuffer[1] == 'B') && (packetbuffer[replyidx - 1] == '$'))
      break;

    if ((packetbuffer[1] == 'C') && (packetbuffer[replyidx - 1] == '$')){
      leftTrigger = (char)packetbuffer[5]; leftTrigger.concat((char)packetbuffer[6]); leftTrigger.concat((char)packetbuffer[7]);
      rightThumbstick = (char)packetbuffer[10]; rightThumbstick.concat((char)packetbuffer[11]); rightThumbstick.concat((char)packetbuffer[12]);
      break;
    }
      

    if ((packetbuffer[1] == 'D') && (packetbuffer[replyidx - 1] == '$')){
      rightTrigger = (char)packetbuffer[5]; rightTrigger.concat((char)packetbuffer[6]); rightTrigger.concat((char)packetbuffer[7]);
      leftThumbstick = (char)packetbuffer[10]; leftThumbstick.concat((char)packetbuffer[11]); leftThumbstick.concat((char)packetbuffer[12]);
      break;
    }
      

    while (ble -> available()) {
      char c =  ble->read();
      if (c == '!') {
        replyidx = 0;
      }
      packetbuffer[replyidx] = c;
      inString += c;
      replyidx++;
      timeout = origtimeout;
      
    }
    
    if (timeout == 0) break;
    delay(1);
  }

  packetbuffer[replyidx] = 0;  // null term

  if (!replyidx)  // no data or timeout 
    return 0;
  if (packetbuffer[0] != '!')  // doesn't start with '!' packet beginning
    return 0;
  
  return replyidx;
}
