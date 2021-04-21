% test bench for camera baseline

% n measurements, taken k seconds apart
n = 5;
k = 1;

% 1st row to store num of detected people reported
% 2nd row to store manual evaluation of individuals detected
% 3rd row to store manual evaluation of false positives
results = zeros(2, n);

% take n measurements
for i=1:n
    [numPeople, img] = vision_detector() % run vision algorithm
    
    imageFile = sprintf('test_photos/test_camera#%d.png', i); % save camera image
    imwrite(img, imageFile)
    
    results(1, i) = numPeople % save num detected people
    pause(k)
end

save('test_data/test_camera.mat', 'results') % save results
    


