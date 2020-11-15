%function imgElements = plot_frame_fluctuations(fluctuations_px, fluctuation_vectors, I, membrane, ref_memb_vars, mapElements, axes_h)
function plot_frame_fluctuations(fluctuations_px, fluctuation_vectors, I, membrane, ref_memb_vars, axes_h)

zoom_x = xlim(axes_h);
zoom_y = ylim(axes_h);

cla(axes_h)

normals = ref_memb_vars.normals;
nNormals = length(normals);
vectors_base = ref_memb_vars.vectors_base;

%% Imagesc with adjusted color scale:
offset = min(I(I>0));
I = I - offset;
I = I/max(I(:)) * 100;
I(I<0) = 0;
imagesc(axes_h, I)
% colorbar(axes_h)
cmap = jet(max(I(:)));
cmap(1,:) = ones(1,3);
colormap(axes_h, cmap);
axis(axes_h, 'equal')
hold(axes_h,  'on')
% set(axes_h,'DataAspectRatio', [1 1 1], 'fontsize', 8);

%% Plot fluctuations:
neg_flut_i = find(fluctuations_px < 0);
pos_flut_i = 1:nNormals;
pos_flut_i(neg_flut_i) = [];

x = vectors_base(: ,1);
y = vectors_base(:,2);

plot(axes_h,[x; x(1)], [y; y(1)], 'w', 'linewidth', 2);
plot(axes_h,membrane(:,1), membrane(:,2), 'k', 'linewidth', 2);

quiver(axes_h,x(pos_flut_i), y(pos_flut_i), fluctuation_vectors(pos_flut_i, 1), fluctuation_vectors(pos_flut_i, 2), 'r', 'autoscale', 'off', 'linewidth', 2);
quiver(axes_h,x(neg_flut_i), y(neg_flut_i), fluctuation_vectors(neg_flut_i, 1), fluctuation_vectors(neg_flut_i, 2), 'm', 'autoscale', 'off', 'linewidth', 2);

axis(axes_h, 'equal')
xlim(axes_h, zoom_x)
ylim(axes_h, zoom_y)

xticks(axes_h,[])
yticks(axes_h,[])
xticklabels(axes_h,[])
yticklabels(axes_h,[])
