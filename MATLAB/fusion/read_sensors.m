% reading sensors for testing
instrreset % reset all serial ports
clear all;
close all;
clc;

camera = webcam('/dev/video2'); % camera for testing
grideyeName = '/dev/ttyUSB2'; % grideye data
dataPortName = '/dev/ttyUSB4'; % mmwave data
controlPortName = '/dev/ttyUSB3'; % mmwave control

% initialize mmwave
[dataPort, controlPort, params, scene, wall, cfgData] = mmwave_initialize(dataPortName, controlPortName);

% initialize grideye and wait on USB line
s = grideye_initialize(grideyeName);
while s.BytesAvailable == 0
    % wait for PIR signal
end

% n measurements, taken k seconds apart
n = 5;
k = 1;

% num of detected people reported on each measurement, with snapshot taken
results = zeros(1, n);

% begin reading grideye data
m = 0; % used to track number of grideye measurements before mmwave triggered
for i=1:n
    % take photo for evaluation
    image = snapshot(camera);
    imageFile = sprintf('test_photos/test_grideye#%d.png', i); % save camera image
    imwrite(image, imageFile);
    
    % read grideye data
    data_grid = rot90(grideye_read(s));% - noise);
    
    % count people
    [num_people, coordinates] = grideye_count(data_grid);
    results(1, i) = num_people; % store num detected people of frame
    m = m + 1;

    if num_people > 0
        % show people's positions
        for j = 1:num_people
            fprintf("person %d, x-coord: %d\n", j, coordinates(j, 1));
        end
       break; % begin mmwave if grideye detects someone
    end
    
    % wait for next reading
    pause(k);
end

% read data from mmwave and store in results vector
mmwave_read(dataPort, controlPort, params, scene, wall, cfgData, results, (n - m), k, camera);

save('test_data/test_sensors.mat', 'results'); % save results