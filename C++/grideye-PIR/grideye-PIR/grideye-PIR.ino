/***************************************************************************
  This is a library for the AMG88xx GridEYE 8x8 IR camera

  This sketch tries to read the pixels from the sensor

  Designed specifically to work with the Adafruit AMG88 breakout
  ----> http://www.adafruit.com/products/3538

  These sensors use I2C to communicate. The device's I2C address is 0x69

  Adafruit invests time and resources providing this open source code,
  please support Adafruit andopen-source hardware by purchasing products
  from Adafruit!

  Written by Dean Miller for Adafruit Industries.
  BSD license, all text above must be included in any redistribution
 ***************************************************************************/

#include <Wire.h>
#include <Adafruit_AMG88xx.h>

Adafruit_AMG88xx amg;
float pixels[AMG88xx_PIXEL_ARRAY_SIZE];

// Define pins for LEDs
int led_pin = LED_BUILTIN;
// Input from Motion Sensor
int pir_pin = 3;
// Variable for Motion Detected
int motionDetected = 0;
// Variable to store value from PIR
int pirValue;
// trigger grideye if PIR detects
int triggerGrideye = 0;

void setup() {
    Serial.begin(9600);
//    Serial.println(F("GRIDEYE TEST"));

    bool status;
    
    // default settings
    amg.begin();
    
//    Serial.println("-- Pixels Test --");

//    Serial.println();

    // Setup LEDs as Outputs
    pinMode(led_pin, OUTPUT);
    // Setup PIR as Input
    pinMode(pir_pin, INPUT);

    digitalWrite(led_pin, HIGH);
    delay(300); // let sensors boot up
    digitalWrite(led_pin, LOW);
//    Serial.println("Ready!");
}

void loop() {
//    // wait for PIR to detect something - this line breaks the MATLAB reader
//    while (digitalRead(pir_pin) == 0 && triggerGrideye == 0);// { Serial.println("No motion."); }
//
//    // first time PIR detects movement
//    if (triggerGrideye == 0) {
//      // Display Triggered LED for 3 seconds
//      digitalWrite(led_pin, HIGH);
////      Serial.println("Detected!");
//      triggerGrideye = 1;
//      
//      delay(300);
//      digitalWrite(led_pin, LOW);
////      Serial.println("Begin grideye!");
//    } else {
      readGrideye(); // otherwise, look for grideye data
//    }
}

void readGrideye() {
    // read grideye data
    amg.readPixels(pixels);
    
    // Print the temperature of each pixel
    for(unsigned char i = 0; i < 64; i++)
    {
      Serial.print(pixels[i]);
      Serial.print(",");
    } 
    // end print with return
    Serial.println();
    // short delay between sends
    delay(50);
}
