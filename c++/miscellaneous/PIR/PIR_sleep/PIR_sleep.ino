/*
  HC-SR501 Motion Sensor Demonstration 1
  HC-SR501-Demo1.ino
  Motion Sensor with Delay
  Set sensor for 3-second trigger
  DroneBot Workshop 2018
  https://dronebotworkshop.com
*/
 
// Define pins for LEDs
int detectedLED = LED_BUILTIN;
 
// Input from Motion Sensor
int pirPin = A3;
 
// Variable for Motion Detected
int motionDetected = 0;
 
// Variable to store value from PIR
int pirValue; 
 
 
void setup() {
  Serial.begin(9600);
  
  // Setup LEDs as Outputs
  pinMode(detectedLED, OUTPUT);
  
  // Setup PIR as Input
  pinMode(pirPin, INPUT);
 
  // Initial 1 Minute Delay to stabilize sensor
  digitalWrite(detectedLED, HIGH);
  delay(60000);
  digitalWrite(detectedLED, LOW);
  Serial.println("Ready!");
}
 
void loop() {
  // Get value from motion sensor
  pirValue = digitalRead(pirPin);
  
  // See if motion Detxected
  if (pirValue == 1){
    // Display Triggered LED for 3 seconds
    digitalWrite(detectedLED, HIGH);
    motionDetected = 1;
    Serial.println("Detected!");
    delay(3000);
  } else {
    Serial.println("Empty!");
    digitalWrite(detectedLED, LOW);
  }
  
  // Add delay after triggering to reset sensor
  if (motionDetected == 1) {
    // After trigger wait 6 seconds to re-arm
    digitalWrite(detectedLED, LOW);
    delay(6000);
    motionDetected = 0;
    Serial.println("Ready!");
  }
  
}
