% takes n measurements from the mmwave sensor, once every k seconds
n = 10;
k = 1;

dataPortName = '/dev/ttyUSB4';
controlPortName = '/dev/ttyUSB3';

[dataPort, controlPort, params, scene, wall, cfgData] = mmwave_initialize(dataPortName, controlPortName);

[numPeople, targets] = mmwave_read(dataPort, controlPort, params, scene, wall, cfgData, n, k); % read data from mmwave

    % print positions
%     for i = 1:numPeople
%         fprintf('x: %d, y: %d\n', targets(1, i), targets(2, i)) % print xy
%     end
    
%     pause(k); % wait k seconds for next measurement