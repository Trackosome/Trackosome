function mask = from_ROI_pos_to_mask(xi, yi, lx, ly, sizeY, sizeX)

mask = zeros(sizeY, sizeX);
mask(round(yi + 0.5): round(yi + ly - 1 - 0.5), round(xi + 0.5) : round(xi + lx - 1 - 0.5)) = 1; % +/- 0.5 to account for the deviations required to plot imrect ROIs

end