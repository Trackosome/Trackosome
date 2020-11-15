function [CS_mask_ROI_XY, CS_mask_ROI_XZ] = generate_frame_masks(f, ROI_pos, metadata)

xi = ROI_pos.xi;
yi = ROI_pos.yi;
zi = ROI_pos.zi;
lx = ROI_pos.lx;
ly = ROI_pos.ly;
lz = ROI_pos.lz;

CS_mask_ROI_XY(:,:,1) = from_ROI_pos_to_mask(xi(f, 1), yi(f, 1), lx(f, 1), ly(f, 1), metadata.SizeY, metadata.SizeX);
CS_mask_ROI_XY(:,:,2) = from_ROI_pos_to_mask(xi(f, 2), yi(f, 2), lx(f, 2), ly(f, 2), metadata.SizeY, metadata.SizeX);
CS_mask_ROI_XZ(:,:,1) = from_ROI_pos_to_mask(xi(f, 1), zi(f, 1), lx(f, 1), lz(f, 1), metadata.nStacks, metadata.SizeX);
CS_mask_ROI_XZ(:,:,2) = from_ROI_pos_to_mask(xi(f, 2), zi(f, 2), lx(f, 2), lz(f, 2), metadata.nStacks, metadata.SizeX);

end