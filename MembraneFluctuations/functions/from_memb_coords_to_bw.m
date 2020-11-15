function [median_memb_full, median_memb_fill] = from_memb_coords_to_bw(membrane_coords, frame_size)
% Convert a binary closed curve (nucelar envelope) to a binary area (nucleus)
%
%   Arguments:
%   membrane_coords := coordintates [x,y] of the closed curve (membrane)
%   frame_size := size of the image
%
%   Output:
%   mean_dist_memb_points_um := verage distance between points in micrometers
%   perimeter_um := perimeter of the closed curve (membrane) in micrometers


memb_bw = zeros(frame_size);
memb_int_coords = round(membrane_coords);

memb_bw(sub2ind(size(memb_bw),memb_int_coords(:,2),memb_int_coords(:,1))) = 1;
median_memb_full = imdilate(memb_bw, ones(3,3));
median_memb_full = imclose(median_memb_full, strel('disk', 20));
median_memb_fill = imfill(median_memb_full, 'holes');

end