function [appdata_pos, appdata] = clear_track_data
%% Clear tracking data
% Domingos Leite de Castro, domingos.castro@i3s.up.pt
% Paulo de Castro Aguiar, pauloaguiar@ineb.up.pt

appdata = get(0,'ApplicationData');

fns = fieldnames(appdata);
for ii = 1:numel(fns)
    if strncmp(fns{ii},'gui_track',9)    
         rmappdata(0,fns{ii});
    end
end

appdata_pos = get(0,'ApplicationData'); % make sure it's gone