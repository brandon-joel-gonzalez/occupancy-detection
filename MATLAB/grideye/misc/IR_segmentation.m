% IR image segmentation
% takes in 8x8 array
% outputs number of detected blobs
function [detected_blobs] = IR_segmentation(I)
range = [min(I(:)) max(I(:))]
figure
imshow(I,[])
colormap(gca,hot)
title('Original image')

smoothValue = 0.01*diff(range).^2;
J = imguidedfilter(I,'DegreeOfSmoothing',smoothValue);

figure
imshow(J,[])
colormap(gca,hot)
title('Guided filtered image')

thresh = multithresh(J,2)
L = imquantize(J,thresh);
L = imfill(L);

figure
imshow(label2rgb(L))
title('Label matrix from 3-level Otsu')

props = regionprops(L,I,{'Area','BoundingBox','MeanIntensity','Centroid'});

% Find the index of the background region
[~,idx] = max([props.Area]);

figure
imshow(I,[])
colormap(gca,hot)
title('Segmented regions with mean temperature')

detected_blobs = 0
for n = 1:numel(props)
    % If the region is not background
    if n ~= idx
       detected_blobs = detected_blobs +1
        % Draw bounding box around region
       rectangle('Position',props(n).BoundingBox,'EdgeColor','c')
       
       % Draw text displaying mean temperature in Celsius
       T = [num2str(props(n).MeanIntensity,3) ' \circ C'];
       text(props(n).Centroid(1),props(n).Centroid(2),T,...
           'Color','c','FontSize',12)
    end
end

end

