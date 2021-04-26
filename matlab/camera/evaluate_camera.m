% use to manually evaluate results of camera
dataFilename = 'test_data/scenario3_trial3.mat';
photoFilename = 'test_photos/scenario3_trial3/photo#%d.png';
resultsFilename = 'test_results/scenario3_trial3.mat';

% evaluate n measurements
n = 20;
good = 0; % +1 if correct # of individuals reported on a frame, +0 otherwise
missed = 0; % +1 if individual missed on a frame, +0 otherwise
lied = 0; % +1 if individual falsely reported on a frame, +0 otherwise
totalPeople = 0; % total number of individuals in the scene across all frames

% assess each measurement
data = importdata(dataFilename);
for i=1:n
    % show ith image
    imageFile = sprintf(photoFilename, i);
    image = imread(imageFile);
    imshow(image);
    
    numPeople = input('How many people do you see?');
    if (numPeople == data(i))
        good = good + 1;
    end
    
    numMissed = input('How many people were missed?');
    if (numMissed ~= 0)
        missed = missed + numMissed;
    end
    
    numFalse = input('How many people were falsely reported?');
    if (numFalse ~= 0)
        lied = lied + numFalse;
    end
    
    % keep track of total number of people across all frames
    totalPeople = totalPeople + numPeople;
end

% compute evaluation rates
results = zeros(3, 1);
results(1) = good / double(n); % # of correct frames / total frames
results(2) = missed / double(totalPeople); % # of people missed / total number of people across all frames
results(3) = lied / double(totalPeople); % # of people falsely reported / total number of people across all frames

save(resultsFilename, 'results'); % save results