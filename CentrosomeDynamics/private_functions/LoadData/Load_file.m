function [Imgs, nChannels, filename, metadata] = Load_file(dir_filename, metadata)
%% Load Files: .tiff, .tif, .nd2, .mat (saved data)
% Domingos Leite de Castro, domingos.castro@i3s.up.pt
% Paulo de Castro Aguiar, pauloaguiar@ineb.up.pt

[~, filename, ext] = fileparts(dir_filename);
Imgs = cell(3,1);

switch true    
    %% Load Tiff
    case strcmp(ext, '.tiff') ||  strcmp(ext, '.tif')
        nChannels = 1;
        try
            [Img, metadata.SizeX, metadata.SizeY,  metadata.nStacks, metadata.nFrames, metadata.z_step,...
                metadata.frame_step, metadata.px2um] = Import_Microscope_Tiff_Stack( dir_filename );             
        catch
            Img = loadtiff( dir_filename );
            [metadata.SizeY, metadata.SizeX, metadata.nStacks, metadata.nFrames] = size(Img);
            metadata.frame_step = nan;
            metadata.z_step = nan;
            metadata.px2um = nan;
        end
        Imgs{1} = Img;
        
    % Load Matlab matrix
    case strcmp(ext, '.mat')
        nChannels = 1;
        S = load(dir_filename);
        Imgs = struct2cell(S);
        [metadata.SizeY, metadata.SizeX, metadata.nStacks, metadata.nFrames] = size(Imgs);
        metadata.frame_step = nan;
        metadata.z_step = nan;
        metadata.px2um = nan;
        
    % Load ND2 file   
    case strcmp(ext, '.nd2')
        [Imgs, nChannels, metadata.nStacks, metadata.nFrames, metadata.px2um, metadata.z_step] = Open_BioFormat_for_CS_track(dir_filename);
        metadata.SizeY = size(Imgs{1}, 1);
        metadata.SizeX = size(Imgs{1}, 2);
        metadata.frame_step = nan;

    otherwise
        msgbox('Unkown file format. Load image as Tiff, Mat or ND2 file')        
end
end