% IR people counting - no plots
% takes in 8x8 array
% outputs number of detected people
function [num_people] = people_counting(data)
    % map pixel temp to 0<->1 range
    max_pixel = max(data(:))
    data_map = data / max_pixel
    
    % interpolate to 32x32 grayscale image
    [x_locs,y_locs] = meshgrid(1:8);
    [x_interp,y_interp] = meshgrid(1:0.22:8-.07); % 8x8 to 32x32
    data_interp = interp2(x_locs, y_locs, data_map, x_interp, y_interp, 'cubic');
    originalImage = mat2gray(data_interp);

    % Threshold the image to get a binary image (only 0's and 1's) of class "logical."
    % Method #1: using im2bw()
    normalizedThresholdValue = 0.95; % In range 0 to 1.
    thresholdValue = normalizedThresholdValue * max(max(originalImage)); % Gray Levels.
    binaryImage = im2bw(originalImage, normalizedThresholdValue);       % One way to threshold to binary

    % Do a "hole fill" to get rid of any background pixels or "holes" inside the blobs.
    binaryImage = imfill(binaryImage, 'holes');
     
    % Identify individual blobs by seeing which pixels are connected to each other.
    % Each group of connected pixels will be given a label, a number, to identify it and distinguish it from the other blobs.
    % Do connected components labeling with either bwlabel() or bwconncomp().
     labeledImage = bwlabel(binaryImage, 8);     % Label each blob so we can make measurements of it
    % labeledImage is an integer-valued image where all pixels in the blobs have values of 1, or 2, or 3, or ... etc.

    % Get all the blob properties.  Can only pass in originalImage in version R2008a and later.
    blobMeasurements = regionprops(labeledImage, originalImage, 'all');
    numberOfBlobs = size(blobMeasurements, 1);
    
    % Loop over all blobs printing their measurements to the command window.
    num_people = 0;
    for k = 1 : numberOfBlobs           % Loop through all blobs.
        thisBlobsPixels = blobMeasurements(k).PixelIdxList;  % Get list of pixels in current blob
        blobArea = blobMeasurements(k).Area;		% Get area.
        
        % check if blob is big enough to resemble human
        if blobArea > 7.0
            num_people = num_people + 1
        end
    end
end

