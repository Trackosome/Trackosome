function metadata = metadataInput(metadata)

if isempty(metadata)
    % Load Parameters:
    metadata = getappdata(0, 'gui_fluct_metadata');
end

frame_step = metadata.frame_step;
px2um = metadata.px2um;

% Get user input regarding image sequence:
prompt   = {'frame step [s]', 'px2um [\mum/px]'};
name     = 'Check parameters';
numlines = [1, 30];


defaultanswer   = { num2str(metadata.frame_step), num2str(metadata.px2um)};
options.Interpreter = 'tex';
answer          = inputdlg( prompt, name, numlines, defaultanswer, options );

try
    frame_step = str2double( answer{1} );
    px2um = str2double( answer{2} );
catch
end

metadata.px2um = px2um;
metadata.frame_step = frame_step;

setappdata(0, 'gui_fluct_metadata', metadata)