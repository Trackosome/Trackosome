
function visualize_reconstruction(reconstruction_axes, Img_NM_BW, Img_CM_BW, centroid, CS_x_um, CS_y_um, CS_z_um, metadata, CS_states)
%% Visualize Cell, nucleus and Centrosomes in 3D
%   Domingos Leite de Castro, domingos.castro@i3s.up.pt
%   Paulo de Castro Aguiar, pauloaguiar@ineb.up.pt

%%
px2um = metadata.px2um;
z_step = metadata.z_step;

cla(reconstruction_axes)
axes(reconstruction_axes)
hold on

blue = getappdata(0, 'gui_color_3');
green = getappdata(0, 'gui_color_4');
yellow = getappdata(0, 'gui_color_5');
red = getappdata(0, 'gui_color_6');

if ~isempty(CS_x_um) 
    
    CS_lines = [CS_x_um(1), CS_y_um(1), CS_z_um(1); centroid(1), centroid(2), centroid(3); CS_x_um(2), CS_y_um(2), CS_z_um(2) ];
    plot3( CS_lines(:,1), CS_lines(:,2), CS_lines(:,3), 'color', blue, 'linewidth', 1.5);
    
    for c = 1:2        
        if CS_states(c) == 3
            color = 'y';
        elseif CS_states(c) == 4
            color = [0.5 0.5 0.5];
        else
            if c == 1
                color = red;
            else
                color = blue;
            end
        end     
        scatter3( CS_x_um(c), CS_y_um(c), CS_z_um(c), 'o', 'filled', 'MarkerFaceColor', color);
        plot3( CS_x_um(c), CS_y_um(c), CS_z_um(c), 'o', 'Color', 'k');   
    end    
    scatter3( centroid(1), centroid(2), centroid(3), 'o', 'filled', 'MarkerFaceColor', yellow );    
end

if ~isempty(Img_NM_BW)
    V = Img_NM_BW(:,:,:);
   [XX, YY, ZZ] = meshgrid( px2um*(1:size(V,2)), px2um*(1:size(V,1)), z_step*(1:size(V,3)) );
    V = smooth3( Img_NM_BW(:,:,:)  );
    p = patch( isosurface( XX, YY, ZZ, V, 0.5 ) );
    isonormals( XX, YY, ZZ, V, p);
    set(p,'FaceColor', yellow, 'FaceAlpha', 0.8, 'EdgeColor', 'none');
end

if ~isempty(Img_CM_BW)
    V = smooth3( Img_CM_BW(:,:,:) );
    [XX, YY, ZZ] = meshgrid( px2um*(1:size(V,2)), px2um*(1:size(V,1)), z_step*(1:size(V,3)) );
    p = patch( isosurface( XX, YY, ZZ, V, 0.5 ) );
    isonormals( XX, YY, ZZ, V, p);    
    set(p,'FaceColor', green, 'FaceAlpha', 0.75, 'EdgeColor', 'none');
end

xlabel('[um]')
ylabel('[um]')
zlabel('[um]')
grid on;
light;
lighting gouraud;
camlight('left');
material dull

hold off
axis equal
drawnow
