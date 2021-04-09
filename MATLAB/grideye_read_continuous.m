% MATLAB data for reading Arduino serial prinout data
instrreset % reset all serial ports
clear all
close all
clc

s = serial('/dev/ttyUSB0'); % change this to desired Arduino board port
set(s,'BaudRate',115200); % baud rate for communication
fopen(s); % open the comm between Arduino and MATLAB

% figure and axes parameters
f1 = figure();
screen = get(0,'screensize');
fig_span = 0.75; % figure size 90% of screen
set(gcf,'Position',[((1.0-fig_span)/2.0)*screen(3),((1.0-fig_span)/2.0)*screen(4),...
    (fig_span*screen(3))-((1.0-fig_span)/2.0)*screen(3),(fig_span*screen(4))-((1.0-fig_span)/2.0)*screen(3)],...
    'color',[252.0,252.0,252.0]/256.0)
loop_break = true; % dummy variable to exit loop when BREAK is pressed
dialogBox = uicontrol('Style', 'PushButton', 'String', 'Break Loop','Callback', 'loop_break = false;');
% plot zeros so we can just update it later
[x_locs,y_locs] = meshgrid(1:8);
[x_interp,y_interp] = meshgrid(1:0.07:8-.07); % interpolate 8x8 to 100x100

% Sensor noise measurement
% for this: place a large object with uniform temperature in
% front of sensor (book, wall, table) - this is a psuedo calibration
out = fscanf(s); % read data
data_parse = split(out,','); % split by comma
data_array = zeros(64,1); 
for ii = 1:64
    data_array(ii) = str2double(data_parse(ii)); % convert to double
end
noise = reshape(data_array,[8,8]);
mean_noise = mean(mean(noise)); % calculate mean noise
noise = noise-mean_noise; % subtract mean noise from each pixel's noise
    
plot_bounds = [mean_noise-2 26]; % plot bounds - If colder or hotter are expected  - this may be changed
while loop_break 
    out = fscanf(s);
    data_parse = split(out,',');
    data_array = zeros(64,1);
    for ii = 1:64
        data_array(ii) = str2double(data_parse(ii));
    end
    data_array = reshape(data_array,[8,8])-noise;
    cla()
    % interpolate and plot onto image
    data_interp = interp2(x_locs,y_locs,data_array,x_interp,y_interp,'cubic');
    imagesc(data_interp,plot_bounds)
    c1 = colorbar; % colorbar for temperature reading
    ylabel(c1,'Temperature [C]','FontSize',16)
    pause(0.05) % briefly pause to allow graphics to catch-up
end