clear; clc;

%% Load bvecs-bvals.
bvecs = dlmread('Brain_Graphs/Data/run01_aligned_trilin.bvecs')';
bvals = dlmread('Brain_Graphs/Data/run01_aligned_trilin.bvals');
bvals = (bvals/1000)';
bvecs = bvecs(11:end, :);  % First 10 are zero.
bvals = bvals(11:end);

%% Load and preprocess fiber points and their flows.
flows       = load('Brain_Graphs/Data/signal.mat');
flows       = cellfun(@(x) x(11:end,:)', flows.S, 'UniformOutput', false)'; % First 10 values are garbage.
flowsM      = cell2mat(flows);

fibers      = load('Brain_Graphs/Data/fibers.mat');
fibers      = fibers.fibers;
fibers      = cellfun(@transpose, fibers, 'UniformOutput', false);          % Rows = fibers, columns = x,y,z coordinates.
fibersM     = cell2mat(fibers);
fiberLabels = cell_as_matrix_labels(fibers);

%% Basic Parameters.
allFibers = size(fibers, 1);
allPoints = size(fibersM, 1);
minAngle  = 30;                 % Angle of cone.
powerLaw  = 4;                  % Power of formula of flow distance (bigger => more emphasis on the flows).
topK      = 10;                 % Closest neighbors of each point that we keep.

%% Top k-Euclidean neighbors.
[ids, dist]     = knnsearch(fibersM, fibersM, 'K', topK+1);
kNeighbors.ids  = ids(:, 2:end);    % Closest neighbor is the point itself.
kNeighbors.dist = dist(:, 2:end);


%% What percent of the top k-neighbords live on the same fiber.
res = BG.neighbors_on_same_fiber(kNeighbors.ids, fiberLabels)

%% Calibrate Euclidean distances of knn by flow-distance.
flows_calibrated = exp(1).^-flowsM;    % Accounting that a flow being small semantically 'means' is bigger.
tic
kNeighbors.flowDist = zeros(size(kNeighbors.dist));
for i=1:allPoints;
    x = fibersM(i,:);
    j = 1;
    for nID = kNeighbors.ids(i,:) % Traverse all knn of x.
        kNeighbors.flowDist(i, j) = embedded_flow_distance(x, fibersM(nID, :), flows_calibrated(i, :), bvecs, minAngle, powerLaw);
        j = j + 1; 
    end
end
toc

%% Re-sort knn according to new distances
[sortedDists, sortedIndex] = sort(kNeighbors.flowDist, 2);
kNeighbors.flowIDs = zeros(size(kNeighbors.flowDist));

for i=1:allPoints
    kNeighbors.flowIDs(i, :)     = kNeighbors.ids(i, sortedIndex(i,:));
    assert(all(sortedDists(i,:) == kNeighbors.flowDist(i, sortedIndex(i, :))));
end

kNeighbors.flowDist = sortedDists;

res = BG.neighbors_on_same_fiber(kNeighbors.flowIDs, fiberLabels)

%%
fiber = 10;
pointsOnFiber = size(fibers{fiber}, 1);
figure; hold on;
for point = 1:pointsOnFiber-1    
    scatter3(fibers{fiber}(point, 1), fibers{fiber}(point, 2), fibers{fiber}(point, 3))
    input('')
end

%% Find how much flow goes between succecive points of a fiber.
fiber = 10;
pointsOnFiber = size(fibers{fiber}, 1);
for point = 1:pointsOnFiber-1
    x = fibers{fiber}(point, :);
    y = fibers{fiber}(point+1, :);
    [val, index] = min(angles(y-x, bvecs));
    xFlows = flows{fiber}(point,:);
    sum(xFlows(index) >= xFlows) 
    sum(xFlows(index) >= xFlows) / length(xFlows)   
%     flow_fraction(x, y, flows{fiber}(point,:), bvecs, 10)
    input('')
end



%% BF (Testing)
% points = fibersM(1:100,:);
% distSmalls = flow_pairwise_dists_Human_Friendly(points,flowsM,bvecs,min_angle, power_law);
% [kNeighbors.Dist, kNeighbors.IDs] = top_k_neighbors_from_dist_parfor(distSmalls, 10);

%% 
% load 'Brain_Graphs/Data/allDists_powerlaw_1';
% load 'Brain_Graphs/Data/allDists_powerlaw_2';
load 'Brain_Graphs/Data/tok_100_Neighbors_powerlaw_2';
% save ('Brain_Graphs/Data/tok_100_Neighbors_powerlaw_2.mat', kNeighbors);
% clear 'allDists'


%% Measure deviation from symmetry according to single closest neighbor
ranked = 1;
ranks  = ones(allPoints, 1) * +inf;
for i=1:allPoints
    i_kn1 = kNeighbors.IDs(i,1);
    kn    = kNeighbors.IDs(i_kn1,:);
    kn_rank_i = find(kn==i);
    if kn_rank_i
        ranks(ranked) = kn_rank_i;
        ranked = ranked + 1;
    end    
end
ranks = ranks(ranks ~= +Inf);     %exclude ranks that were completely missed
completely_missed = allPoints - size(ranks,1)
mean(ranks)
median(ranks)
hist(ranks, topK);
title('Flow Reciprocity: How my top1 neighbor ranks me?');


%% Measure deviation from symmetry according to all knns
m = 1;
different_ks = [10,20,30,40,50,60,70,80,90,100];
medArr = zeros(1, size(different_ks,2));
aveArr = zeros(1, size(different_ks,2));
infArr = zeros(1, size(different_ks,2));

for k = different_ks     
    ranks  = ones(allPoints, k) * +inf;
    for i=1:allPoints
        for j=1:k
            kn_ij = kNeighbors.IDs(i,j);
            rank = find(kNeighbors.IDs(kn_ij, :) == i);
            if rank        
                ranks(i,j) = rank;
            end
        end

    end
    
    distortionM = abs(ranks - repmat((1:k), allPoints, 1));  % Measure distortion as the absolute value of the rank difference between two points        
    temp        = distortionM(distortionM ~= +inf);    
    
    medArr(m) = median(temp);
    aveArr(m) = mean(temp);
    infArr(m) = sum(sum(ranks == +inf)) / (allPoints * k);   % Fraction of points that are not neighbors 'at all' given the topk        
    m = m + 1;
end

plot(different_ks, medArr)
title('Deviation from being a symmetric distance')
xlabel('Values of k, for knn')
ylabel('Median Distortion')
figure; 
plot(different_ks, aveArr)
title('Deviation from being a symmetric distance')
xlabel('Values of k, for knn')
ylabel('Average Distortion')
figure
plot(different_ks, infArr)
title('Deviation from being a symmetric distance')
xlabel('Values of k, for knn')
ylabel('Fraction of Completely missed')