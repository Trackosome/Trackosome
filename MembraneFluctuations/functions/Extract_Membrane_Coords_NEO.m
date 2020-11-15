function [ref_memb] = Extract_Membrane_Coords_NEO( Iproj, XY_borders, filterWindow, plot_all, plot_end )

membrane_coords_ref_XY = zeros(length(XY_borders),2);

if plot_all || plot_end
    figure
    imagesc(Iproj), hold on
    colormap('jet')
    axis equal
    
    quiver( XY_borders(:,2,1), XY_borders(:,2,2),  XY_borders(:,1,1) - XY_borders(:,2,1), XY_borders(:,1,2) - XY_borders(:,2,2), 'k.', 'autoscale', 'off')
    drawnow
end


for i = 1:length(XY_borders)
    
    [profile_coords, profile] = my_improfile(Iproj, XY_borders(i,:,1), XY_borders(i,:,2));
    [~, i_max] = max(profile);
        
    membrane_coords_ref_XY(i,:) = [profile_coords(i_max, 1), profile_coords(i_max, 2)];
    
    if plot_all
        plot(profile_coords(i_max, 1), profile_coords(i_max, 2), 'b.', 'markersize', 10)   
        drawnow
    end    
end



%% Filter Membrane

half_W = floor(filterWindow/2);

[~, m, ~] = unique(membrane_coords_ref_XY, 'rows','stable');
membrane_coords_ref_XY = membrane_coords_ref_XY(m,:);


padded_memb = [membrane_coords_ref_XY(end-half_W:end, :); membrane_coords_ref_XY; membrane_coords_ref_XY(1:half_W+1, :)];
ref_memb_padded = movmean(padded_memb, filterWindow);
ref_memb = ref_memb_padded(half_W + 2 :end - half_W - 1, :);
ref_memb(end+1,:) = ref_memb(1,:);

% % % % if plot_all || plot_end
% % % %     plot(ref_memb(:,1), ref_memb(:,2), 'color', [1 1 1], 'marker', '.', 'markersize', 10)
% % % % end

