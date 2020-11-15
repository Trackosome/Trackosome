function mask = from_draw_to_membrane_mask(mask_size, h_axes, radius)

if ~exist('h_axes', 'var')
    h_axes = gca;
end

h_draw = my_imfreehand(h_axes);
points = round(h_draw.getPosition);
sub_points = sub2ind(mask_size,points(:,2), points(:,1));
mask = zeros(mask_size);
mask(sub_points) = 1;
mask = imdilate(mask, strel('disk',radius));