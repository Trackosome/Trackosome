function clear_all_data

appdata = get(0,'ApplicationData')

fns = fieldnames(appdata);
for ii = 1:numel(fns)  
         rmappdata(0,fns{ii});
end

appdata = get(0,'ApplicationData') %make sure it's gone