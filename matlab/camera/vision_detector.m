% function to run camera baseline algorithm
% takes in frame index
% returns number of people detected
function [numPeople] = vision_detector(camera, imageFile)
    % initialize detector
    bodyDetector = vision.CascadeObjectDetector('UpperBody'); 
    bodyDetector.MinSize = [60 60];
    bodyDetector.MergeThreshold = 10;

    % take photo
    image = snapshot(camera);

    % process and label
    bboxBody = bodyDetector(image);
    numPeople = size(bboxBody, 1);
    IBody = insertObjectAnnotation(image,'rectangle',bboxBody,'Upper Body');
    
    % save image
    imwrite(IBody, imageFile)
    %figure
    %imshow(IBody)
    %title('Detected upper bodies');
end

