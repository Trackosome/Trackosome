function mask = from_ROI_rect_to_masks(h_ROI, sizeX, sizeY)

pos = getPosition(h_ROI);
xi = round(pos(1));
yi = round(pos(2));
lx = round(pos(3));
ly = round(pos(4)); 

 mask = from_ROI_pos_to_mask(xi, yi, lx, ly, sizeY, sizeX);