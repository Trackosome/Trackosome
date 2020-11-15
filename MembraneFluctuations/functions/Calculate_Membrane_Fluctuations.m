function [fluctuations, fluctuations_vectors, error_signal, warning_signal] = Calculate_Membrane_Fluctuations(membrane_new, normals, ref_membrane, w_default, plot_all, plot_final_flutuations)

w_size = w_default;

nNormals = length(normals);
fluctuations = zeros(nNormals,1);
fluctuations_vectors = zeros(nNormals,2);

% Guarantee that first point of reference membrane is close to first point of new membrane:
membrane = align_membranes(membrane_new, ref_membrane);

% (x1,y1) - base of normal vectors; (x2,y2) - tip of normal vectors
x1 = ref_membrane(:,1);
y1 = ref_membrane(:,2);
x2 = normals(:,1) + ref_membrane(:,1);
y2 = normals(:,2) + ref_membrane(:,2);

w_beg_i = 1;

% Plots:
if plot_all
    hold on
    plot(membrane(:,1),membrane(:,2), 'b.'), hold on
    plot(ref_membrane(:,1), ref_membrane(:,2), 'k.')
    quiver(ref_membrane(:,1), ref_membrane(:,2), normals(:,1), normals(:,2), 'r')
    axis equal
end

error_signal = 0;
warning_signal = 0;

for i = 1:nNormals
    
    repeat = true;
    count = 1;   
    
    while repeat
        memb_points_ahead = membrane(w_beg_i+1:min(w_beg_i + w_size, length(membrane)), :);
        memb_points =  membrane(w_beg_i:w_beg_i + min(w_size, length(memb_points_ahead)) - 1, :);
        
        % (x3,y3) - base of memb vectors; (x4,y4) - tip of memb vectors; 
        x3 = memb_points(:,1);
        y3 = memb_points(:,2);
        x4 = memb_points_ahead(:,1);
        y4 = memb_points_ahead(:,2);
        
        % intersections between normal vector and pairs of membrane points:
        intersecs = [((x1(i).*y2(i) - y1(i).*x2(i)).*(x3-x4)-(x1(i)-x2(i)).*(x3.*y4-y3.*x4))./ ((x1(i)-x2(i)).*(y3-y4)-(y1(i)-y2(i)).*(x3-x4)), ...
            ((x1(i).*y2(i) - y1(i).*x2(i)).*(y3-y4)-(y1(i)-y2(i)).*(x3.*y4-y3.*x4))./ ((x1(i)-x2(i)).*(y3-y4)-(y1(i)-y2(i)).*(x3-x4))];
        
        % Distance between pairs of membrane points:
        dist_memb_points = sqrt((x3 - x4).^2 + (y3 - y4).^2);
        
        % Distance between pairs of membrane points and intersections:
        dist_memb_interscs = sqrt((x3 - intersecs(:,1)).^2 + (y3 - intersecs(:,2)).^2) + sqrt((x4 - intersecs(:,1)).^2 + (y4 - intersecs(:,2)).^2);
        
        % Intersection point:
        [error_distance, point_i] = min(abs(dist_memb_points - dist_memb_interscs));
        
        % Check if needs to repeat:
        if error_distance*100 > 1
            % Increase Window:
            w_new = round(w_size*1.5);
            w_diff = w_new - w_size;
            w_beg_i =  w_beg_i - round(w_diff/2);
            
            if w_beg_i < 1
                % needs to see before the first point of membrane
                membrane = [membrane(end - round(w_diff/2):end, :); membrane]; 
                w_beg_i = 1;
                
            elseif w_beg_i + w_new > length(membrane)
                % needs to see beyond the last point of membrane
                 membrane = [membrane; membrane(1:w_new, :)]; 
            else
                % search window was increased - reference membrane or
                % current membrane may be to irregular
                warning_signal = 1;
            end
            
            w_size = w_new;
        
        else % Found the intersection point:
            fluctuations(i) = sqrt((intersecs(point_i, 1) - x1(i)).^2 + (intersecs(point_i, 2) - y1(i)).^2);
            fluctuations_vectors(i,:) = [intersecs(point_i, 1) - x1(i), intersecs(point_i, 2) - y1(i)];

            repeat = false;
            w_size = w_default;
        end
        
        count = count + 1;
        if count > 10         
           repeat = false;
           error_signal = 1;
           break
        end
    end
    
    if error_signal
       break 
    end
    
%     fluctuations_vectors(i,:) = [intersecs(point_i, 1) - x1(i), intersecs(point_i, 2) - y1(i)];
    w_beg_i = max(w_beg_i + point_i - 1,1);
    
    % Plots:
    if plot_all
        plot(x1(i), y1(i), 'k.', 'markersize', 15), hold on
        plot(x3, y3, 'c.', 'markersize', 15)
        plot(x4, y4, 'c.', 'markersize', 15)
%         plot(intersecs(:,1), intersecs(:,2), 'y.')
        plot(intersecs(point_i, 1), intersecs(point_i, 2), 'color', [1 0.3 0],'marker', '.', 'markersize', 15)
        plot(membrane(w_beg_i, 1), membrane(w_beg_i, 2), 'b.', 'markersize', 25)
        quiver(x1(i), y1(i), (intersecs(point_i, 1) - x1(i)), (intersecs(point_i, 2) - y1(i)), 'k', 'autoscale', 'off', 'linewidth', 2);
        drawnow
    end    
end

fluctuations = fluctuations';
neg_flut_i = find(calc_norms(fluctuations_vectors + normals) < calc_norms(abs(fluctuations_vectors) + abs(normals)));
fluctuations(neg_flut_i) = - fluctuations(neg_flut_i);

% Plots:
if plot_final_flutuations
    
    pos_flut_i = 1:nNormals;
    pos_flut_i(neg_flut_i) = [];
    
    plot(x1, y1, 'k', 'linewidth', 2)
    plot(membrane(:,1), membrane(:,2), 'm', 'linewidth', 2)
    quiver(x1(neg_flut_i), y1(neg_flut_i), fluctuations_vectors(neg_flut_i,1), fluctuations_vectors(neg_flut_i,2), 'b', 'autoscale', 'off', 'linewidth', 2);
    quiver(x1(pos_flut_i), y1(pos_flut_i), fluctuations_vectors(pos_flut_i,1), fluctuations_vectors(pos_flut_i,2), 'r', 'autoscale', 'off', 'linewidth', 2);
    
    drawnow
end

end

