function [membrane_mask] = Calc_Membrane_Mask( I, memb_mask_pre, to_plot )
%% Calculates a "donut-shaped" mask around the membrane coordinates
%
% Arguments:
%   I := raw image of current frame
%   memb_mask_pre := binary mask of previous frame
%   to_plot := 1 to plot results
%
% Outputs
%   membrane_mask := mask of membrane for current frame
%%

I_masked = I.*memb_mask_pre;
m = median( I(:) );
s = std( I(:) );

thresh = 5;
repeat = true;
close_size = 15;

count = 1;

while repeat
    
    membrane_mask = false( size( I ) );
    membrane_mask( I_masked > (m + thresh * s) ) = true;
    
    membrane_mask = bwareaopen( membrane_mask, 100 ); 
    membrane_mask = imclose(membrane_mask, strel('disk', close_size) );
    
    if to_plot        
        imagesc(membrane_mask + memb_mask_pre)
        axis equal
        drawnow          
    end
    
    bounds = bwboundaries(membrane_mask);
    [~,nAreas] = bwlabel(membrane_mask);
    
    if numel(bounds)~=2 || nAreas ~=1
        thresh = thresh*0.9;
    else
        repeat = false;
    end
    
    count = count + 1;
    
    if count > 50
      membrane_mask = memb_mask_pre;
      repeat = false;
    end
    
end
end

