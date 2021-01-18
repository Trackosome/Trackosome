function [Img_filt, is_filtered] = Spatial_Filtering_3D_LoG( Img, cs_radius_px, scale)
% Spatial_Filtering_3D
%   Perform convolution of image with a given kernel
%   Paulo de Castro Aguiar, pauloaguiar@ineb.up.pt
%   Domingos Leite de Castro, domingos.castro@i3s.up.pt

[SizeY, SizeX, ~, Nframes] = size( Img );

%% Kernel side

% Hardcoded Optimization!
% if cs_radius_px > 4
%    cs_radius_px = cs_radius_px - 2; 
% end

Lxy = round(5*cs_radius_px);

%% Kernel - Laplacian of Gaussian:
if mod(Lxy,2) == 0
    Lxy = Lxy + 1;
end
Lz = round( Lxy / scale);
if mod(Lz,2) == 0
    Lz = Lz + 1;
end

Lxy_2 = (Lxy-1)/2;
Lz_2  = (Lz -1)/2;

[XX, YY, ZZ] = ndgrid( -Lxy_2:Lxy_2, -Lxy_2:Lxy_2, -Lz_2:Lz_2);
s_z  = cs_radius_px / scale;

G_plus  = exp(-(XX.*XX/2/cs_radius_px^2 + YY.*YY/2/cs_radius_px^2 + ZZ.*ZZ/2/s_z^2));
G_plus  = G_plus / sum( G_plus(:) );

G_minus = exp(-1/2*(XX.*XX/2/cs_radius_px^2 + YY.*YY/2/cs_radius_px^2 + ZZ.*ZZ/2/s_z^2));
G_minus  = G_minus / sum( G_minus(:) );

kernel = G_plus - G_minus;


%% Convolution:
h = waitbar(0, 'Applying Laplacian of Gaussian (LoG) filter');

[nY, nX, nZ, nF] = size(Img);
Img_filt_raw = zeros(nY, nX, nZ + ceil(Lz_2)*2, nF);
Img_filt = single(zeros(nY, nX, nZ, nF));
filter_break = 0;

for f = 1:Nframes
    
    % Check if filtering was stoped in user-interface 
    if getappdata(0, 'gui_ChooseFrames_break') 
        setappdata(0, 'gui_ChooseFrames_break', 0)
        m = msgbox('Filtering stopped');
        Img_filt =  Img;  
        filter_break = 1;
        break
    end
    
    % repeat borders
    top = repmat( Img(:,:,end,f), [1, 1, ceil(Lz_2)] );
    bottom = repmat( Img(:,:,1,f), [1, 1, ceil(Lz_2)] );
    
    % Convolution
    Img_to_conv = cat(3,bottom, Img(:,:,:,f), top);
    Img_filt_raw(:,:,:,f) = convnfft(Img_to_conv, kernel, 'same');    
    Img_filt(:,:,:,f) = single(Img_filt_raw(:,:,ceil(Lz_2)+1:end-ceil(Lz_2),f));

    waitbar(f/Nframes);
end

% Remove borders
if ~filter_break
    Img_filt(1:round(Lxy_2), :, :, :) = 0;
    Img_filt(SizeY-round(Lxy_2):end, :, :, :) = 0;
    Img_filt(:, 1:round(Lxy_2), :, :) = 0;
    Img_filt(:,SizeX-round(Lxy_2):end, :, :) = 0;
    is_filtered = 1;
else
    is_filtered = 0;
end

try
close(h);
catch
end

end