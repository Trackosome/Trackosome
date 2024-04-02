function [Img, SizeX, SizeY, Nstacks, Nframes, z_step, frame_step, px2um] = Import_Microscope_Tiff_Stack( filename )
% Import_Microscope_Tiff_Stack
%   Import microscope tiff stack and associated parameters
%   Paulo de Castro Aguiar, pauloaguiar@ineb.up.pt

Img = loadtiff( filename );
Img = single(Img);

% get info from file 
A = imfinfo( filename );

if isfield(A, 'ImageDescription' )
    B = A.ImageDescription;
else
    B = '';
end

foo = regexp( B, '.+slices=(\d+).+', 'tokens');
if ~isempty( foo )
    Nstacks = str2double( foo{1} );
else
    Nstacks = 1;
end

foo = regexp( B, '.+spacing=(\d+\.\d+).+', 'tokens');
if ~isempty( foo )
    z_step = str2double( foo{1} );
else
    z_step = nan;
end

foo = regexp( B, '.+finterval=(\d+\.\d+).+', 'tokens');
if ~isempty( foo )
    frame_step = str2double( foo{1} );
else
    frame_step = nan;
end

foo = regexp( B, '.+frames=(\d+).+', 'tokens');
if ~isempty( foo )
    Nframes = str2double( foo{1} );
else
    Nframes = 1;
end

if Nframes*Nstacks == 1
    Nframes = size(Img,3);
end

SizeX = size(Img,2);
SizeY = size(Img,1);

if isempty(A(1,1).XResolution)
    px2um = 1.0; %resolution assumed to be equal in X and Y
    warndlg(['No Pixel resolution data in image metadata.' ...
        newline 'We are assuming 1 px/um.' newline 'You can change px/um conversion in Metadata'])
else
    px2um = 1.0 / A(1,1).XResolution; %resolution assumed to be equal in X and Y
end

Img = reshape(Img, SizeY, SizeX, Nstacks, Nframes);

end

