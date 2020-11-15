function [CS_mask_ROI_XY, CS_mask_ROI_XZ] = masks_2coords(X, Y, metadata)

SizeX = metadata.SizeX;
SizeY = metadata.SizeY;
nStacks = metadata.nStacks; 
kernelROI_XY = metadata.kernelROI_XY; 
kernelROI_Zproj = metadata.kernelROI_Zproj;

CS_mask_XY = cat( 3, zeros(SizeY, SizeX), zeros(SizeY, SizeX));
CS_mask_XY( round(Y(1)), round(X(1)), 1 ) = 1;
CS_mask_ROI_XY(:,:,1) = imdilate(CS_mask_XY(:,:,1), kernelROI_XY);
CS_mask_XY( round(Y(2)), round(X(2)), 2 ) = 1;
CS_mask_ROI_XY(:,:,2) = imdilate(CS_mask_XY(:,:,2), kernelROI_XY);

% Define Initial XZ Masks as columns
CS_mask_XZ = cat(3, zeros(nStacks, SizeX), zeros(nStacks, SizeX));
CS_mask_XZ(:, round(round(X(1))), 1) = 1;
CS_mask_XZ(:, round(round(X(2))), 2) = 1;
CS_mask_ROI_XZ(:,:,1) = imdilate(CS_mask_XZ(:,:,1), kernelROI_Zproj);
CS_mask_ROI_XZ(:,:,2) = imdilate(CS_mask_XZ(:,:,2), kernelROI_Zproj);