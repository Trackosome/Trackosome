function [ signal_FFT_abs, freqs ] = FFT_Paulo( signal, SamplingRate )
%FFT_Paulo Fast Fourier Transform
%   Calculates and plots FFT
%
%   Sintax:
%   [ signal_FFT_abs, freqs ] = FFT_Paulo( signal, SamplingRate )
%
%   Arguments:
%   signal := raw signal
%   SamplingRate := acquisition sampling rate in Hz
%
%   Outputs:
%   signal_FFT_abs := absolute value of FFT signal
%   freqs := frequency space interval

    Nyquist = 0.5 * SamplingRate;
    y = signal;
    y_clean = y - mean(y);
    Y = fft( y_clean );
    L       = round( length(Y)/2 );
    signal_FFT_abs   = abs( Y(1:L) ) / L ;
    freqs   = linspace( 0, Nyquist, L );


end

