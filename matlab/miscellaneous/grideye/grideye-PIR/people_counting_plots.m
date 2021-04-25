% IR people counting - with data plots
% takes in 8x8 array
% outputs number of detected people
function [num_people, coordinates] = people_counting_plots(data)
    % map pixel temp to 0<->1 range
    max_pixel = max(data(:));
    data_map = data / max_pixel;
    
    % interpolate to 32x32 grayscale image
    [x_locs,y_locs] = meshgrid(1:8);
    [x_interp,y_interp] = meshgrid(1:0.22:8-.07); % 8x8 to 32x32
    data_interp = interp2(x_locs, y_locs, data_map, x_interp, y_interp, 'cubic');
    originalImage = mat2gray(data_interp);

    % Threshold the image to get a binary image (only 0's and 1's) of class "logical."
    % Method #1: using im2bw()
    normalizedThresholdValue = 0.95; % In range 0 to 1.
    thresholdValue = normalizedThresholdValue * max(max(originalImage)); % Gray Levels.
%     binaryImage = im2bw(originalImage, normalizedThresholdValue);       % One way to threshold to binary
    binaryImage = originalImage > thresholdValue;

    % Do a "hole fill" to get rid of any background pixels or "holes" inside the blobs.
    binaryImage = imfill(binaryImage, 'holes');
    % Show the threshold as a vertical red bar on the histogram.
    hold on;
    maxYValue = ylim;
    line([thresholdValue, thresholdValue], maxYValue, 'Color', 'r');
    % Place a text label on the bar chart showing the threshold.
    annotationText = sprintf('Thresholded at %d gray levels', thresholdValue);
    % For text(), the x and y need to be of the data class "double" so let's cast both to double.
    text(double(thresholdValue + 5), double(0.5 * maxYValue(2)), annotationText, 'FontSize', 10, 'Color', [0 .5 0]);
    text(double(thresholdValue - 70), double(0.94 * maxYValue(2)), 'Background', 'FontSize', 10, 'Color', [0 0 .5]);
    text(double(thresholdValue + 50), double(0.94 * maxYValue(2)), 'Foreground', 'FontSize', 10, 'Color', [0 0 .5]);
    % Display the binary image.
    subplot(3, 3, 3);
    imshow(binaryImage); 
    captionFontSize = 14;
    title('Binary Image, obtained by thresholding', 'FontSize', captionFontSize); 
    % Identify individual blobs by seeing which pixels are connected to each other.
    % Each group of connected pixels will be given a label, a number, to identify it and distinguish it from the other blobs.
    % Do connected components labeling with either bwlabel() or bwconncomp().
     labeledImage = bwlabel(binaryImage, 8);     % Label each blob so we can make measurements of it
    % labeledImage is an integer-valued image where all pixels in the blobs have values of 1, or 2, or 3, or ... etc.
    subplot(3, 3, 4);
    imshow(labeledImage, []);  % Show the gray scale image.
    title('Labeled Image, from bwlabel()', 'FontSize', captionFontSize);
    % Let's assign each blob a different color to visually show the user the distinct blobs.
    coloredLabels = label2rgb (labeledImage, 'hsv', 'k', 'shuffle'); % pseudo random color labels
    % coloredLabels is an RGB image.  We could have applied a colormap instead (but only with R2014b and later)
    subplot(3, 3, 5);
    imshow(coloredLabels);
    axis image; % Make sure image is not artificially stretched because of screen's aspect ratio.
    caption = sprintf('Pseudo colored labels, from label2rgb().\nBlobs are numbered from top to bottom, then from left to right.');
    title(caption, 'FontSize', captionFontSize);
    % Get all the blob properties.  Can only pass in originalImage in version R2008a and later.
    blobMeasurements = regionprops(labeledImage, originalImage, 'all');
    numberOfBlobs = size(blobMeasurements, 1);
    % bwboundaries() returns a cell array, where each cell contains the row/column coordinates for an object in the image.
    % Plot the borders of all the coins on the original grayscale image using the coordinates returned by bwboundaries.
    subplot(3, 3, 6);
    imshow(originalImage);
    title('Outlines, from bwboundaries()', 'FontSize', captionFontSize); 
    axis image; % Make sure image is not artificially stretched because of screen's aspect ratio.
    hold on;
    boundaries = bwboundaries(binaryImage);
    numberOfBoundaries = size(boundaries, 1);
    for k = 1 : numberOfBoundaries
        thisBoundary = boundaries{k};
        plot(thisBoundary(:,2), thisBoundary(:,1), 'g', 'LineWidth', 2);
    end
    hold off;
    textFontSize = 14;	% Used to control size of "blob number" labels put atop the image.
    labelShiftX = -7;	% Used to align the labels in the centers of the coins.
    blobECD = zeros(1, numberOfBlobs);
    % Print header line in the command window.
    %fprintf(1,'Blob #      Mean Intensity  Area   Perimeter    Centroid       Diameter\n');
    % Loop over all blobs printing their measurements to the command window.
    num_people = 0;
    coordinates = zeros(numberOfBlobs, 3);
    for k = 1 : numberOfBlobs           % Loop through all blobs.
        % Find the mean of each blob.  (R2008a has a better way where you can pass the original image
        % directly into regionprops.  The way below works for all versions including earlier versions.)
        thisBlobsPixels = blobMeasurements(k).PixelIdxList;  % Get list of pixels in current blob.
        meanGL = mean(originalImage(thisBlobsPixels)); % Find mean intensity (in original image!)
        meanGL2008a = blobMeasurements(k).MeanIntensity; % Mean again, but only for version >= R2008a

        blobArea = blobMeasurements(k).Area;		% Get area.
        blobPerimeter = blobMeasurements(k).Perimeter;		% Get perimeter.
        blobCentroid = blobMeasurements(k).Centroid;		% Get centroid one at a time
        blobECD(k) = sqrt(4 * blobArea / pi);					% Compute ECD - Equivalent Circular Diameter.
        %fprintf(1,'#%2d %17.1f %11.1f %8.1f %8.1f %8.1f % 8.1f\n', k, meanGL, blobArea, blobPerimeter, blobCentroid, blobECD(k));
        % Put the "blob number" labels on the "boundaries" grayscale image.
        %text(blobCentroid(1) + labelShiftX, blobCentroid(2), num2str(k), 'FontSize', textFontSize, 'FontWeight', 'Bold');
        
        % check if blob is big enough to resemble human
        if blobArea > 7.0
            num_people = num_people + 1;
            
        % get grideye coordinates
        x = blobMeasurements(k).Centroid(1);
        y = blobMeasurements(k).Centroid(2);

        % find corresponding pixel val (0<->1) in interpolated bitmap
        pix_val = data_interp(round(x), round(y));

        % map pixel from mintemp-maxtemp to z coordinate
        max_val = max(data_interp(:));
        min_val = min(data_interp(:));
        max_z = 8;
        min_z = 0;
        
        z = (pix_val - min_val) * (max_z - min_z) / (max_val - min_val) + min_z;
        coordinates(k, 1) = round(x / 4); % 32x32 to 8x8
        coordinates(k, 2) = round(y / 4);
        coordinates(k, 3) = round(z);
        end
    end
end

