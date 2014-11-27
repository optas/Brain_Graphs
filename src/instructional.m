labelsExhaust = zeros(size(kNeighbors.ids));
K = kNeighbors.ids;
for i = 1: size(K,1)
    for j = 1: size(K,2)
    labelsExhaust(i,j) = pointLabels(kNeighbors.ids(i,j));
    end
end

labelsFun  = arrayfun(@(x) pointLabels(x) ,kNeighbors.ids);
labelBest  = pointLabels(kNeighbors.ids);