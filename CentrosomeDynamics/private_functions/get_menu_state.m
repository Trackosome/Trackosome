function menu_state = get_menu_state()
% Domingos Leite de Castro, domingos.castro@i3s.up.pt
% Paulo de Castro Aguiar, pauloaguiar@ineb.up.pt

% States: 
%   - 1: Load Data Only
%   - 2: Pre-process data
%   - 3: Track centrosomes
%   - 4: Results

results_available = getappdata(0, 'gui_track_results_available');
Preprocess_vars = getappdata(0, 'gui_Preprocess_vars');
LoadData_state = getappdata(0, 'gui_LoadData_state');


switch true

    case results_available 
    menu_state = 4; % Results are available

    case ~isempty(Preprocess_vars) && Preprocess_vars.state == 2 % Pre-processing finished
    menu_state = 3;

    case LoadData_state == 2
    menu_state = 2; % Data is loaded   
    
    otherwise
    menu_state = 1; % GUI is empty
end

