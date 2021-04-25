% evaluate n measurements
good = 0
miss = 0
for i=1:n
    
    if (results(1, i) ~= results(2, i))
        good = good + 1
    else
        miss = miss + abs(diff(results(1, i), results(2, i)))
end

% compute evaluation rates
GMR = good / n
MDR = miss / sum(results(2, :))
FDR = 0