function [memb_coords_all, centered_I, centroids, error_signal, stopped] = Segment_Membs(I, nPoints, img_filt_side, memb_filter_width, step, masks)

error_signal = 0;
stopped = 0;

try
    
    size_I = size(I);
    if length(size_I) == 3
        nFrames = size_I(3);
    else
        nFrames = 1;
    end
    frame_size = size_I(1:2);
    
    centered_I = zeros(size(I));
    masked_I = zeros(size(I));
    
    centroids = zeros(nFrames,2);
    memb_coords_all = zeros(nPoints + 1, 2, nFrames);
    
    %% Define Initial Mask:
    Iproj_pre = squeeze(median(I(:,:,1:nFrames),3));
    
    if isempty(masks{1})
        membrane_mask_pre = ones(frame_size);
        membrane_mask_pre = Calc_Membrane_Mask( Iproj_pre, membrane_mask_pre, 0 );
    end
    
    %% Segment all Membranes:
    wait_bar = waitbar(0,'Segmenting Membranes...');
    
    for f = 1:nFrames
        
        break_signal = getappdata(0, 'stop_cycle');
        if  break_signal
            setappdata(0, 'stop_cycle', []);
            stopped = 1;
            break
        end
        
        
        %% Filter frame
        I_frame = I(:,:,f);
        I_frame = medfilt2( I_frame, [img_filt_side img_filt_side] );
        
        %% Membrane Mask:
        if isempty(masks{f})
            membrane_mask = Calc_Membrane_Mask( I_frame, membrane_mask_pre, 0 );
        else
            membrane_mask = masks{f};
        end
        masked_frame = I_frame .* membrane_mask;
        masked_I(:,:,f) = masked_frame;
        
        %% Extract Membrane Coords:
        [XY_borders] =  Extract_Profiles( membrane_mask, step, 0, 0);
        memb_coords_XY = Extract_Membrane_Coords_NEO(masked_frame, XY_borders, memb_filter_width, 0, 0);
        memb_coords_XY = interp_equal_space(memb_coords_XY, nPoints + 1);
        
        %% Center Membrane Coords and Frame
        [centroids(f,:), ~] = calc_centroid_area(memb_coords_XY, frame_size, false);
        [centered_I(:,:,f), centered_memb_coords] = membrane_Translaction(...
            I_frame, memb_coords_XY, centroids(f,:), centroids(1,:));
        memb_coords_all(:,:,f) = centered_memb_coords;
        
        %% Membrane Mask for Next Frame
        membrane_mask_pre = calc_next_membrane_mask(memb_coords_XY, frame_size);
        
        try
            waitbar(f/nFrames, wait_bar)
        catch
        end
    end
    
    try
        close(wait_bar)
    catch
    end
    
catch
    error_signal = 1;
    if nFrames>1
        msgbox(['Error segmenting membrane in frame ' num2str(f)]);
    else
        msgbox('Error segmenting membrane');
    end
end
