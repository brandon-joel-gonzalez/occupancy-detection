% function to run camera baseline algorithm
% returns number of people detected and image
function [num_people, IBody] = vision_detector()
    % initialize detector
    clear all;
    bodyDetector = vision.CascadeObjectDetector('UpperBody'); 
    bodyDetector.MinSize = [60 60];
    bodyDetector.Mergereshold = 10;

    % take photo
    pause(3);
    cam = webcam('/dev/video2');
    image = snapshot(cam);

    % process and label
    bboxBody = bodyDetector(image);
    num_people = size(bboxBody, 1);
    IBody = insertObjectAnnotation(image,'rectangle',bboxBody,'Upper Body');
    %figure
    %imshow(IBody)
    %title('Detected upper bodies');
end

