%% Extracting Laplacian Spectral Features
clear
clc

%%
data_folder = 'Brain_Graphs/Data/';
brains = load(strcat(data_folder, 'Deformation.mat'));   % Cell array, with fibers correspondign to a brain and its deformations
brains = brains.fibers;
 
%%
fibers_i_brain = cell(length(brains), 1);
for i=1:length(brains)
    fibers_i_brain{i} = Brain_Graphs_IO.fibers_to_matrix(brains{i});
end

%% Euclidean-knn
k           = 10 + 1;
knn_i_brain = cell(length(brains), 1);
for i=1:length(brains)
    [ids, dist]  = knnsearch(fibers_i_brain{i}, fibers_i_brain{i}, 'K', k);
    knn_i_brain{i}.IDs  = ids(:, 2:end);
    knn_i_brain{i}.Dist = dist(:, 2:end);
end

%% Node Similarities
sigma = k;
for i=1:length(brains)
    total_distance_mass = sum(knn_i_brain{i}.Dist, 2);
    normalized_dists    = divide_columns(knn_i_brain{i}.Dist', total_distance_mass)';    
    similarities        = exp(-sigma*normalized_dists);    
    knn_i_brain{i}.Sim  = similarities;
    assert(all(all(normalized_dists > 0)))
end

%% Adjacency-Laplacian Matrix and Spectra
tic
eigs_total      = 10 + 1;
spectra_i_brain = cell(length(brains), 1);
for i=1:length(brains)
    Ag = k_neighbors_to_adjacency_matrix(knn_i_brain{i}, 'Sim');
    As = symmetrize_adjacency(Ag, 'ave');
    L  = adjacency_to_laplacian(As, 'comb');
    [evecs, evals] = eigs(L, eigs_total, 'SM');
    [evals, evecs] = Spectra.sort_spectrum(diag(evals), evecs);
    assert(abs(evals(1)) < 1e-6)            % Throw first eigenvector since is uninformative for Laplacian.    
    
    spectra_i_brain{i}.Comb_Laplacian = L;
    spectra_i_brain{i}.Evals          = evals(2:end);
    spectra_i_brain{i}.Evecs          = evecs(:,2:end);    
end
toc
save(strcat(data_folder, 'Deformations_spectra.mat'), 'spectra_i_brain')

