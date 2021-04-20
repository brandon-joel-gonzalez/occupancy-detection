% initialize detector
clear all;
bodyDetector = vision.CascadeObjectDetector('UpperBody'); 
bodyDetector.MinSize = [60 60];
bodyDetector.MergeThreshold = 10;

% take photo
pause(3);
cam = webcam('/dev/video2');
image = snapshot(cam);

% process and label
bboxBody = bodyDetector(image);
IBody = insertObjectAnnotation(image,'rectangle',bboxBody,'Upper Body');
figure
imshow(IBody)
title('Detected upper bodies');