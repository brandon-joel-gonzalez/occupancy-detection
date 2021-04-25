% takes in USB port, opens it for serial comms
function [s] = grideye_initialize(portName)
    s = serial(portName); % change this to desired Arduino board port
    set(s,'BaudRate',9600); % baud rate for communication
    fopen(s); % open the comm between Arduino and MATLAB
end

