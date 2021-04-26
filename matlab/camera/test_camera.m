% reading photos for testing
clear all;
camera = webcam('/dev/video3');

dataFilename = 'test_data/scenario3_trial3.mat';
photoFilename = 'test_photos/scenario3_trial3/photo#%d.png';

% n measurements, each taken k seconds apart (k should be a multiple of n)
n = 20;
k = .5;

% num of detected people reported on each measurement
data = zeros(1, n);

% take n measurements
for i=1:n
    imageFile = sprintf(photoFilename, i); % save camera image
    [numPeople] = vision_detector(camera, imageFile); % run vision algorithm
    data(1, i) = numPeople; % store num detected people in frame
    pause(k); % wait k seconds to next measurement
end

save(dataFilename, 'data'); % save results