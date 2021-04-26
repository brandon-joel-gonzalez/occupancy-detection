% use to manually evaluate results of camera
dataFilename = 'test_data/scenario1_trial1.mat';
photoFilename = 'test_photos/scenario1_trial1/photo#%d.png';
resultsFilename = 'test_results/scenario1_trial1.mat';

% evaluate n measurements
n = 20;
good = 0; % +1 if correct # of individuals reported on a frame, +0 otherwise
missed = 0; % +1 if individual missed on a frame, +0 otherwise
lied = 0; % +1 if individual falsely reported on a frame, +0 otherwise
totalPeople = 0; % total number of individuals in the scene across all frames

% assess each measurement
data = importdata(dataFilename);
for i=1:n
    % show ith image, and print xy-coord if applicable
    imageFile = sprintf(photoFilename, i);
    image = imread(imageFile);
    imshow(image);
    
    % print coordinates of people in frame (assume no more than 3 targets max)
    reportedPeople = data(1,i);
    for j=0:2
        fprintf("x-coord: %d, y-coord: %d\n", data(2*j+2, i), data(2*j+3, i));
    end
    
    numPeople = input('How many people do you see?');
    if (numPeople == reportedPeople)
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