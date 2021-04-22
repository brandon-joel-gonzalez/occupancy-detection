% evaluate n measurements
results = open('test_data/test_camera.mat', 'results')
n = 0
good = 0
miss = 0
assessments = zeros(1, n)

% assess each frame
for i=1:n
    zeros(1, i) = 0
    
    if (results(1, i) == evaluations(1, i))
        good = good + 1
    else
        miss = miss + abs(diff(results(1, i), results(2, i)))
    end
    
    if (
end

% compute evaluation rates
GMR = good / n
MDR = miss / sum(results(2, :))
FDR = 0 / sum(