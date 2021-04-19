% setup
MOTION_PIN = "D7";
a = arduino('/dev/ttyACM0','Uno');
configurePin(a, MOTION_PIN, 'DigitalInput');

% loop
while true
  proximity = readDigitalPin(a, MOTION_PIN);
  
  if (proximity == 1)
    disp('Motion detected!');
  else
    disp('No motion...');

  end
end