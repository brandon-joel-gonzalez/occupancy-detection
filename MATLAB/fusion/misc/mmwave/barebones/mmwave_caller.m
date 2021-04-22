% reads data from the mmwave sensor every k seconds
k = 1;

dataPortName = '/dev/ttyUSB3';
controlPortName = '/dev/ttyUSB2';

[dataPort, params, scene] = mmwave_initialize(dataPortName, controlPortName);

while true
    numPeople = mmwave_read(dataPort, params, scene); % read data from mmwave
    disp(numPeople);
    pause(k); % wait k seconds for next measurement
end