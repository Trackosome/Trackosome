function [centroid, area] = calc_centroid_area(membrane_coords, frame_size, to_plot)
%% Calculates centroid and area of the nucleus 
%
%   Arguments:
%   membrane_coords := coordintates (x,y) of the closed curve (membrane)
%   frame_size := size of the images
%   to_plot := 1 - to plot results
%
%   Output:
%   centroid := centroid of the membrane
%   area:= area inside the membrane (area of the nucleus)
%%

[median_memb_full, median_memb_fill] = from_memb_coords_to_bw(membrane_coords, frame_size);

stats = regionprops(median_memb_fill, 'Area','Centroid');
area = stats.Area;
centroid = stats.Centroid;

if to_plot
    
    imagesc(median_memb_full + median_memb_fill), hold on
    plot(centroid(1),centroid(2), 'r.'),
    axis equal
    drawnow
    
end
end