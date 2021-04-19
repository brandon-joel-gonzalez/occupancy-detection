
/*
  Using Interrupts on the Panasonic Grid-EYE Sensor
  By: Nick Poole
  SparkFun Electronics
  Date: January 12th, 2018
  
  MIT License: Permission is hereby granted, free of charge, to any person obtaining a copy of this 
  software and associated documentation files (the "Software"), to deal in the Software without 
  restriction, including without limitation the rights to use, copy, modify, merge, publish, 
  distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the 
  Software is furnished to do so, subject to the following conditions:
  The above copyright notice and this permission notice shall be included in all copies or 
  substantial portions of the Software.
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING 
  BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
  DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  
  Feel like supporting our work? Buy a board from SparkFun!
  https://www.sparkfun.com/products/14568
  
  This example demonstrates the use of the GridEYE's interrupt registers. Open a serial terminal
  and you should find the device is waiting for an interrupt to fire. Once an object enters the 
  sensor's range with a temperature above the UPPER_LIMIT or below the LOWER_LIMIT, the example 
  code will display a table of all pixels and their respective interrupt states. The HYSTERESIS
  parameter may be used to stabilize sensor behavior close to the limits. I recommend running
  this example code using the default parameters at room temperature and waving a hot soldering
  iron in front of the sensor to fire the interrupt.
  
  Hardware Connections:
  Attach the Qwiic Shield to your Arduino/Photon/ESP32 or other
  Plug the sensor onto the shield
*/

#include <SparkFun_GridEYE_Arduino_Library.h>
#include <Wire.h>

// Use these values (in degrees C) to adjust the interrupt parameters
#define UPPER_LIMIT 50
#define LOWER_LIMIT 20
#define HYSTERESIS 5

GridEYE grideye;

void setup() {

  // Start your preferred I2C object 
  Wire.begin();
  // Library assumes "Wire" for I2C but you can pass something else with begin() if you like
  grideye.begin();
  // Pour a bowl of serial
  Serial.begin(9600);

  // Set interrupt parameters
  grideye.setInterruptModeAbsolute();
  grideye.setUpperInterruptValue(UPPER_LIMIT);
  grideye.setLowerInterruptValue(LOWER_LIMIT);
  grideye.setInterruptHysteresis(HYSTERESIS);

}

void loop() {

  // check every 500ms to see if the interrupt flag is set
  while(!grideye.interruptFlagSet()){
    Serial.println("waiting for interrupt flag...");
    delay(500);
  }

  // tell the user that an interrupt was fired
  Serial.println("Motion detected!");

  // read all the pixels
  Serial.print("[");
  for(int i=1; i<=64; i++){
    Serial.print(grideye.getPixelTemperature(i-1));
    Serial.print(", ");
    if( i%8 == 0 ) Serial.println();
  }
  Serial.println("]");
  Serial.println();

  // clear the interrupt flag bit in the device register
  grideye.clearInterruptFlag();

}
