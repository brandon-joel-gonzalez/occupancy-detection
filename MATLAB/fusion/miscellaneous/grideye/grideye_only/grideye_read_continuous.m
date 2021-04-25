% MATLAB data for reading Arduino serial prinout data
instrreset % reset all serial ports
clear all
close all
clc

s = serial('/dev/ttyUSB0'); % change this to desired Arduino board port
set(s,'BaudRate',9600); % baud rate for communication
fopen(s); % open the comm between Arduino and MATLAB

% Sensor noise measurement
% for this: place a large object with uniform temperature in
% front of sensor (book, wall, table) - this is a psuedo calibration
noise = grideye_read(s);
mean_noise = mean(mean(noise)); % calculate mean noise
noise = noise-mean_noise; % subtract mean noise from each pixel's noise
    
% plot_bounds = [mean_noise-2 26]; % plot bounds - If colder or hotter are expected  - this may be changed
while true
    % read data
    data_grid = grideye_read(s) - noise
    
    % count people
    num_people = people_counting(data_grid);
    disp(num_people)
    
    % wait for next reading
    pause(5)
end