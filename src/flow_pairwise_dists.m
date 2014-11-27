function allDists = flow_pairwise_dists(points, flows, directions, min_angle, power_law, top_k, threads_num)
% 
% Not symmetric distance
%
    tic
    matlabpool local 7
    N = size(points, 1);
    allDists = zeros(N,N);
    parfor i = 1:N
        T = zeros(N,1);        
        for j = 1:N
            if i == j
                T(j) = 0;
            else
                T(j) = embedded_flow_distance(points(i,:), points(j, :), flows(i, :), directions, min_angle, power_law);
            end            
        end
%         A{i, 1} = T;
          allDists(i,:) = T;
    end  
%     allDists = cell2mat(A);
    matlabpool close
    toc
end



%
% The following funtions are currently STUBS
%

function allDists = flow_pairwise_dists_Human_Friendly(points, flows, directions, min_angle, power_law)
%Non symmetric
    N = size(points, 1);
    allDists = zeros(N,N);
    for i = 1:N
        for j = 1:N
            if i == j
                allDists(i,j) = 0;
            else
                allDists(i,j) = embedded_flow_distance(points(i,:), points(j, :), flows(i, :), directions, min_angle, power_law);
            end
        end
    end
end


function allDists = flow_symmetric_pairwise_dists(points, flows, directions, min_angle, power_law)    
    matlabpool local 7 
    N = size(points, 1);
    A = cell(N-1,1);
    parfor i = 1:N-1
        T = zeros(N-i,1);
        m = 1;
        for j = i+1:N
            T(m) = embedded_flow_distance(points(i,:), points(j, :), flows(i, :), directions, min_angle, power_law);
            m = m + 1;
        end
        [dists, sort_ids] = sort(T);   
    %     A{i, 1} = dists(1:k);
    %     A{i, 2} = sort_ids(1:k);
    %     A{i, 2} = A{i, 2} + i;
    end    
    allDists = squareform(cell2mat(A));
    matlabpool close
end