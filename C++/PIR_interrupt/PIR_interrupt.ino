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
volatile byte state = LOW;
 
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

  attachInterrupt(digitalPinToInterrupt(pir_pin), interrupt_routine, RISING);
  Serial.println("Ready!");
}
 
void loop() {
  // see if PIR interrupt was triggered
  if (state == HIGH){
    Serial.println("Detected!");
    delay(6000);

    // wait 5 seconds for retrigger

    state = LOW;
    digitalWrite(led_pin,LOW);
    Serial.println("Ready!");
  } else {
    Serial.println("Empty!");  
  }
}

void interrupt_routine() {
  state = HIGH;
  digitalWrite(led_pin, HIGH);
}
