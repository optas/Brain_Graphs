classdef BG
    % Various routines developed for the 'Brain_Graphs' project.
    
    methods (Static)
        
        function [res] = neighbors_on_same_fiber(kNeighbors, fiberLabels, k)
            % Computes how many of the k-closest neighbors of a collection
            % of fiber points are on the same fiber.
            % 
            % kNeighbors    -   (struct) representing a point cloud with the
            %                   k-corresponding closest neighbors of each
            %                   point. 
            %                   - .
            
            
            if ~exist('k', 'var')
                k = size(kNeighbors, 2);
            else
                if k > size(kNeighbors, 2)
                    error('Incorrect input k. Restricting on more neighbors than those computed.')
                end 
            end
            
            labelOfNeighbors = fiberLabels(kNeighbors);                       
            numPoints        = size(kNeighbors, 1);
            res              = zeros(k, 1);
            i                = 1;            
            
            for m = 1:k
                sameLabel = sum(sum(labelOfNeighbors(:,1:m) - repmat(fiberLabels, 1, m) == 0));                
                diffLabel = numPoints*m - sameLabel;                
                assert(diffLabel == sum(sum(labelOfNeighbors(:,1:m) - repmat(fiberLabels, 1, m) ~= 0)))
                res(i)    =  sameLabel / (sameLabel + diffLabel);
                i         = i + 1;
            end                        
        end
        
    end
    
end

