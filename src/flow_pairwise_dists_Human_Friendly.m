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