
function [Img_NM_BW, Img_CM_BW, centroid, CS_coords_um] = defineReconstInputs(imgs_to_show, CS_coords_um, NM_vars, CM_vars, f)
%% Define inputs for 3D visualization function

if imgs_to_show(1) % Centrosomes
        
    CS_coords_um.x = CS_coords_um.x(f,:);
    CS_coords_um.y = CS_coords_um.y(f,:);
    CS_coords_um.z = CS_coords_um.z(f,:);    
    centroid = NM_vars.metrics.centroid(f, :);
else
    CS_coords_um.x = [nan nan];
    CS_coords_um.y = [nan nan];
    CS_coords_um.z = [nan nan];
    centroid = [nan nan nan];
end

% Nucleus Memb:
if imgs_to_show(2) 
    centroid = NM_vars.metrics.centroid(f,:);
    Img_NM_BW = NM_vars.memb_BW(:,:,:,f);
else
    Img_NM_BW = [];
end

% Cell Memb:
if imgs_to_show(3)     
    Img_CM_BW = CM_vars.memb_BW(:,:,:,f);
else
    Img_CM_BW = [];
end
