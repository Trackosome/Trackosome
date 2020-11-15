
function [profile_coords, profile, inds] = my_improfile(I, points_x, points_y)


m = diff(points_y)/diff(points_x);
b = points_y(1)-m*points_x(1);

if abs(m)<1
    
    if points_x(2) < points_x(1)
        points_x = flip(points_x);
    end
    
    x_border = (points_x(1):points_x(2)-1)+0.5;
    y_border = round(m.*x_border + b);
    
    y_final = repmat(y_border, 2, 1);
    y_final = y_final(:);
    
    x_final_mid = points_x(1)+1:points_x(2)-1;
    x_final_mid = repmat(x_final_mid, 2, 1);
    x_final_mid = x_final_mid(:);
    x_final = [points_x(1); x_final_mid; points_x(2)];
    
elseif m == 0
    
    if points_x(2) < points_x(1)
        points_x = flip(points_x);
    end
    
    x_final = points_x(1):points_x(2);
    y_final = points_y(1)*ones(size(x_final));
    
elseif abs(m) == inf
    
    if points_y(2) < points_y(1)
        points_y = flip(points_y);
    end
    
    y_final = [points_y(1):points_y(2)]';
    x_final = points_x(1)*ones(size(y_final));
    
else 
    
    if points_y(2) < points_y(1)
        points_y = flip(points_y);
    end
    
    
    y_border = (points_y(1):points_y(2)-1)+0.5;
    x_border = round((y_border - b)/m);
    
    x_final = repmat(x_border, 2, 1);
    x_final = x_final(:);
    
    y_final_mid = points_y(1)+1:points_y(2)-1;
    y_final_mid = repmat(y_final_mid, 2, 1);
    y_final_mid = y_final_mid(:);
    y_final = [points_y(1); y_final_mid; points_y(2)];
end    
   

profile_coords = [x_final y_final];
profile_coords =  unique(profile_coords,'rows');


inds = sub2ind(size(I), profile_coords(:,2), profile_coords(:,1));
try
profile = I(inds);
catch
   disp('doo!') 
end
end