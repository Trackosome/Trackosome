function metrics = calc_membrane_metrics(Img_memb_BW,metadata)


if isempty(Img_memb_BW)
    
    metrics.centroid = [];
    metrics.pca = [];
    metrics.irregularity = [];
    metrics.eccentricity = [];
    
else    
    %% Calculate Median Nuclear Membrane
    z_step = metadata.z_step;
    px2um = metadata.px2um;
    nFrames = metadata.nFrames;
    
    irregularity = zeros(nFrames, 1);
    eccentricity = zeros(nFrames, 1);
    eig_vecs_vals = zeros(3, 4, nFrames);
    centroid = zeros(nFrames, 3);
    
    for f = 1:nFrames
        
        % Get membrane stack:
        stack = Img_memb_BW(:,:,:,f);
        [pY,pX,pZ] = ind2sub( size(stack), find( stack > 0 ) );
        
        if ~isempty(pY)
            
            % Centroid:
            point_coords_um = [ px2um*pX, px2um*pY, z_step*pZ ];
            centroid(f,:) = sum(point_coords_um, 1)' / size(point_coords_um,1);
            
            % PCA (Eigen vectors and Eigen Values):
            [ coeff, ~, latent] = pca( point_coords_um );
            eig_vecs_vals(:,:,f) = [ coeff, latent/sum(latent) ];
            
            % Excentricity and Solidity of biggest slice:
            areas = squeeze(sum(sum(Img_memb_BW(:,:,:, f),1 ),2));
            [~, z] = max(areas);
            slice = bwareafilt(logical(Img_memb_BW(:,:,z, f)), 1);
            stats = regionprops(slice, 'Solidity', 'Eccentricity');
            irregularity(f) = 1 - stats.Solidity;
            eccentricity(f) = stats.Eccentricity;
            
            % You can add more metrics here:
            % ...
        end
        
    end
    
    metrics.centroid = centroid;
    metrics.pca = eig_vecs_vals;
    metrics.irregularity = irregularity;
    metrics.eccentricity = eccentricity;
    
end

end
