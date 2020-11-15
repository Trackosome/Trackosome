function plot_frame_projection(Img, axes_handle, proj_dir)

projection = squeeze(max( Img, [], proj_dir)) ;
if proj_dir~=3
    projection = projection';
end
axes(axes_handle);
cla

imagesc(projection), hold on

if proj_dir == 3
    axes_handle.YDir = 'reverse';
else
    axes_handle.YDir = 'normal';
end




