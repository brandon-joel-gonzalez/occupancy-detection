% reading sensors for testing

% n measurements, taken k seconds apart
n = 5;
k = 1;

% num of detected people reported on each measurement, with image
results = zeros(1, n);

instrreset % reset all serial ports
clear all;
close all;
clc;

camera = webcam('/dev/video2'); % camera for testing
s = serial('/dev/ttyUSB0'); % change this to desired Arduino board port
set(s,'BaudRate',9600); % baud rate for communication
fopen(s); % open the comm between Arduino and MATLAB

while s.BytesAvailable == 0
    % wait for PIR signal
end
pause(5); % wait a moment to begin reading grideye/mmwave data

% grideye noise measurement
noise = grideye_read(s);
mean_noise = mean(mean(noise)); % calculate mean noise
noise = noise-mean_noise; % subtract mean noise from each pixel's noise

% begin reading grideye data
m = 1;
for i=1:n
    % take photo for evaluation
    image = snapshot(camera);
    imageFile = sprintf('test_photos/test_camera#%d.png', i); % save camera image
    imwrite(IBody, imageFile);
    
    % read grideye data
    data_grid = grideye_read(s) - noise;
    
    % count people from grideye
    num_people = grideye_count(data_grid);
    
    results(1, i) = numPeople; % store num detected people of frame
    m = m + 1;
    
    % begin mmwave if grideye detects someone
    if num_people > 0
       break 
    end
    
    % wait for next reading
    pause(k);
end

% START MMWAVE

% begin reading mmwave data
for i=m:n
    % take photo for manual evaluation
    image = snapshot(camera);
    imageFile = sprintf('test_photos/test_camera#%d.png', i); % save camera image
    imwrite(IBody, imageFile);
    
    % count people from mmwave
    % num_people = mmwave_count
    
    % wait for next reading
    results(1, i) = numPeople; % store num detected people of frame
    pause(k);
end

save('test_data/test_sensors.mat', 'results'); % save results