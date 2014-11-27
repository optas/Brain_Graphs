function labels = cell_as_matrix_labels(C)
% Labels the rows of a matrix that resides in C{i} as i.
% Input:
%        C: A cell array, that contains in each cell a matrix. The columns
%        of all the matrices must be the same. Thus, C must be a valid
%        input for cell2mat.
%
% Example:  C{1} = 5x10 matrix, C{2} = 2x10 matrix
%           cell_as_matrix_labels(C)
%           outputs: 1,1,1,1,1,2,2
%
% Preconditions 
% 1.            Each cell of c is a matrix with the same number of columns.
 
    allRows     = cell_as_matrix_total_rows(C);
    labels      = zeros(allRows, 1);    
    leftBound   = 1;  
    rightBound  = leftBound - 1;
    
    for i = 1:numel(C)
        rows_i   = size(C{i},1);
        labels(leftBound : rightBound + rows_i) = i;
        leftBound  = leftBound + rows_i;
        rightBound = leftBound - 1;
    end
    assert(all(1:numel(C) == unique(labels)'))                            
end

function totalRows = cell_as_matrix_total_rows(C)
    sizes = cell2mat(cellfun(@size, C, 'uni', false));
    totalRows = sum(sizes(:,1));
end
