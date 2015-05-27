function [A] = k_neighbors_to_adjacency_matrix(kNeighbors, weight_type)
% TODO: Add explanation of weight_type
% Converts the k-nearest neighbors data into a corresponding (weighted)
% graph described by its adjacency matrix.
% 
% Input:    kNeigbors      - structure with two fields containing the knn
%                            data.
%           kNeigbors.IDs  - (n x k) matrix, i-th row are the IDs of the
%                            k-nn neighbors of the i-th datum, sorted in
%                            ascending distance from i.
%           kNeigbors.Dist - (n x k) matrix with same format as kNeigbors.IDs
%                            capturing the the distances between the data.
%
% Output:   A              - (n x n) sparse matrix corresponding to the
%                            adjacency matix of a graph that is built over the n-datums (used as nodes)
%                            connected with their k-nn with edge weights
%                            being their corresponding distances.


[n, k]     = size(kNeighbors.IDs);
totalEdges = numel(kNeighbors.(weight_type));
temp       = repmat(1:n, k, 1); 

i = reshape(temp, 1, totalEdges);             % 1,...,1,2,..,2,...,n,...,n (each block has k elements)
j = reshape(kNeighbors.IDs', 1, totalEdges);  % j(m)  =  kNeighbors.IDs(ceil(m/k), mod(m,k))
v = reshape(kNeighbors.Dist', 1, totalEdges);

A = sparse(i, j, v, n, n);
   
end