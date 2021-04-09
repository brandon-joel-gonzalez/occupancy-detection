//
// combination of grideye + PIR sensors
//

#include <Wire.h>
#include <Adafruit_AMG88xx.h>

Adafruit_AMG88xx amg;

float pixels[AMG88xx_PIXEL_ARRAY_SIZE];

#define PIR 7
#define PIR_THRESH 6000

void setup()
{
    Serial.begin(9600);

    bool status;
    // default settings
    status = amg.begin();
    if (!status) {
        Serial.println("Could not find a valid AMG88xx sensor, check wiring!");
        while (1);
    }
    Serial.println("Grideye Setup Completed");

    pinMode(PIR, INPUT);
    delay(10000);
    Serial.println("PIR Setup Completed");
    
    delay(3000); // sensors booted
}


void loop()
{ 
     // grideye - read all the pixels
    amg.readPixels(pixels);

    Serial.print("[");
    for(int i=1; i<=AMG88xx_PIXEL_ARRAY_SIZE; i++){
      Serial.print(pixels[i-1]);
      Serial.print(", ");
      if( i%8 == 0 ) Serial.println();
    }
    Serial.println("]");
    Serial.println();

    // PIR - 
    int duration = pulseIn(PIR,HIGH);

    Serial.print(duration);
    
    if(duration < PIR_THRESH)
      Serial.println(" - Motion Detected");
    else
      Serial.println(" - No Motion");

    //delay a second
    delay(1000);
}
