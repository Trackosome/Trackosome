%% Normalize Centrossome Coordinates
function [CS_x_um_centered, CS_y_um_centered, CS_z_um_centered, XX, YY, ZZ] = normalize_CS_coordinates(CS_x_um, CS_y_um, CS_z_um, filtered_NM_centroid, NM_centroid_trim, median_NM, px2um, z_step, plot_stuff)

CS_x_um_centered = CS_x_um - filtered_NM_centroid(1,:)';
CS_y_um_centered = CS_y_um - filtered_NM_centroid(2,:)';
CS_z_um_centered = CS_z_um - filtered_NM_centroid(3,:)';

if plot_stuff
    % Plot Centered Trajectories
    figure
    sz = 15;
    c = linspace(1,10,length(NM_centroid_trim(1,:)));
    % Centrosomes
    plot3( CS_x_um_centered(:,1), CS_y_um_centered(:,1), CS_z_um_centered(:,1), 'MarkerSize', 1); hold on
    plot3( CS_x_um_centered(:,2), CS_y_um_centered(:,2), CS_z_um_centered(:,2), 'r','MarkerSize', 1);
    scatter3(CS_x_um_centered(:,1), CS_y_um_centered(:,1), CS_z_um_centered(:,1), sz,c,'filled');
    scatter3(CS_x_um_centered(:,2), CS_y_um_centered(:,2), CS_z_um_centered(:,2), sz,c,'filled');
    plot3(0,0,0,'k*')
    drawnow
end


% Nucleus Membrane
[XX, YY, ZZ] = meshgrid( px2um*(1:size(median_NM,2))-NM_centroid_trim(1), px2um*(1:size(median_NM,1))-NM_centroid_trim(2), z_step*(1:size(median_NM,3))-NM_centroid_trim(3));
if plot_stuff
    p = patch( isosurface( XX, YY, ZZ, median_NM, 0.5) );
    isonormals( XX, YY, ZZ, median_NM, p);
    set(p,'FaceColor', 'g', 'FaceAlpha', 0.4, 'EdgeColor', 'none');
    grid on;
    light;
    lighting phong;
    camlight('left')
    hold on,
    axis vis3d equal;
    xlabel('X')
    ylabel('Y')
    zlabel('Z')
    title('Centered Cromosome Trajectories')
    drawnow
end

end