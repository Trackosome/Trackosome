function [fluctuations_px_filt, fluctuation_vectors_filt, memb_coords_filt] = filter_fluctuations(fluctuations_px, normals, ref_memb, space_filt, time_filt)

if space_filt == 0
    space_filt = 0.00000000001;
end

if time_filt == 0
    time_filt = 0.00000000001;
end


fluctuations_px_filt = imgaussfilt(fluctuations_px, [space_filt, time_filt], 'padding', 'circular');


[nPoints, nFrames] = size(fluctuations_px);
fluctuation_vectors_filt = (ones([nPoints, 2, nFrames]).*normals).*reshape(fluctuations_px_filt, [nPoints, 1, nFrames]);

memb_coords_filt = ones([nPoints, 2, nFrames]).* ref_memb + ...
    (ones([nPoints, 2, nFrames]).* normals).*reshape(fluctuations_px_filt, [nPoints, 1,  nFrames]);

