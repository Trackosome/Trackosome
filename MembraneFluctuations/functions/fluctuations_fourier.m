function [full_ffts, mean_fft, max_fft, freqs] = fluctuations_fourier(fluct_um, dist_memb_points_um)

% Calcualte Fourier Transform (FT) of the fluctations
% 
%   Arguments:
%   fluct_um := 2D matrix with the fluctuations (in micrometers) for all frames
%   dist_memb_points_um := distance between poiints of reference membrane in micrometers    
% 
%   Outpus:
%   full_ffts := FT for all frames
%   mean_fft := mean FT of all frames
%   max_fft := majorant FT of all frames
%   freqs := frequency axis 
% 


[~, nFrames] = size(fluct_um); 

%% Spatial FFTs:

[ signal_FFT, freqs ] = FFT_Paulo( fluct_um(:,1), 1/dist_memb_points_um );
full_ffts = zeros(length(signal_FFT), nFrames);

full_ffts(:,1) = signal_FFT;

for f = 1:nFrames
    [ full_ffts(:,f), ~] = FFT_Paulo( fluct_um(:,f), 1/dist_memb_points_um );   
end


%% Mean Fourier Transform:
mean_fft =  mean(full_ffts, 2);

%% Max Fourier Transform:
max_fft = max(full_ffts, [], 2);
       

end