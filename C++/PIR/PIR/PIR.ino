//
// Credit to https://how2electronics.com/interface-panasonic-pir-motion-sensor-with-arduino/
//

#define PIR 7
#define PIR_THRESH 6000
 
void setup()
{
  Serial.begin(9600);
  pinMode(PIR, INPUT);

  Serial.println("Sensor Initializing.....");
  delay(5000);
  Serial.println("Setup Completed");
  delay(100);
}

void loop() 
{
  int duration = pulseIn(PIR,HIGH);

  if(duration < PIR_THRESH)
    Serial.println("Motion Detected");
  else
    Serial.println("No Motion");

  Serial.print(duration);

  delay(1000);
}
