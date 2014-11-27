function [dists, ids] = top_k_neighbors_from_dist_parfor(pdistM, k)

    matlabpool local 8

    N = size(pdistM, 1);
    dists = zeros(N,k);
    ids   = zeros(N,k);
    
    parfor i = 1:N
        [sortDist_i, sortIDs_i] = sort(pdistM(i,:));
        dists(i,:) = sortDist_i(2:k+1);
        ids(i,:)   = sortIDs_i(2:k+1);           
    end

    matlabpool close

    % Following code only for asserions
    % The distances returned must be in descending order
    [~, B] = sort(dists, 2);
    C = repmat(1:k, allPoints, 1);
    assert(all(all(C== B)))       
    
end
