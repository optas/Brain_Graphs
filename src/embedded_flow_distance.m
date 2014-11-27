function dist = embedded_flow_distance(x, y, x_flows, directions, min_angle, power_law)
% TODO eval, and add formula
%
% Input:
%        x, y:          2 n-dimensional vectors
%        
%        x_flows:       m-dimensional vector which captures the m flow measurements
%                       that were taken at input point -x-
%
%        directions:    mXn matrix, directions(i,:) is the i-th direction
%                       (vector) along which the the x_flows(i) measurement
%                       was captured
%                       
%        min_angle:     flows measured along directions that form less than
%                       -min_angle- angle with the vector (x-y) will contibute 
%                       in the output embedded distance
%                              
%       power_law:      a in formula
%
%

    if all(x == y) || all(y-x == zeros(1,size(x,2)) )
        dist = 0;        
    else    
        flow_frac = flow_fraction(x, y, x_flows, directions, min_angle);
        dist = norm(x - y) * (1 / (flow_frac^power_law));
    end
end


function fraction = flow_fraction(x, y, x_flows, directions, min_angle)
    if y==x
        ME = MException('oops');
        throw(ME)
    end
        
    flows_in_cone = angles(y-x, directions) <= min_angle;
    fraction = sum(x_flows(flows_in_cone)) ./ sum(x_flows);
end


