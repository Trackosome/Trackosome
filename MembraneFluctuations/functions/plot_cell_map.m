function  plot_cell_map(vector_base_px, normals, dist_between_points_um, axes_map, set_lims)

nPoints = length(vector_base_px);

grid_step = round(0.07*nPoints);
grid_scale_points = [1;(grid_step:grid_step:nPoints-grid_step)'];
grid_scale_um = round(grid_scale_points * dist_between_points_um);


%% Plot membrane:
hold(axes_map,  'on')
% axes_map.YDir = 'reverse';
vectors_norm = 15;

if ~isempty(set_lims)
    ylim(axes_map, [min(vector_base_px(:,2))-vectors_norm-20, max(vector_base_px(:,2))+vectors_norm+20])
    xlim(axes_map, [min(vector_base_px(:,1))-vectors_norm-40, max(vector_base_px(:,1))+vectors_norm+40])
end
%% Plot mini vectors:
plot(axes_map, vector_base_px(grid_scale_points,1), vector_base_px(grid_scale_points,2), '.', 'color', [1 1 1], 'markersize', 10); hold(axes_map,  'on')
quiver(axes_map, vector_base_px(grid_scale_points,1), vector_base_px(grid_scale_points,2), normals(grid_scale_points,1)*vectors_norm, normals(grid_scale_points,2)*vectors_norm, 'color', [1 1 1], 'autoscale', 'off', 'linewidth', 1);
text_coords = vector_base_px(grid_scale_points, :) + normals(grid_scale_points,:)*vectors_norm*1.5;

text(axes_map, text_coords(:,1),text_coords(:,2), num2str(grid_scale_um), 'color', [1 1 1], 'fontweight', 'bold', 'fontsize', 8);


