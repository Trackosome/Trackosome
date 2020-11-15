function membrane = align_membranes(memb_new, ref_memb)
%% Shifts the coordinates of "membrane_new" so that its first point is close
% to the first point of "ref_memb"
%
% Arguments:
%   memb_new := coordinats of membrane [x,y] to align
%   ref_memb := coordinats of reference membrane [x,y] 
%
% Outputs:
%   membrane := alligned membrane coordinates [x,y] 
%%

dist_x = (memb_new(:,1) - ref_memb(1,1));
dist_y = (memb_new(:,2) - ref_memb(1,2));
dists = sqrt( dist_x.^2 + dist_y.^2);

[~, closest_pt] = min(dists);
membrane = [memb_new(closest_pt:end,:); memb_new(1:closest_pt-1,:)];

end
