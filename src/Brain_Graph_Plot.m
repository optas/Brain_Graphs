classdef Brain_Graph_Plot

    properties
    end
    
    methods (Static)
        function scatter_3D_points(P)
            assert(size(P,2) == 3);
            figure;            
            scatter3(P(:,1), P(:,2), P(:,3))    
        end
        
        function compute_plot_convex_hull(pointCloud)
            %% Exploring the Convex Hull
            C   = convhull(pointCloud);
            tri = delaunay(C(:,1), C(:,2), C(:,3));
            figure; trimesh(tri, C(:,1), C(:,2), C(:,3));
            % Observation 1: Less than 1% of all the fiber points are part of the convex
            % hull of the fascicle.
        end
    
        function cone_around_vector(queryVector, vectorCollection, minAngle)
            % Plot the vectors of the vectorCollection that fall inside a 
            % cone centered at the queryVector. Each such vector must have
            % a small than minAngle angle with the queryVector.
                 
            inCone = angles(queryVector, vectorCollection) <= minAngle;
            figure; hold on;            
            for i = 1:size(vectorCollection, 1)    
                if inCone(i) == 1
                    quiver3(0,0,0, vectorCollection(i,1), vectorCollection(i,2), vectorCollection(i,3))
                end
                scatter3(queryVector(1), queryVector(2), queryVector(3),  '*')
            end
        end
        
    end
    
end

