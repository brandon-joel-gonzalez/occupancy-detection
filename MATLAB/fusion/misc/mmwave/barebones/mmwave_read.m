% mmwave reading function
% no GUI elements
% takes in data port, cfg parameters, and scene
% returns num of targets located, along with positions/velocities
function [numTargets, targets] = mmwave_read(hDataSerialPort, Params, scene)

    %% Init variables
%     trackerRun = 'Target';
%     colors='brgcm';
%     labelTrack = 0;

    %sensor parameters
    %sensor.rangeMax = 6;
    sensor.rangeMax = Params.dataPath.numRangeBins*Params.dataPath.rangeIdxToMeters;
    sensor.rangeMin = 1;
    sensor.azimuthFoV = 120*pi/180; %120 degree FOV in horizontal direction
    sensor.framePeriod = Params.frameCfg.framePeriodicity;
    sensor.maxURadialVelocity = 20;
%     sensor.angles = linspace(-sensor.azimuthFoV/2, sensor.azimuthFoV/2, 128);

%     hTargetBoxHandle = [];
%     peopleCountTotal = 0;
%     peopleCountInBox = zeros(1, scene.numberOfTargetBoxes);
%     rxData = zeros(10000,1,'uint8');

    maxNumTracks = 20;
%     maxNumPoints = 250;
% 
%     hPlotCloudHandleAll = [];
%     hPlotCloudHandleOutRange = [];
%     hPlotCloudHandleClutter = [];
%     hPlotCloudHandleStatic = [];
%     hPlotCloudHandleDynamic =[];
%     hPlotPoints3D = [];
% 
%     clutterPoints = zeros(2,1);
%     activeTracks = zeros(1, maxNumTracks);
% 
%     trackingHistStruct = struct('tid', 0, 'allocationTime', 0, 'tick', 0, 'posIndex', 0, 'histIndex', 0, 'sHat', zeros(1000,6), 'ec', zeros(1000,9),'pos', zeros(100,2), 'hMeshU', [], 'hMeshG', [], 'hPlotAssociatedPoints', [], 'hPlotTrack', [], 'hPlotCentroid', []);
%     trackingHist = repmat(trackingHistStruct, 1, maxNumTracks);


    %% Data structures
    syncPatternUINT64 = typecast(uint16([hex2dec('0102'),hex2dec('0304'),hex2dec('0506'),hex2dec('0708')]),'uint64');
    syncPatternUINT8 = typecast(uint16([hex2dec('0102'),hex2dec('0304'),hex2dec('0506'),hex2dec('0708')]),'uint8');

    frameHeaderStructType = struct(...
        'sync',             {'uint64', 8}, ... % See syncPatternUINT64 below
        'version',          {'uint32', 4}, ...
        'platform',         {'uint32', 4}, ...
        'timestamp',        {'uint32', 4}, ... % 600MHz clocks
        'packetLength',     {'uint32', 4}, ... % In bytes, including header
        'frameNumber',      {'uint32', 4}, ... % Starting from 1
        'subframeNumber',   {'uint32', 4}, ...
        'chirpMargin',      {'uint32', 4}, ... % Chirp Processing margin, in ms
        'frameMargin',      {'uint32', 4}, ... % Frame Processing margin, in ms
        'uartSentTime' ,    {'uint32', 4}, ... % Time spent to send data, in ms
        'trackProcessTime', {'uint32', 4}, ... % Tracking Processing time, in ms
        'numTLVs' ,         {'uint16', 2}, ... % Number of TLVs in thins frame
        'checksum',         {'uint16', 2});    % Header checksum

    tlvHeaderStruct = struct(...
        'type',             {'uint32', 4}, ... % TLV object Type
        'length',           {'uint32', 4});    % TLV object Length, in bytes, including TLV header 

    % Point Cloud TLV object consists of an array of points. 
    % Each point has a structure defined below
    pointStruct = struct(...
        'range',            {'float', 4}, ... % Range, in m
        'angle',            {'float', 4}, ... % Angel, in rad
        'doppler',          {'float', 4}, ... % Doplper, in m/s
        'snr',              {'float', 4});    % SNR, ratio
    % Target List TLV object consists of an array of targets. 
    % Each target has a structure define below
    targetStruct = struct(...
        'tid',              {'uint32', 4}, ... % Track ID
        'posX',             {'float', 4}, ... % Target position in X dimension, m
        'posY',             {'float', 4}, ... % Target position in Y dimension, m
        'velX',             {'float', 4}, ... % Target velocity in X dimension, m/s
        'velY',             {'float', 4}, ... % Target velocity in Y dimension, m/s
        'accX',             {'float', 4}, ... % Target acceleration in X dimension, m/s2
        'accY',             {'float', 4}, ... % Target acceleration in Y dimension, m/s
        'EC',               {'float', 9*4}, ... % Tracking error covariance matrix, [3x3], in range/angle/doppler coordinates
        'G',                {'float', 4});    % Gating function gain

    frameHeaderLengthInBytes = lengthFromStruct(frameHeaderStructType);
    tlvHeaderLengthInBytes = lengthFromStruct(tlvHeaderStruct);
    pointLengthInBytes = lengthFromStruct(pointStruct);
    targetLengthInBytes = lengthFromStruct(targetStruct);
    indexLengthInBytes = 1;

%     exitRequest = 0;
    lostSync = 0;
    gotHeader = 0;
    outOfSyncBytes = 0;
    runningSlow = 0;
    maxBytesAvailable = 0;
%     point3D = [];

    frameStatStruct = struct('targetFrameNum', [], 'bytes', [], 'numInputPoints', 0, 'numOutputPoints', 0, 'timestamp', 0, 'start', 0, 'benchmarks', [], 'done', 0, ...
        'pointCloud', [], 'targetList', [], 'indexArray', []);
    fHist = repmat(frameStatStruct, 1, 10000);
    %videoFrame = struct('cdata',[],'colormap', []);
    %F = repmat(videoFrame, 10000,1);
%     optimize = 1;
%     skipProcessing = 0;
    frameNum = 1;
%     frameNumLogged = 1;
%     fprintf('------------------\n');
    
    %% read data
    frameStart = tic;
    fHist(frameNum).timestamp = frameStart;
    bytesAvailable = get(hDataSerialPort,'BytesAvailable');
    if(bytesAvailable > maxBytesAvailable)
        maxBytesAvailable = bytesAvailable;
    end
    fHist(frameNum).bytesAvailable = bytesAvailable;
    if(gotHeader == 0)
        %Read the header first
        [rxHeader, byteCount] = fread(hDataSerialPort, frameHeaderLengthInBytes, 'uint8');
    end
    fHist(frameNum).start = 1000*toc(frameStart);

    magicBytes = typecast(uint8(rxHeader(1:8)), 'uint64');
    if(magicBytes ~= syncPatternUINT64)
        reason = 'No SYNC pattern';
        lostSync = 1;
    end
    if(byteCount ~= frameHeaderLengthInBytes)
        reason = 'Header Size is wrong';
        lostSync = 1;
    end        
    if(validateChecksum(rxHeader) ~= 0)
        reason = 'Header Checksum is wrong';
        lostSync = 1; 
    end

    frameHeader = readToStruct(frameHeaderStructType, rxHeader);

    if(gotHeader == 1)
        if(frameHeader.frameNumber > targetFrameNum)
            targetFrameNum = frameHeader.frameNumber;
            disp(['Found sync at frame ',num2str(targetFrameNum),'(',num2str(frameNum),'), after ', num2str(1000*toc(lostSyncTime),3), 'ms']);
            gotHeader = 0;
        else
            reason = 'Old Frame';
            gotHeader = 0;
            lostSync = 1;
        end
    end

    % We have a valid header
    targetFrameNum = frameHeader.frameNumber;
    fHist(frameNum).targetFrameNum = targetFrameNum;
    fHist(frameNum).header = frameHeader;

    dataLength = frameHeader.packetLength - frameHeaderLengthInBytes;

    fHist(frameNum).bytes = dataLength; 
%     numInputPoints = 0;
    numTargets = 0;
%     mIndex = [];
    targets = [];

    if(dataLength > 0)
        %Read all packet
        [rxData, byteCount] = fread(hDataSerialPort, double(dataLength), 'uint8');
        if(byteCount ~= double(dataLength))
            reason = 'Data Size is wrong'; 
            lostSync = 1;  
        end
        offset = 0;

        fHist(frameNum).benchmarks(1) = 1000*toc(frameStart);

        % TLV Parsing
        for nTlv = 1:frameHeader.numTLVs
            tlvType = typecast(uint8(rxData(offset+1:offset+4)), 'uint32');
            tlvLength = typecast(uint8(rxData(offset+5:offset+8)), 'uint32');
            if(tlvLength + offset > dataLength)
                reason = 'TLV Size is wrong';
                lostSync = 1;
                break;                    
            end
            offset = offset + tlvHeaderLengthInBytes;
            valueLength = tlvLength - tlvHeaderLengthInBytes;
            switch(tlvType)
                case 6
                    % Point Cloud TLV
                    numInputPoints = valueLength/pointLengthInBytes;
                    if(numInputPoints > 0)                        
                        % Get Point Cloud from the sensor
                        p = typecast(uint8(rxData(offset+1: offset+valueLength)),'single');

                        pointCloud = reshape(p,4, numInputPoints);    
%                            pointCloud(2,:) = pointCloud(2,:)*pi/180;

                        posAll = [pointCloud(1,:).*sin(pointCloud(2,:)); pointCloud(1,:).*cos(pointCloud(2,:))];
                        snrAll = pointCloud(4,:);

                        % Remove out of Range, Behind the Walls, out of FOV points
                        inRangeInd = (pointCloud(1,:) > 1) & (pointCloud(1,:) < 6) & ...
                            (pointCloud(2,:) > -50*pi/180) &  (pointCloud(2,:) < 50*pi/180) & ...
                            (posAll(1,:) > scene.areaBox(1)) & (posAll(1,:) < (scene.areaBox(1) + scene.areaBox(3))) & ...
                            (posAll(2,:) > scene.areaBox(2)) & (posAll(2,:) < (scene.areaBox(2) + scene.areaBox(4)));
                        pointCloudInRange = pointCloud(:,inRangeInd);
                        posInRange = posAll(:,inRangeInd);
%{
                        % Clutter removal
                        staticInd = (pointCloud(3,:) == 0);        
                        clutterInd = ismember(pointCloud(1:2,:)', clutterPoints', 'rows');
                        clutterInd = clutterInd' & staticInd;
                        clutterPoints = pointCloud(1:2,staticInd);
                        pointCloud = pointCloud(1:3,~clutterInd);
%}
                        numOutputPoints = size(pointCloud,2);                          
                    end                        
                    offset = offset + valueLength;

                case 7
                    % Target List TLV
                    numTargets = valueLength/targetLengthInBytes;                        
                    TID = zeros(1,numTargets);
                    S = zeros(6, numTargets);
                    EC = zeros(9, numTargets);
                    G = zeros(1,numTargets);                        
                    for n=1:numTargets
                        TID(n)  = typecast(uint8(rxData(offset+1:offset+4)),'uint32');      %1x4=4bytes
                        S(:,n)  = typecast(uint8(rxData(offset+5:offset+28)),'single');     %6x4=24bytes
                        EC(:,n) = typecast(uint8(rxData(offset+29:offset+64)),'single');    %9x4=36bytes
                        G(n)    = typecast(uint8(rxData(offset+65:offset+68)),'single');    %1x4=4bytes
                        offset = offset + 68;
                    end
                    targets = S; % save target positions/velocities

                case 8
                    % Target Index TLV
                    numIndices = valueLength/indexLengthInBytes;
                    mIndex = typecast(uint8(rxData(offset+1:offset+numIndices)),'uint8');
                    offset = offset + valueLength;
            end
        end
    end

    if(bytesAvailable > 32000)
        runningSlow  = 1;
    elseif(bytesAvailable < 1000)
        runningSlow = 0;
    end

    if(runningSlow)
        % Don't pause, we are slow
    else
        pause(0.01);
    end
%{
% To catch up, we read and discard all uart data
bytesAvailable = get(hDataSerialPort,'BytesAvailable');
disp(bytesAvailable);
[rxDataDebug, byteCountDebug] = fread(hDataSerialPort, bytesAvailable, 'uint8');
%}    
    while(lostSync)
        for n=1:8
            [rxByte, byteCount] = fread(hDataSerialPort, 1, 'uint8');
            if(rxByte ~= syncPatternUINT8(n))
                outOfSyncBytes = outOfSyncBytes + 1;
                break;
            end
        end
        if(n == 8)
            lostSync = 0;
            frameNum = frameNum + 1;
            if(frameNum > 10000)
                frameNum = 1;
            end

            [header, byteCount] = fread(hDataSerialPort, frameHeaderLengthInBytes - 8, 'uint8');
            rxHeader = [syncPatternUINT8'; header];
            byteCount = byteCount + 8;
            gotHeader = 1;
        end
    end
    
end

%% Helper functions

%Display Chirp parameters in table on screen
function h = displayChirpParams(Params, Position, hFig)

    dat =  {'Start Frequency (Ghz)', Params.profileCfg.startFreq;...
            'Slope (MHz/us)', Params.profileCfg.freqSlopeConst;...   
            'Samples per chirp', Params.profileCfg.numAdcSamples;...
            'Chirps per frame',  Params.dataPath.numChirpsPerFrame;...
            'Frame duration (ms)',  Params.frameCfg.framePeriodicity;...
            'Sampling rate (Msps)', Params.profileCfg.digOutSampleRate / 1000;...
            'Bandwidth (GHz)', Params.profileCfg.freqSlopeConst * Params.profileCfg.numAdcSamples /...
                               Params.profileCfg.digOutSampleRate;...
            'Range resolution (m)', Params.dataPath.rangeResolutionMeters;...
            'Velocity resolution (m/s)', Params.dataPath.dopplerResolutionMps;...
            'Number of Rx (MIMO)', Params.dataPath.numRxAnt; ...
            'Number of Tx (MIMO)', Params.dataPath.numTxAnt;};
    columnname =   {'Chirp Parameter (Units)      ', 'Value'};
    columnformat = {'char', 'numeric'};
    
    h = uitable('Parent',hFig,'Units','normalized', ...
            'Position', Position, ...
            'Data', dat,... 
            'ColumnName', columnname,...
            'ColumnFormat', columnformat,...
            'ColumnWidth', 'auto',...
            'RowName',[]);
end

function length = lengthFromStruct(S)
    fieldName = fieldnames(S);
    length = 0;
    for n = 1:numel(fieldName)
        [~, fieldLength] = S.(fieldName{n});
        length = length + fieldLength;
    end
end

function [R] = readToStruct(S, ByteArray)
    fieldName = fieldnames(S);
    offset = 0;
    for n = 1:numel(fieldName)
        [fieldType, fieldLength] = S.(fieldName{n});
        R.(fieldName{n}) = typecast(uint8(ByteArray(offset+1:offset+fieldLength)), fieldType);
        offset = offset + fieldLength;
    end
end

function CS = validateChecksum(header)
    h = typecast(uint8(header),'uint16');
    a = uint32(sum(h));
    b = uint16(sum(typecast(a,'uint16')));
    CS = uint16(bitcmp(b));
end
