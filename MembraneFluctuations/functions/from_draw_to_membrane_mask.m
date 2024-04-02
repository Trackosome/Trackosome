function mask = from_draw_to_membrane_mask(mask_size, h_axes, radius)

if ~exist('h_axes', 'var')
    h_axes = gca;
end

h_draw = my_imfreehand(h_axes);
points = round(h_draw.getPosition);

% Just is case the hand gets out of the borders
points(points(:,1)<1,1) = 1;
points(points(:,2)<1,2) = 1;
points(points(:,1)>mask_size(2),1) = mask_size(2);
points(points(:,2)>mask_size(1),2) = mask_size(1);

sub_points = sub2ind(mask_size,points(:,2), points(:,1));
mask = zeros(mask_size);
mask(sub_points) = 1;
mask = imdilate(mask, strel('disk',radius));