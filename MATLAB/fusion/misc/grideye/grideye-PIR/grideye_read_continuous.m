% MATLAB data for reading Arduino serial prinout data
instrreset % reset all serial ports
clear all
close all
clc

s = serial('/dev/ttyUSB0'); % change this to desired Arduino board port
set(s,'BaudRate',9600); % baud rate for communication
fopen(s); % open the comm between Arduino and MATLAB

while s.BytesAvailable == 0
    % wait for PIR signal
end
pause(1) % wait a moment to begin reading grideye data

% Sensor noise measurement
% for this: place a large object with uniform temperature in
% front of sensor (book, wall, table) - this is a psuedo calibration
noise = grideye_read(s);
mean_noise = mean(mean(noise)); % calculate mean noise
noise = noise-mean_noise; % subtract mean noise from each pixel's noise

figure;
hold;
xlim([0 8]);
ylim([0 8]);
xlabel('x position');
ylabel('z position');

while true
    % read data
    data_grid = grideye_read(s) - noise;
    
    % count people
    [num_people, coordinates] = people_counting(data_grid);
    
    % plot people
    cla
    for i = 1:num_people
        x = coordinates(i, 1);
        z = coordinates(i, 2);
        scatter(x, z, 'filled');
    end
    
    % wait for next reading
    pause(1)
end