function [Img_NM, Img_NM_BW, Img_CM, Img_CM_BW] = NM_CM_reconstruction(Img_NM, Img_CM, px2um, bin_thresh, to_filt)

scale_param = 0.189/px2um; % normalize for other px2um ratios

%% Nucleus Membrane Reconstruction:
Img_NM_BW = [];

if  ~isempty(Img_NM)    
    k_size_open = ceil(2 * scale_param);
    k_size_close = ceil(6 * scale_param);
    k_size_dilate = ceil(8 * scale_param);
    k_size_erode = ceil(8 * scale_param);
    morph_params = [k_size_open, k_size_close, k_size_dilate, k_size_erode];    
    
    if to_filt        
        Img_NM = filter_4D(Img_NM, [5,5,1,1]);
        Img_NM = Img_NM / max( Img_NM(:) );
    end
    Img_NM_BW = segment_membrane(Img_NM, bin_thresh, morph_params, 'Nucleus Membrane' );
end

%% Cell Membrane Reconstruction:
Img_CM_BW = [];

if ~isempty(Img_CM)    
    k_size_open = ceil(1 * scale_param);
    k_size_close = ceil(10 * scale_param);
    k_size_dilate = ceil(8 * scale_param);
    k_size_erode = ceil(10 * scale_param);
    morph_params = [k_size_open, k_size_close, k_size_dilate, k_size_erode];    
    
    if to_filt        
        Img_CM = filter_4D(Img_CM, [5,5,1,1]);
        Img_CM = Img_CM / max( Img_CM(:) );
    end
    
    Img_CM_BW =  segment_membrane(Img_CM, bin_thresh, morph_params, 'Cell Membrane' );
end



function Img_BW = segment_membrane(Img, bin_thresh, morph_params, title_txt)
  
k_size_open = morph_params(1);
k_size_close = morph_params(2);
k_size_dilate = morph_params(3);
k_size_erode = morph_params(4);  

Img_BW = zeros(size(Img));
[~,~,total_z,total_f] = size( Img );

m = waitbar(0, ['Segmenting ' title_txt '...']);
WinOnTop(m);

try    
    for f = 1:total_f
        
        try
            waitbar(f/total_f, m)
        catch
        end
        
        % Binarize image:
        if isempty(bin_thresh)
            Img_BW(:,:,:,f) = imbinarize(Img(:,:,:,f));
        else
            Img_BW(:,:,:,f) = imbinarize(Img(:,:,:,f), bin_thresh);
        end
        
        % Morphological operation to create closed areas:
        for z=1:total_z
            Img_BW(:,:,z,f) = imopen( Img_BW(:,:,z,f), strel('disk',round(k_size_open/2)));
            Img_BW(:,:,z,f) = imclose( Img_BW(:,:,z,f), strel('disk',round(k_size_close/2)));
            Img_BW(:,:,z,f) = imdilate( Img_BW(:,:,z,f), strel('disk',k_size_dilate) );
            Img_BW(:,:,z,f) = imerode( Img_BW(:,:,z,f), strel('disk',k_size_erode ) );
            Img_BW(:,:,z,f) = imfill( Img_BW(:,:,z,f), 'holes' );
        end
        
        % Choose biggest volume:
        conn = 26;
        CC = bwconncomp(Img_BW(:,:,:,f),conn);
        props = regionprops3(CC, 'Volume');
        sortedVolumes = sort([props.Volume], 'descend');
        Img_BW(:,:,:,f) = bwareaopen(Img_BW(:,:,:,f),sortedVolumes(1),conn);
        Img_BW(:,:,:,f) = Img_BW(:,:,:,f) .* Img_BW(:,:,:,f);
        
    end
        try
            close(m)
        catch
        end
    
catch     
    msgbox('ERROR in membrane segmentation. Try to correct with appropriate threshold.')
end






