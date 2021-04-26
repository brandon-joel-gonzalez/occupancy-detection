% reading sensors for testing
instrreset % reset all serial ports
clear all;
close all;
clc;

camera = webcam('/dev/video3'); % camera for testing
grideyeName = '/dev/ttyUSB0'; % grideye data
dataPortName = '/dev/ttyUSB2'; % mmwave data
controlPortName = '/dev/ttyUSB1'; % mmwave control

dataFilename = 'test_data/scenario3_trial3.mat';
photoFilename = 'test_photos/scenario3_trial3/photo#%d.png';

% initialize grideye and wait on USB line
s = grideye_initialize(grideyeName);
while s.BytesAvailable == 0
    % wait for PIR signal
end

% n measurements, taken k seconds apart
n = 20;
k = .5;

% people reported on each measurement, with snapshot taken
% 1st index is number of people detected
% 2nd/3rd index are xy-coord of 1st target
% 4th/5th index are xy-coord of 2nd target
% 6th/7th index are xy-coord of 2nd target
% assume no more than 3 targets will be detected; all initialized to 0
data = zeros(7, n, 'double');

% begin reading grideye data
m = 1; % used to track number of grideye measurements before mmwave triggered
timesDetected = 0; % keep track of times that grideye detected someone
for i=1:n
    % take photo for evaluation
    image = snapshot(camera);
    imageFile = sprintf(photoFilename, i); % save camera image
    imwrite(image, imageFile);
    
    % read grideye data
    data_grid = rot90(grideye_read(s));% - noise);
    
    % count people
    [num_people, coordinates] = grideye_count(data_grid);
    data(1, i) = num_people; % store num detected people of frame
    for j=0:num_people
        if j == num_people
            break;
        end
        
        data(2*j+2, i) = coordinates(j+1); % store x-coord of people (depth is not tracked for grideye)
    end

    if num_people > 0
        timesDetected = timesDetected + 1;
        % show people's x-position
        for j = 1:num_people
            fprintf("person %d, x-coord: %d\n", j, coordinates(j, 1));
        end
        
        if timesDetected == 5
            break; % begin mmwave if grideye detects someone multiple times
        end
    end
    
    % wait for next reading
    m = m + 1;
    pause(k);
end
fclose(s);

% initialize mmwave
[dataPort, controlPort, params, scene, wall, cfgData] = mmwave_initialize(dataPortName, controlPortName);

% read data from mmwave and store in data vector
data = mmwave_read(dataPort, controlPort, params, scene, wall, cfgData, data, m, n, k, camera, photoFilename);

save(dataFilename, 'data'); % save results