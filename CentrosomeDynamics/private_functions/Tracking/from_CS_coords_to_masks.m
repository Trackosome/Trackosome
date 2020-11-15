function [CS_mask_ROI_XY, CS_mask_ROI_XZ] = from_CS_coords_to_masks(X_px, Y_px, Z_stack, metadata)

kernelROI_XY = metadata.kernelROI_XY;
kernelROI_Zproj = metadata.kernelROI_Zproj;
nStacks = metadata.nStacks;
SizeY = metadata.SizeY;
SizeX = metadata.SizeX;

CS_mask_XY = zeros(SizeY, SizeX);

try
CS_mask_XY(round(Y_px), round(X_px)) = 1;
catch
   disp("Error") 
end


CS_mask_ROI_XY = imdilate(CS_mask_XY(:,:), kernelROI_XY);

CS_mask_XZ = zeros(nStacks, SizeX);
CS_mask_XZ(round(Z_stack), round(X_px)) = 1;
CS_mask_ROI_XZ = imdilate(CS_mask_XZ(:,:), kernelROI_Zproj);