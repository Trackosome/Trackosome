function [CS_x_px, CS_y_px, CS_z_stack] = calculate_Centroid_3D(Img, metadata, X, Y, initialFrame, finalFrame, CS_x_px, CS_y_px, CS_z_stack)

% Metadata:
rCentrosome_px = metadata.centrosome_radius_px;
frame_step = metadata.frame_step;
z_step  = metadata.z_step; 


%% Masks Dimensions
rCentrosome_stacks = round(1.5/z_step); % r around 2 stacks;
lengthROI_px = ceil(frame_step/5*rCentrosome_px); % around 30 px;
lengthROI_stacks = ceil(frame_step/5 * rCentrosome_stacks); % around 10 stacks 
kernelROI_XY = strel('rectangle',[lengthROI_px, lengthROI_px]);
kernelROI_Zproj = strel('rectangle',[lengthROI_stacks lengthROI_px]); % Region of Interest XZ for frame i+1

metadata.rCentrosome_stacks = rCentrosome_stacks;
metadata.lengthROI_px = lengthROI_px;
metadata.lengthROI_stacks = lengthROI_stacks;
metadata.kernelROI_XY = kernelROI_XY;
metadata.kernelROI_Zproj = kernelROI_Zproj;

%% Initial Masks - based on 2 Coords only:
[CS_mask_ROI_XY, CS_mask_ROI_XZ] = masks_2coords(X, Y, metadata);


%% Tracking Cycle:
thresh = zeros(1, 2);
Img_plot = Img;
threshFactor_XY = 1.5;

for f = initialFrame:finalFrame   
        
    for c = 1:2
              
        [CS_x_px(f,c), CS_y_px(f,c),CS_z_stack(f,c), CS_mask_ROI_XY(:,:,c), CS_mask_ROI_XZ(:,:,c)] = from_frame_to_CS_coords(Img(:,:,:,f), f, CS_mask_ROI_XY(:,:,c), CS_mask_ROI_XZ(:,:,c), threshFactor_XY,  kernelROI_XY, kernelROI_Zproj, metadata);
   
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

%         clf(figure(1000))
%         clf(figure(2000))        
%         clf(figure(666))    

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

    end

    
    % % % % % PROJECTIONS FOR PLOTS:
    Img_plot(:,:,:,f) = Img(:,:,:,f);
    Img_plot(Img_plot < max(thresh) ) = 0;
        
    plot_projection_XY = squeeze(sum( Img_plot(:,:,:, f), 3)) ;
    plot_projection_XZ = squeeze(sum( Img_plot(:,:,:, f), 1))';
    plot_projection_YZ = squeeze(sum( Img_plot(:,:,:, f), 2))';
      
    figure(2)
    subplot 131
    imagesc(plot_projection_XY), hold on
    plot(CS_x_px(f,1), CS_y_px(f,1), 'r*')
    plot(CS_x_px(f,2), CS_y_px(f,2), 'r*')
    title(['XY Projection - frame = ' num2str(f) ])
    xlabel('X'), ylabel('Y')
    
    subplot 132
    imagesc(plot_projection_XZ), hold on
    
    plot(CS_x_px(f,1), CS_z_stack(f,1), 'r*')
    plot(CS_x_px(f,2), CS_z_stack(f,2), 'r*')
    title('XZ Projection')
    xlabel('X'), ylabel('Z')
    
    subplot 133
    imagesc(plot_projection_YZ), hold on
    plot(CS_y_px(f,1), CS_z_stack(f,1), 'r*')
    plot(CS_y_px(f,2), CS_z_stack(f,2), 'r*')
    
    title('YZ Projection')
    xlabel('Y'), ylabel('Z')


end


end


