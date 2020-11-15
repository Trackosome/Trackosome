function [I, metadata] = Load_Files(fname)

I = [];
metadata = [];
[~, name, type] = fileparts(fname);

if strcmp(type, '.tif') ||  strcmp(type, '.tiff')
    m = msgbox('Importing Tiff Stack...');
    [I, metadata.SizeX, metadata.SizeY, ~, metadata.nFrames, ~, metadata.frame_step, metadata.px2um] ...
        = Import_Microscope_Tiff_Stack( fname );
    
    
% % % elseif strcmp(type, '.mat')
% % %     m = msgbox('Importing .mat file...');
% % %     load(fname, 'I', 'px2um', 'frame_step', 'metadata')
% % %     
% % %     if ~exist('I', 'var')
% % %         msgbox('ERROR: you selected a file without image stack "I"')
% % %     end
% % %     
% % %     if exist('metadata', 'var')
% % %         try
% % %             px2um = metadata.px2um;
% % %         catch
% % %             px2um = nan;
% % %         end
% % %         
% % %         try
% % %             frame_step = metadata.frame_step;
% % %         catch
% % %             frame_step = nan;
% % %         end
% % %         
% % %     else
% % %         if ~exist('px2um', 'var')
% % %             px2um = nan;
% % %         end
% % %         
% % %         if ~exist('frame_step', 'var')
% % %             frame_step = nan;
% % %         end
% % %     end
% % %         
% % %     [metadata.SizeX, metadata.SizeY, metadata.nFrames] = size(I);
% % %     metadata.px2um = px2um;
% % %     metadata.frame_step = frame_step;
    
else
    try
        m = msgbox('Importing Video...');
        [I, ~, ~] = Open_BioFormat(fname);
        metadata.px2um = nan;
        metadata.frame_step = nan;
        [metadata.SizeX, metadata.SizeY, metadata.nFrames] = size(I);
    catch e
        msgbox(['ERROR importing file: "' name '"' newline newline ...
            'If you are loading a .mat file previously exported by "Membrane Flucutations" module, use the option "Load Saved Data". '...
             newline newline  'Error message: ' newline e.message ])
    end
end

try
    close(m)
catch
end

I = squeeze(I);
