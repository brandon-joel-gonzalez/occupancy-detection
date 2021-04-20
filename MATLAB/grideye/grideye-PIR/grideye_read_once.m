% MATLAB data for reading Arduino serial prinout data
instrreset % reset all serial ports
s = serial('/dev/ttyUSB0'); % change this to desired Arduino board port
set(s, 'BaudRate', 9600); % baud rate for communication
fopen(s); % open the comm between Arduino and MATLAB

while s.BytesAvailable == 0
    % wait for PIR signal to send char to start
end
pause(5) % wait a moment to begin reading grideye data

% read data into 8x8 array
data_grid = grideye_read(s)

% process interpolated data to extract blobs
num_people = people_counting(data_grid);

%[x_locs,y_locs] = meshgrid(1:8);
%[x_interp,y_interp] = meshgrid(1:0.03:8-.07); % interpolate 8x8 to 231x231
%data_interp = interp2(x_locs,y_locs,data_grid,x_interp,y_interp,'cubic');
%num_blobs = IR_segmentation(data_interp);
%imagesc(data_grid)