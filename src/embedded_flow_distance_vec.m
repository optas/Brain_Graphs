function D = embedded_flow_distance_vec(x, Z, directions, min_angle, power_law)
    points  = size(Z, 1);
    D       = zeros(points, 1);
    x_flows = x(4:end);
    for i=1:points
        y = Z(i,1:3);        
        D(i) = embedded_flow_distance(x(1:3), y, x_flows, directions, min_angle, power_law);
    end

end