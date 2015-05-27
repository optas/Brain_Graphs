classdef Brain_Graphs_IO
    % A class providing a variety of functions for managing input-output
    % and basic transforms of the data related to the "Brain_Graphs"
    % project.
    
    properties
    end
    
    methods (Static)
        
        function [M] = fibers_to_matrix(fibers)
            % Given a cell array containing in each cell a matrix storing
            % the points along a fiber, produces a unified matrix storing
            % all the fiber points together.
            %
            % Input:  fibers     - (m x 1) cell array.
            %         fibers{i}  - (3 x n_i) matrix storing the 3D points along
            %                      the i-th fiber.           
            %                   
            % Output: M          - (number_of_all_points_in_all_fibers x 3)
            %                      storing the same information as the 
            %                      input fibers but in a different format.
            
            fibers = cellfun(@transpose, fibers, 'UniformOutput', false);
            M      = cell2mat(fibers);
        end
        
        
        %             L      = cell_as_matrix_labels(fibers);
    end
    
end

