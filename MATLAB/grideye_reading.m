% MATLAB data for reading Arduino serial prinout data
instrreset % reset all serial ports
s = serial('/dev/ttyUSB0'); % change this to desired Arduino board port
set(s,'BaudRate',115200); % baud rate for communication
fopen(s); % open the comm between Arduino and MATLAB
out = fscanf(s); % read data
data_str = split(out,',');
n_vars = 64; % number of variables printed
data_array = zeros(n_vars,1);
for ii=1:n_vars
    data_array(ii) = str2double(data_str(ii));
end
data_grid = reshape(data_array,8,8);
imagesc(data_grid)