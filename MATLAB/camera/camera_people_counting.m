% initialize camera
clear;
cam = webcam('/dev/video2');

% create PeopleDetector system object
peopleDetector = vision.PeopleDetector(...
'ClassificationModel', 'UprightPeople_128x64', ... % choices are UprightPeople_96x48, UprightPeople_128x64
'ClassificationThreshold', 0.5, ... % default is 1
'MinSize', [], ... % Smallest region containing a person; default is [], which is size used in training
'MaxSize', [], ... % Largest region containing a person; default is [], which is size of image
'ScaleFactor', 1.05, ... % scales between MinSize and MaxSize; default is 1.05
'WindowStride', [4 4], ... % how far window moves, default is [8 8]
'MergeDetections', false ... % merge similar detections; default is true
);

while true
   % wait and grab/resize image every few seconds
   pause(3);
   close();
   image = snapshot(cam);
   % image = imresize(image, 2);
   
   % assess image
   [bboxes,scores] = peopleDetector(image);

   % display people found
   if (~isempty(bboxes))
       image = insertObjectAnnotation(image,'rectangle',bboxes,scores);
   end
   figure, imshow(image);
   title('Detected people and detection scores');
end