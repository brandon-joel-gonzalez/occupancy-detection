% reading camera for testing
clear all
camera = webcam('/dev/video2');

% n measurements, taken k seconds apart
n = 5;
k = 1;

% num of detected people reported on each measurement, with image
results = zeros(1, n);
%images = zeros(n, 1080, 1920, 3);

% take n measurements
for i=1:n
    [numPeople] = vision_detector(camera, i); % run vision algorithm
    results(1, i) = numPeople; % store num detected people in frame
    pause(k); % wait k seconds to next measurement
end

save('test_data/test_camera.mat', 'results'); % save results