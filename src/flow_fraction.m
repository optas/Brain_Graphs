function fraction = flow_fraction(x, y, x_flows, directions, min_angle)
    flows_in_cone = angles(y-x, directions) <= min_angle;
    fraction= sum(x_flows(flows_in_cone)) ./ sum(x_flows);
end