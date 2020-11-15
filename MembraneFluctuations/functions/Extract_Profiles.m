function [XY_borders] = Extract_Profiles( membrane_mask, step, to_plot, plot_end )

% Find the shortest segments - profiles - connecting the borders of a "donut-shape" mask
%    
% Arguments:
%   membrane_mask := "donut-shape" mask of the membrane (closed curve)
%   step := step to go throught the borders of the mask. step = 1, finds profiles for every point of the inner border 
%                                                        step = n, finds a profile every n points of the inner border 
%   to_plot := 1 - plot entire algorith in real time
%   plot_end := 1 - plot final result
%
% Output:
%   XY_borders := 3D matrix [[x_out x_in];[y_out y_in]] with the
%       coordinates of the inner and outter borders associated with each
%       profile

%% Define outer and inner border:
B = bwboundaries(membrane_mask);

B1 = B{1};
B2 = B{2};
if max(B1(:,1)) < max(B2(:,1))
    bound_in = B1(:,2);
    bound_in(:,2) =  B1(:,1);
    bound_out = B2(:,2);
    bound_out(:,2) =  B2(:,1);
else
    bound_in = B2(:,2);
    bound_in(:,2) =  B2(:,1);
    bound_out = B1(:,2);
    bound_out(:,2) =  B1(:,1);
end

bound_out = align_membranes(bound_out, bound_in);
bound_in = bound_in(1:step:end, :);
bound_out = bound_out(1:step:end, :);

if to_plot || plot_end
    figure
    imagesc(membrane_mask), hold on,
    axis equal
    plot(bound_in(:,1), bound_in(:,2))
    plot(bound_out(:,1), bound_out(:,2))
    plot(bound_in(1,1), bound_in(1,2), 'g.', 'markersize', 15)
    plot(bound_out(1,1), bound_out(1,2), 'g.', 'markersize', 15)
end

%% Loop to find Profiles:

factor = 10; % the window sees 1/factor of the boundary points
window = round(length(bound_out)/factor);
bound_out_pad = [bound_out; bound_out(1, :)] ;
closest_bound_out_pre = 1;
profile_borders_i = 1;

XY_borders = zeros(length(bound_in), 2,2);

for i = 1:length(bound_in)
    
    w_beg = closest_bound_out_pre;
    w_end = min(closest_bound_out_pre+window, length(bound_out_pad));
    
    %% Find closest point from outter boundary:
    dist_x = (bound_out_pad(w_beg:w_end,1) - bound_in(i,1));
    dist_y = (bound_out_pad( w_beg:w_end,2) - bound_in(i,2));
    dists = sqrt( dist_x.^2 + dist_y.^2);
    [~, shortest_dist_i] = min(dists);
    closest_bound_out = shortest_dist_i + w_beg - 1;
    
    % closest point pairs:
    x_out = bound_out_pad(closest_bound_out,1);
    x_in = bound_in(i,1);
    y_out = bound_out_pad(closest_bound_out,2);
    y_in = bound_in(i,2);
    
    if to_plot 
        plot(bound_out_pad(1:w_beg,1), bound_out_pad(1:w_beg,2), 'k.', 'markersize', 12)
        plot(bound_in(i,1),bound_in(i,2), 'k.', 'markersize', 12)
        plot(bound_out_pad(w_beg:w_end,1), bound_out_pad(w_beg:w_end,2), 'c.', 'markersize', 15)
        quiver(bound_in(i,1),bound_in(i,2), x_out - x_in, y_out - y_in, 'b', 'autoscale', 'off')
        drawnow
    end
    
    %% If some points from outter boundary were skipped, extract the respective profiles:
    if closest_bound_out > closest_bound_out_pre
        
        if   closest_bound_out > closest_bound_out_pre + 1
            % closest point pairs:
            x_out = bound_out_pad(closest_bound_out_pre:closest_bound_out,1);
            x_in = ones(length(x_out),1) * bound_in(i,1);
            y_out = bound_out_pad(closest_bound_out_pre:closest_bound_out,2);
            y_in = ones(length(y_out),1)* bound_in(i,2);
            
            if to_plot 
                quiver(x_in, y_in, x_out - x_in, y_out - y_in, 'r', 'autoscale', 'off')
                drawnow
            end
        end
        closest_bound_out_pre = closest_bound_out;
    end
    
    %% Define profile borders:
    XY_borders(profile_borders_i:profile_borders_i+length(x_out)-1,:, 1) = [x_out x_in];
    XY_borders(profile_borders_i:profile_borders_i+length(x_out)-1,:, 2) = [y_out y_in];
    profile_borders_i = profile_borders_i + length(x_out);
end

%% The remaining points from outter boundary are connected to last point from inner boundary
if closest_bound_out < length(bound_out_pad)
    
    x_out = bound_out_pad(closest_bound_out:end,1);
    x_in = ones(length(x_out),1) * bound_in(end,1);
    y_out = bound_out_pad(closest_bound_out:end,2);
    y_in = ones(length(y_out),1)* bound_in(end,2);
    XY_borders(profile_borders_i:profile_borders_i+length(x_out)-1,:, 1) = [x_out x_in];
    XY_borders(profile_borders_i:profile_borders_i+length(x_out)-1,:, 2) = [y_out y_in];
    
    if to_plot || plot_end
        quiver(x_in, y_in, x_out - x_in, y_out - y_in, 'r', 'autoscale', 'off')
        drawnow
    end
end

if  plot_end
    quiver( XY_borders(:,2,1), XY_borders(:,2,2),  XY_borders(:,1,1) - XY_borders(:,2,1), XY_borders(:,1,2) - XY_borders(:,2,2), 'k.', 'autoscale', 'off')
    drawnow
end
