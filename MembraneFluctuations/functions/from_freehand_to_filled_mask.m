
function [mask, h_draw] = from_freehand_to_filled_mask(mask, h_axes)

if ~exist('h_axes', 'var')
    h_axes = gca;
end

% h_draw = my_imfreehand(h_axes);
 h_draw = imfreehand(h_axes);
points = h_draw.getPosition;
points = [points; points(1,:)];

mask_size = size(mask);

for i =  1: length(points) - 1
    
    p1 =  points(i,:);
    p2 =  points(i + 1,:);
    theta = atan2( p2(:,2) - p1(:,2), p2(:,1) - p1(:,1));
    r = sqrt( (p2(:,1) - p1(:,1)).^2 + (p2(:,2) - p1(:,2)).^2);
    line = 0:r;
    x = round(p1(:,1) + line.*cos(theta));
    y = round(p1(:,2) + line.*sin(theta));
    
    sub_points = sub2ind(mask_size, y, x);
    mask(sub_points) = 1;
end

mask = imfill(mask);

end
