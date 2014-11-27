clear; clc;

%% Load bvecs-bvals
bvecs = dlmread('Data/run01_aligned_trilin.bvecs')';
bvals = dlmread('Data/run01_aligned_trilin.bvals');
bvals = (bvals/1000)';
bvecs = bvecs(11:end, :); % first 10 are zero
bvals = bvals(11:end, :);

%% Load and preprocess fiber points and their flows 
flows        = load('Data/signal.mat');
flows        = cellfun(@(x) x(11:end,:)', flows.S, 'UniformOutput', false)';% First 10 values are garbage

fibers       = load('Data/fibers.mat');
fibers       = fibers.fibers;
fibers       = cellfun(@transpose, fibers, 'UniformOutput', false);        % rows = Fibers, columns = x,y,z coordinates

flowsM       = cell2mat(flows);
fibersM      = cell2mat(fibers);

fiberLabels  = cell_as_matrix_labels(fibers);

%% Basic Parameters
allFibers = size(fibers, 1);
allPoints = size(fibersM, 1);
min_angle = 45;
power_law = 2;
topK      = 100;

%% BF (Testing)
% points = fibersM(1:100,:);
% distSmalls = flow_pairwise_dists_Human_Friendly(points,flowsM,bvecs,min_angle, power_law);
% [kNeighbors.Dist, kNeighbors.IDs] = top_k_neighbors_from_dist_parfor(distSmalls, 10);

%% 
% load 'Data/allDists_powerlaw_1';
% load 'Data/allDists_powerlaw_2';
load 'Data/tok_100_Neighbors_powerlaw_2';
% save ('Data/tok_100_Neighbors_powerlaw_2.mat', kNeighbors);
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


%% Top k-Euclidean neighbors
[ids, dist]     = knnsearch(fibersM, fibersM, 'K', topK+1);
l2_kNeighbors.IDs  = ids(:, 2:end);
l2_kNeighbors.Dist = dist(:, 2:end);


%% Check percentages of flow-knn on same fiber
labelOfNeighbors = fiberLabels(kNeighbors.IDs);
res = zeros(100, 1);
i = 1;
for m =1:100
    sameLabel = sum(sum(labelOfNeighbors(:,1:m) - repmat(fiberLabels, 1, m) == 0));
    diffLabel = sum(sum(labelOfNeighbors(:,1:m) - repmat(fiberLabels, 1, m) ~= 0));  
    res(i)  =  sameLabel / (sameLabel + diffLabel);
    i = i + 1;
end
figure;
plot(1:100, res, '*')


%% Calibrate Euclidean distance of knn by Flow
tic
for i=1:allPoints;
    x = fibersM(i,:);
    j = 1;
    for nID = kNeighbors.ids(i,:) % Traverse all knn of x
        kNeighbors.flow_dist(i, j) = embedded_flow_distance(x, fibersM(nID, :), flowsM(i, :), bvecs, min_angle, power_law);
        j = j + 1; 
    end
end
toc

%% Re-sort knn according to new distances (re-write, add assertions)
[temp1, temp2] = sort(kNeighbors.flow_dist, 2);
temp3  = zeros(size(kNeighbors.flow_ids));

for i=1:allPoints
    temp3(i,:) = kNeighbors.flow_ids(i, temp2(i,:));
end

kNeighbors.flow_dist = temp1;
kNeighbors.flow_ids  = temp3;

%% Other Useful
matdata = cellfun(@str2num,data);


%% Find how much flow goes between succecive points of the fiber (unfinished)
fiber = 10;
points_on_fiber = size(fibers3D{fiber},1);
for point= 1:points_on_fiber-1
    x = fibers3D{fiber}(point, :);
    y = fibers3D{fiber}(point+1, :);
    flow_fraction(x, y, flows{fiber}(point,:), bvecs, 45)
end

%% Plot the fibers
figure; hold on;
for i = 1:size(fibers3D, 1)
    
% for i = [1,10,20]
    scatter3(fibers3D{i}(:,1), fibers3D{i}(:,2), fibers3D{i}(:,3))    
end


%% Plot the bvecs
figure; hold on;
for i = 1:size(bvecs, 1)    
    scatter3(bvecs(i,1), bvecs(i,2), bvecs(i,3))
end


%% Plot bvecs-cone
min_angle = 45;
flows_in_cone = angles(bvecs(1,:) , bvecs) <= min_angle;    % Cone is around bvec1
figure; hold on;
for i = 1:size(bvecs, 1)    
    if flows_in_cone(i) == 1
        quiver3(0,0,0, bvecs(i,1), bvecs(i,2), bvecs(i,3))
    end
end



