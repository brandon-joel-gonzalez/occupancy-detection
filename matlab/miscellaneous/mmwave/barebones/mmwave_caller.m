% reads data from the mmwave sensor every k seconds
k = 1;

dataPortName = '/dev/ttyUSB3';
controlPortName = '/dev/ttyUSB2';

[dataPort, params, scene] = mmwave_initialize(dataPortName, controlPortName);

while true
    [numPeople, targets] = mmwave_read(dataPort, params, scene); % read data from mmwave
    
    % print positions
    for i = 1:numPeople
        fprintf('x: %d, y: %d\n', targets(1, i), targets(2, i)) % print xy
    end
    
    pause(k); % wait k seconds for next measurement
end