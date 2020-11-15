function [CS_x_px, CS_y_px,CS_z_stack, CS_mask_ROI_XY, CS_mask_ROI_XZ, danger, foundCoords] = from_frame_to_CS_coords(Img_f, CS_mask_ROI_XY, CS_mask_ROI_XZ, metadata, xy_lims)

% Metadata:
rCentrosome_stacks = metadata.centrosome_radius_stacks;
rCentrosome_px = metadata.centrosome_radius_px;
nStacks = metadata.nStacks;

% Param for threshold
threshFactor_XY = 1.5;

%% Threshed ROI 3D:

% cut in Zs
temp_Img = permute(Img_f,[3 2 1]);
temp_Img_in_ROI_Zs = temp_Img.*CS_mask_ROI_XZ;
Img_in_ROI_Zs = permute(temp_Img_in_ROI_Zs, [3 2 1]);

% Define threshold for ROI
masked_projection_XY = sum(Img_in_ROI_Zs , 3).*CS_mask_ROI_XY;
thresh = mean(masked_projection_XY(masked_projection_XY ~=0 ))/nStacks*threshFactor_XY;

% Apply threshold to ROI
ROI_3D = Img_in_ROI_Zs.*CS_mask_ROI_XY;
ROI_3D( ROI_3D < thresh ) = 0;


%% Find coordinates of centrosomes inside 3D ROI:
[CS_x_px, CS_y_px,CS_z_stack, danger, foundCoords] = find_CS_Coords(ROI_3D, rCentrosome_px, rCentrosome_stacks, xy_lims);

if ~foundCoords.X || ~foundCoords.Y || ~foundCoords.Z
   return 
end
    

%% Define masks for next frame - based on 3 Coords:
[CS_mask_ROI_XY, CS_mask_ROI_XZ] = from_CS_coords_to_masks(CS_x_px, CS_y_px, CS_z_stack, metadata);
