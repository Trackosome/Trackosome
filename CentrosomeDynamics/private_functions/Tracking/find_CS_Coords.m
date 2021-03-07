function [x,y,z, warning, foundCoords] = find_CS_Coords(ROI_3D, rCentrosome_px, rCentrosome_stacks, lims_xy)

XX = true;
YY = true;
ZZ = true;
warning = false;
foundCoords = [];
[sizeY, sizeX, nStacks] = size(ROI_3D);

projection_ROI_XY = max(ROI_3D, [],3);
projection_ROI_XZ  = squeeze(max(ROI_3D,[],1))';
      
        
mean_metric = 0;

for i = 1:3 % Shorten the ROI
        
    %% Find best Dimension:       
    metricsXYZ = -1*ones(1,3);     
    
    if XX
        intProfile_X = sum( projection_ROI_XY, 1);
        metricsXYZ(1) = calc_profile_metric2(intProfile_X, rCentrosome_px, 'X');        
    end
    
    if YY
        intProfile_Y = sum( projection_ROI_XY, 2);
        metricsXYZ(2) = calc_profile_metric2(intProfile_Y, rCentrosome_px, 'Y');     
    end
    
    if ZZ
        intProfile_Z = sum( projection_ROI_XZ, 2);
        metricsXYZ(3) = calc_profile_metric2(intProfile_Z, rCentrosome_stacks, 'Z');
    end
    
    [maxMetric, axis_to_shrink] = max(metricsXYZ);
    
    %% Shrink ROI in the best dimension    
    if axis_to_shrink == 1 
        
        [~,x_peak] = max(intProfile_X);        
        xi_CS = max(1,x_peak-ceil(rCentrosome_px));
        xf_CS = min(sizeX,x_peak+ceil(rCentrosome_px));   
             
        % shrink ROI 3D in XX:
        new_X_mask = zeros(sizeY, sizeX);
        new_X_mask(:,xi_CS:xf_CS) = 1;        
        ROI_3D = ROI_3D .* new_X_mask;
        
        XX = false;
        
    elseif axis_to_shrink == 2       
        
        [~,y_peak] = max(intProfile_Y);
        yi_CS = max(1,y_peak-ceil(rCentrosome_px));
        yf_CS = min(sizeY,y_peak+ceil(rCentrosome_px));          
        
        % shrink ROI 3D in YY:
        new_Y_mask = zeros(sizeY, sizeX);
        new_Y_mask(yi_CS:yf_CS,:) = 1;       
        ROI_3D = ROI_3D .* new_Y_mask;
        
        YY = false;        
    else         
        
        [~,z_peak]= max(intProfile_Z);
        zi_CS = max(1,z_peak-ceil(rCentrosome_stacks));
        zf_CS = min(nStacks,z_peak+ceil(rCentrosome_stacks));        
        perm_ROI = permute(ROI_3D,[3 2 1]);
        
        intProfile_Z_bin = intProfile_Z > 0;
        if sum(intProfile_Z_bin(zi_CS:zf_CS)) >= 3      
            % shrink ROI 3D in ZZ:
            % you need at least 3 slices to fit a gaussian  
            new_Z_mask = zeros(nStacks, sizeX);
            new_Z_mask(zi_CS:zf_CS,:) = 1;     
            perm_ROI = perm_ROI.*new_Z_mask;
        end
        ROI_3D = permute(perm_ROI, [3 2 1]);       
        
        ZZ = false;
    end   
    
    projection_ROI_XY = sum(ROI_3D, 3);
    projection_ROI_XZ  = squeeze(sum(ROI_3D,1))';

end

        %% Calc centroid of new ROI_3D:
        
        xLims = [lims_xy, sizeX - lims_xy];
        yLims = [lims_xy, sizeY - lims_xy];
        zLims = [1 nStacks];
        
        % Calc X coords:        
        intProfile_X = sum( projection_ROI_XY, 1);    
        [~, x,~, foundCoords.X] = fitGauss(intProfile_X, xLims); % Gauss

        
        % Calc Y coord:
        intProfile_Y = sum( projection_ROI_XY, 2);
        [~, y,~, foundCoords.Y] = fitGauss(intProfile_Y, yLims); % Gauss

        
        % calc Z coord:
        intProfile_Z = sum( projection_ROI_XZ, 2);
        [~, z,~, foundCoords.Z] = fitGauss(intProfile_Z, zLims);
        

         if  (z == 1 || z == nStacks) || (x == xLims(1) || x == xLims(2)) || (y == yLims(1) || y == yLims(2))
           warning = true; 
         end
        
end

