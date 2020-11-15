function [threshed_masked_projection] = Thresh_Masked_Projection(masked_projection,threshFactor_Zproj,kernelCentrosome_Zproj)

kernelCentrosome_Zproj = strel('rectangle', [1 5]);
adjust_thresh = true;
c = 0;

while adjust_thresh
    
    c = c + 1;
    thresh = mean(masked_projection(masked_projection > 0))*threshFactor_Zproj;
    threshed_masked_projection = masked_projection;
    threshed_masked_projection( masked_projection < thresh ) = 0;
    
    BW_threshed_masked = threshed_masked_projection;
    BW_threshed_masked(BW_threshed_masked>0) = 1;
    BW_threshed_masked(isnan(BW_threshed_masked)) = 0;
    
    figure (10)
    subplot 121, imagesc(BW_threshed_masked)    
    
   %% PODE ELIMINAR O CENTROSSOMA!!!
%     BW_threshed_masked = imopen(BW_threshed_masked, kernelCentrosome_Zproj);
    subplot 122, imagesc(BW_threshed_masked) 
    
    
    [~, n_bodies] = bwlabel(BW_threshed_masked);   
   
    
    if n_bodies == 1
        adjust_thresh = false;
    elseif n_bodies > 1
        threshFactor_Zproj = threshFactor_Zproj*1.03;
    else
        threshFactor_Zproj = threshFactor_Zproj*0.97;
    end
    
    if threshFactor_Zproj < 0.1 || threshFactor_Zproj > 10 || c == 30; 
        disp('Ups...')
        return
    end
    
end

threshed_masked_projection(isnan(threshed_masked_projection)) = 0;
threshed_masked_projection = threshed_masked_projection.*BW_threshed_masked;
end

