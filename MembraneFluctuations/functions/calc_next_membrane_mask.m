function membrane_mask_next = calc_next_membrane_mask(membrane_coords, frame_size)
%% Calculate an expanded membrane mask for next frame
% Arguments:
%   membrane_coords := membrane coords [x,y] of membrane
%   frame_size := size of image
%
% Output:
%   membrane_mask_next := binary mask to be used in next frame
%%

membrane_mask_next = false(frame_size);
inds = sub2ind(frame_size, round(membrane_coords(:,2)), round(membrane_coords(:,1)));
membrane_mask_next(inds) = 1;
membrane_mask_next = imdilate(membrane_mask_next, ones(30));

end