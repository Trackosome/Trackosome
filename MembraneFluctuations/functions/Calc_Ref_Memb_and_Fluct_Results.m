function [results, Iproj, error_signal, warning_frames] = Calc_Ref_Memb_and_Fluct_Results(I, memb_coords, nPoints, smooth_Ref_filter_width, space_filt, time_filt, px2um)
%%   Calculates the reference membrane and the fluctuation results
%
%   Arguments:
%   I := 3D (x,y,t) image stack 
%   memb_coords := membrane coords for all frames
%   nPoints := final number of points of the reference membrane
%   smooth_filter_width := size of the filter of the reference membrane
%   space_filt := size of fluctuations filter in space
%   time_filt := size of fluctuations filter in time
%   px2um := pixel to micrometer conversion
%
%   Outputs:
%   results := struc with all results
%   Iproj := median projection of all frames of I
%   error_signal := 1 if an error occurred during flucutations calculation
%   warning_frames := frames where fluctuation vectors have intersections
%
%%

step = 1;

% Reference Membrane and Normal Vectors:
[~, vectors_base_px, normals, Iproj] = Ref_memb_Normal_vecs(I, nPoints, smooth_Ref_filter_width);

% Fluctuations:
[fluctuations_px, fluctuations_vectors, error_signal, warning_frames] = from_Membs_to_Fluctuations(memb_coords, normals, ...
    vectors_base_px, nPoints, step);

dist_memb_points_um  = calc_dist_between_memb_points(vectors_base_px, px2um);

% Filter Fluctuations, Calculate Fourier Transform
[fluctuations_px_filt, fluctuations_vectors_filt, memb_coords_filt] = filter_fluctuations(fluctuations_px, normals, vectors_base_px, space_filt, time_filt);

[ffts_um_struct.full_ffts, ffts_um_struct.mean_fft_raw, ffts_um_struct.max_fft_raw, ffts_um_struct.freqs] = ...
    fluctuations_fourier(fluctuations_px * px2um, dist_memb_points_um);

[ffts_um_struct.full_ffts_filt, ffts_um_struct.mean_fft_filt, ffts_um_struct.max_fft_filt, ffts_um_struct.freqs] = ...
    fluctuations_fourier(fluctuations_px_filt * px2um, dist_memb_points_um);

% Outputs:
ref_memb_vars.normals = normals;
ref_memb_vars.vectors_base = vectors_base_px;
ref_memb_vars.smooth_filter_width = smooth_Ref_filter_width;
ref_memb_vars.dist_memb_points_um = dist_memb_points_um;

results.ref_memb_struct = ref_memb_vars; % Struct with variables from reference membrane
results.dist_ref_memb_points_um = dist_memb_points_um; % distance between points of reference membrane (also contained in ref_memb_vars)
results.memb_coords_raw = memb_coords; % coords of membranes for all frames
results.memb_coords_filt = memb_coords_filt; % coords of membranes for all frames filtered
results.fluctuations_px = fluctuations_px; % matrix with flucutations for all frames in pixels
results.fluctuations_px_filt = fluctuations_px_filt;  % matrix with filtered flucutations for all frames in pixels
results.fluctuations_vectors = fluctuations_vectors; % flucutations vectors for all frames in pixels
results.fluctuations_vectors_filt = fluctuations_vectors_filt; % filtered flucutations vectors for all frames in pixels
results.ffts_um_struct = ffts_um_struct; % Struct with results from fourier analysis