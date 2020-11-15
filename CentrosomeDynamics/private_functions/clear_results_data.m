function clear_results_data
%% Clear data from "Results" Gui
% Domingos Leite de Castro, domingos.castro@i3s.up.pt
% Paulo de Castro Aguiar, pauloaguiar@ineb.up.pt

appdata = get(0,'ApplicationData');

fns = fieldnames(appdata);
for ii = 1:numel(fns)
    if strncmp(fns{ii},'gui_results',9)    
         rmappdata(0,fns{ii});
    end
end

appdata = get(0,'ApplicationData'); % make sure it's gone