function kNeighbors = top_k_neighbors_from_dist(pdistM, k)
    [sortDist, sortIDs] = sort(pdistM, 2);
    kNeighbors.Dists = sortDist(:,2:k+1);
    kNeighbors.IDs   = sortIDs(:,2:k+1);
end


