function [Img1, Img2, Img3] = Open_BioFormat(filename)

data = bfopen(filename);
series1 = data{1,1};

%% Metadata: 

%Nr of Channels
label1 = series1{1,2};
foo = regexp( label1, '.+C=(\d+)+/+(\d+).+', 'tokens');
if ~isempty( foo )
    nChannels = str2double( foo{1}{2} );
else
    nChannels = 1;
end

% Nr of Slices
label1 = series1{1,2};
foo = regexp( label1, '.+Z=(\d+)+/+(\d+).+', 'tokens');
if ~isempty( foo )
    nSlices = str2double( foo{1}{2} );
else
    nSlices = 1;
end

%Nr of Frames
label1 = series1{1,2};
foo = regexp( label1, '.+T=(\d+)+/+(\d+)', 'tokens');
if ~isempty( foo )
    nFrames = str2double( foo{1}{2} );
else
    nFrames = 1;
end


%% Extract planes to Imgs

nPlanes = size(series1, 1);
frame_size = size(series1{1,1});

Img1 = zeros(frame_size(1), frame_size(2), nSlices, nFrames);
Img2 = zeros(frame_size(1), frame_size(2), nSlices, nFrames);
Img3 = zeros(frame_size(1), frame_size(2), nSlices, nFrames);

ch = 1;
slice = 1;
frame = 1;

for i = 1:nPlanes
    
    plane =  double(series1{i,1});
    
    if ch == 1
        Img1(:,:,slice, frame) = plane;
    elseif ch == 2
        Img2(:,:,slice, frame) = plane;
    elseif ch == 3
        Img3(:,:,slice, frame) = plane;
    end
    
    ch = ch + 1;
    
    if ch > nChannels          
        ch = 1;
        slice = slice + 1   ;        
        if slice > nSlices            
            slice = 1;
            frame = frame + 1;                        
        end
    end    
end

Img1 = squeeze(Img1);
Img2 = squeeze(Img2);
Img3 = squeeze(Img3);


