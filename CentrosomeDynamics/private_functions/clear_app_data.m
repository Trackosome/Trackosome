%% Clear all Application Data
% Domingos Leite de Castro, domingos.castro@i3s.up.pt
% Paulo de Castro Aguiar, pauloaguiar@ineb.up.pt

appdata = get(0,'ApplicationData')

fns = fieldnames(appdata);
for ii = 1:numel(fns) 
         rmappdata(0,fns{ii});
end
appdata = get(0,'ApplicationData') %make sure it's gone