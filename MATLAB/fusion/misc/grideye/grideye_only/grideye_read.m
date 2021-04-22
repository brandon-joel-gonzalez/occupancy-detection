% function to read 8x8 data from grideye over serial port
% s is the serial port being read (already configured/opened)
% data_grid is the 8x8 array
function [data_grid] = grideye_read(s)
    out = fscanf(s); % read data
    data_str = split(out, ',');
    n_vars = 64; % number of variables printed
    data_array = zeros(n_vars,1);
    for ii=1:n_vars
        data_array(ii) = str2double(data_str(ii));
    end
    data_grid = reshape(data_array,8,8);
end

