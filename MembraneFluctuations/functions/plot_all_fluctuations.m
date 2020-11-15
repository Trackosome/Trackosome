
function plot_all_fluctuations(fluctuations_um, dist_memb_points_um, axes1)

[nPoints, Nframes] = size(fluctuations_um);

grid_step = round(0.07*nPoints);
grid_scale = round([1;(grid_step:grid_step:nPoints-grid_step)'] * dist_memb_points_um);

axes(axes1)
surf(1:Nframes, [1:nPoints]*dist_memb_points_um, fluctuations_um, 'edgecolor', 'none', 'facealpha', '0.9')
view(2)
axes1.YDir = 'reverse';
hold on
colorbar

xlabel('frame number ' );
ylabel('membrane arc [\mum]' );
zlabel('fluctuations amplitude [\mum]')
yticks(grid_scale)
yticklabels(axes1, grid_scale)
set(axes1, 'fontsize', 8)
xlim([0, Nframes])
ylim([0 nPoints*dist_memb_points_um])

for i = 1:length(grid_scale)
    plot(1:Nframes, grid_scale(i)*ones(Nframes, 1) ,'k-')
end
