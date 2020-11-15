function [fluctuations_px, fluctuations_vectors, error_signal, warning_frames] = ...
    from_Membs_to_Fluctuations(all_centered_memb_coords, normals, vector_base, nPoints, step)

nFrames = size(all_centered_memb_coords, 3);

window_calc_fluct = round(10/step);
fluctuations_px = zeros(nPoints, nFrames);
fluctuations_vectors = zeros(nPoints, 2, nFrames);
h = waitbar(0, 'Calculating fluctuations for all frames...');
error_signal = 0;

warnings = zeros(nFrames, 1);
frames = [1:nFrames];

for f = frames

    %% Calculate Fluctuations    
    [fluctuations_px(:,f), fluctuations_vectors(:,:,f), error_signal, warning_signal] = Calculate_Membrane_Fluctuations(...
    all_centered_memb_coords(:,:,f), normals, vector_base, window_calc_fluct, 0, 0 );
    
    if error_signal
        msgbox(['Error in Frame ' num2str(f) '. Try to correct reference membrane'])
        break
    end
    
    warnings(f) = warning_signal;
    
    try
        waitbar( f/nFrames, h );
    catch
    end        
    
end

warning_frames = nonzeros(frames.*warnings');
close(h);
