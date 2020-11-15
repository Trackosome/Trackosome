function [mean_NM, median_NM_filled] = calc_Median_NM(Img_NM_BW_trim, Img_NM_BW_trim_filled, NM_centroid_trim, px2um, z_step,toPlot)
%% Calculate Median Nuclear Membrane 
% Domingos Leite de Castro, domingos.castro@i3s.up.pt
% Paulo de Castro Aguiar, pauloaguiar@ineb.up.pt

refCentroid = NM_centroid_trim(:,1);
new_centroid = NM_centroid_trim;
centered_NM_BW = Img_NM_BW_trim;

if toPlot
    figure
end

for f = 2:length(NM_centroid_trim)
    
    transl_vec = [ round(( refCentroid(1)./px2um - NM_centroid_trim(1,f)./px2um )), round(( refCentroid(2)./px2um - NM_centroid_trim(2,f)./px2um )), ...
        round(( refCentroid(3)./z_step - NM_centroid_trim(3,f)./z_step ))];
    
    centered_NM_BW(:,:,:,f) = imtranslate(Img_NM_BW_trim(:,:,:,f), transl_vec);   
    centered_NM_BW_filled(:,:,:,f) = imtranslate(Img_NM_BW_trim_filled(:,:,:,f), transl_vec); 
    
    stack = centered_NM_BW(:,:,:,f);
    [pY,pX,pZ] = ind2sub( size(stack), find( stack > 0 ) );
    NM_point_coords_um = [ px2um*pX, px2um*pY, z_step*pZ ];
    new_centroid(:,f) = sum(NM_point_coords_um, 1)' / size(NM_point_coords_um,1);
    
    if toPlot
        subplot 221
        imagesc( sum(Img_NM_BW_trim_filled(:,:,:,1),3) + 5*sum(Img_NM_BW_trim_filled(:,:,:,f),3)), hold on
        plot(NM_centroid_trim(1,f)./px2um, NM_centroid_trim(2,f)./px2um , 'r*')
        plot(refCentroid(1)./px2um, refCentroid(2)./px2um, 'g*')
        title(['Raw VS Reference - XY - Frame: ' num2str(f)])
        
        subplot 222
        imagesc(5*sum(centered_NM_BW_filled(:,:,:,f),3)+ sum(Img_NM_BW_trim_filled(:,:,:,1),3)), hold on
        plot(new_centroid(1,f)./px2um, new_centroid(2,f)./px2um , 'r*')
        plot(refCentroid(1)./px2um, refCentroid(2)./px2um, 'g*')
        title(['Centered VS Reference - XY - Frame: ' num2str(f)])
        
         subplot 223
        imagesc( squeeze(sum(Img_NM_BW_trim_filled(:,:,:,1),1) + 5*sum(Img_NM_BW_trim_filled(:,:,:,f),1))'), hold on
        plot(NM_centroid_trim(1,f)./px2um, NM_centroid_trim(3,f)./z_step , 'r*')
        plot(refCentroid(1)./px2um, refCentroid(3)./z_step, 'g*')
        title(['Raw VS Reference - XZ - Frame: ' num2str(f)])
        
        subplot 224
        imagesc(squeeze(5*sum(centered_NM_BW_filled(:,:,:,f),1)+ sum(Img_NM_BW_trim_filled(:,:,:,1),1))'), hold on
        plot(new_centroid(1,f)./px2um, new_centroid(3,f)./z_step , 'r*')
        plot(refCentroid(1)./px2um, refCentroid(3)./z_step, 'g*')
        title(['Centered VS Reference - XZ - Frame: ' num2str(f)])        
        pause(0.1)
    end
end

mean_NM = mean(centered_NM_BW, 4);
median_NM_filled = median(centered_NM_BW_filled, 4);

end