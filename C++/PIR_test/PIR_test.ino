/*
  HC-SR501 Motion Sensor Demonstration 1
  HC-SR501-Demo1.ino
  Motion Sensor with Delay
  Set sensor for 3-second trigger
  DroneBot Workshop 2018
  https://dronebotworkshop.com
*/

// Define pins for LEDs
int led_pin = LED_BUILTIN;

// Input from Motion Sensor
int pir_pin = 3;

// Variable for Motion Detected
int motionDetected = 0;

// Variable to store value from PIR
int pirValue;

void setup() {
  Serial.begin(9600);

  // Setup LEDs as Outputs
  pinMode(led_pin, OUTPUT);

  // Setup PIR as Input
  pinMode(pir_pin, INPUT);

  // Initial 1 Minute Delay to stabilize sensor
  digitalWrite(led_pin, HIGH);
  delay(60000);
  digitalWrite(led_pin, LOW);
  Serial.println("Ready!");
}

void loop() {
  // Get value from motion sensor
  pirValue = digitalRead(pir_pin);

  // See if motion detected
  if (pirValue == 1) {
    // Display Triggered LED for 3 seconds
    digitalWrite(led_pin, HIGH);
    motionDetected = 1;
    Serial.println("Detected!");
    delay(3000);
  } else {
    Serial.println("Empty!");
    digitalWrite(led_pin, LOW);
  }

  // Add delay after triggering to reset sensor
  if (motionDetected == 1) {
    // After trigger wait 6 seconds to re-arm
    digitalWrite(led_pin, LOW);
    delay(6000);
    motionDetected = 0;
    Serial.println("Ready!");
  }

}
