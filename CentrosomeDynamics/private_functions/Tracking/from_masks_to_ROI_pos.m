function [xi, yi, zi, lx, ly, lz] = from_masks_to_ROI_pos(CS_mask_ROI_XY , CS_mask_ROI_XZ)

% Find positions of Rectangles:
[rows_ROI_1, cols_ROI_1] = find(CS_mask_ROI_XY(:,:,1));
yi(1) = rows_ROI_1(1) - 0.5;
xi(1) = cols_ROI_1(1) - 0.5;
lx(1) = cols_ROI_1(end) - xi(1) + 1.5;
ly(1) = rows_ROI_1(end) - yi(1) + 1.5;

[rows_ROI_2, cols_ROI_2] = find(CS_mask_ROI_XY(:,:,2));
yi(2) = rows_ROI_2(1) - 0.5;
xi(2) = cols_ROI_2(1) - 0.5;
lx(2) = cols_ROI_2(end) - xi(2) + 1.5;
ly(2) = rows_ROI_2(end) - yi(2) + 1.5;

step = 0.3;
[stacks_ROI_1, ~] = find(CS_mask_ROI_XZ(:,:,1));
zi(1) = stacks_ROI_1(1) - step;
lz(1) = stacks_ROI_1(end) - zi(1) + step;% + 1;
 
[stacks_ROI_2, ~] = find(CS_mask_ROI_XZ(:,:,2));
zi(2) = stacks_ROI_2(1) - step;
lz(2) = stacks_ROI_2(end) - zi(2) + step;% + 1;
