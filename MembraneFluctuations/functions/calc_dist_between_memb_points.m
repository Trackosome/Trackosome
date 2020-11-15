function [mean_dist_memb_points_um, perimeter_um] = calc_dist_between_memb_points(memb, px2um)
% Calculates the average distance between points of a closed curve (membrane)
%
%   Arguments:
%   memb := coordintates [x,y] of the closed curve (membrane)
%   px2um := pixel to micrometer conversion
%
%   Output:
%   mean_dist_memb_points_um := verage distance between points in micrometers
%   perimeter_um := perimeter of the closed curve (membrane) in micrometers

memb_ahead = [memb(2:end,:); memb(1,:)];
dist_memb_points_um = sqrt((memb_ahead(1:end-1,1) - memb(1:end-1,1)).^2 + (memb_ahead(1:end-1,2) - memb(1:end-1,2)).^2);
perimeter_um = sum(dist_memb_points_um) * px2um;
mean_dist_memb_points_um = mean(dist_memb_points_um) * px2um;

end