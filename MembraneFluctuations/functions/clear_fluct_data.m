function clear_fluct_data

appdata = get(0,'ApplicationData');

fns = fieldnames(appdata);
for ii = 1:numel(fns)
    if strncmp(fns{ii},'gui_fluct', 9)    
         rmappdata(0,fns{ii});
    end
end

appdata = get(0,'ApplicationData'); %make sure it's gone