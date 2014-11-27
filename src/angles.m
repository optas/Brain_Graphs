function dprods = angles(v, X)    
% Computes the angles bewtween every row vector of a matrix 
% and a given query vector. The angles are in degrees.
%  
% Input:    v       - (1 x n) Real non-zero query vector 
%           X       - (m x n) matrix
%           norm    - (optional, default: 1) if 1 columns of X are normalized
%                                           
% Output:   res     - (1 x n)vector, res[i] is the angle between -v- and -X(i,:)-
%   
%
% (c) Panos Achlioptas 2014    http://www.stanford.edu/~optas

    [m, n] = size(X);
    assert(size(v,2) == n);
    assert(~all(v == zeros(1,n)), '%s (%d)', 'Tried to find angle of zero vector', v);
    
    unit_length = 0;    
    if nargin < 3,
        unit_length = 1;
    end

    dprods = X * v';     % Inner products between rows of X and v
    
                         % Convert dot products to cosines
    if unit_length
        dprods = dprods ./ norm(v, 2);
    else
        dprods = dprods ./ norm(v, 2) * norms(X, 2, 2);
    end
    
                         % Convert cosines to angles in degrees
    dprods  = acos(dprods ) * (180/pi);
    %     dprods = atan2(norm(cross(V,X,2)), dot(V, X, 2))        
    assert(all(dprods <= 180) && all(dprods >= 0) )
    
end