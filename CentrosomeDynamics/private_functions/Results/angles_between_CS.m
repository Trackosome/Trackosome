function [angles] = angles_between_CS(CS_x_um, CS_y_um, CS_z_um, NM_centroid, frames_to_keep, plot_angles)
%% Calculates the 3D angles formed between the centrosomes and the nucleus centroid for all selected frames
% Domingos Leite de Castro, domingos.castro@i3s.up.pt
% Paulo de Castro Aguiar, pauloaguiar@ineb.up.pt

CS1 = [CS_x_um(:,1) CS_y_um(:,1) CS_z_um(:,1)];
CS2 = [CS_x_um(:,2) CS_y_um(:,2) CS_z_um(:,2)];

centered = false;
if isempty(NM_centroid)
    zeros(3,length(CS_x_um));
    centered = true;
end

u = CS1 - NM_centroid;
v = CS2 - NM_centroid;

% 3D Angle:
angles = acos(dot(u,v,2)./calc_norms(u)./calc_norms(v)) * 180/pi .* frames_to_keep;

c = linspace(1,10,length(CS_x_um(:,1)));
sz = 15;

if plot_angles
    figure
    subplot 121
    plot3(CS_x_um(:,1), CS_y_um(:,1), CS_z_um(:,1), 'r', 'linewidth', 2), hold on
    plot3(CS_x_um(:,2), CS_y_um(:,2), CS_z_um(:,2), 'b', 'linewidth', 2)
    scatter3(CS_x_um(:,1), CS_y_um(:,1), CS_z_um(:,1), sz,c,'filled');
    scatter3(CS_x_um(:,2), CS_y_um(:,2), CS_z_um(:,2), sz,c,'filled');
    
    
    axis equal
    if centered
        zeros_vec = zeros(size(NM_centroid(:,1)));
        quiver3(zeros_vec, zeros_vec, zeros_vec, u(:,1), u(:,2), u(:,3), 'r', 'autoscale', 'off');
        quiver3(zeros_vec, zeros_vec, zeros_vec, v(:,1), v(:,2), v(:,3), 'b', 'autoscale', 'off');
    else
        quiver3(NM_centroid(:,1), NM_centroid(:,2), NM_centroid(:,3), u(:,1), u(:,2), u(:,3), 'r', 'autoscale', 'off');
        quiver3(NM_centroid(:,1), NM_centroid(:,2), NM_centroid(:,3), v(:,1), v(:,2), v(:,3), 'b', 'autoscale', 'off');
    end
    
    subplot 122
    plot(angles), title('Angles')
end

end
