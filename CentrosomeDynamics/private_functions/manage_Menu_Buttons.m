function manage_Menu_Buttons(menu_buttons, state)
% Domingos Leite de Castro, domingos.castro@i3s.up.pt
% Paulo de Castro Aguiar, pauloaguiar@ineb.up.pt

% States: 
%   - 1: Load Data Only
%   - 2: Pre-process data
%   - 3: Track centrosomes
%   - 4: Results

%% Enable/disable buttons:
try
    if state == 1
        
        set(menu_buttons.load_data_button, 'enable', 'on')
        set(menu_buttons.pre_process_button, 'enable', 'off')
        set(menu_buttons.track_button, 'enable', 'off')
        set(menu_buttons.results_button, 'enable', 'off')
        
    elseif state == 2
        
        set(menu_buttons.load_data_button, 'enable', 'on')
        set(menu_buttons.pre_process_button, 'enable', 'on')
        set(menu_buttons.track_button, 'enable', 'off')
        set(menu_buttons.results_button, 'enable', 'off')
        
    elseif state == 3
        
        set(menu_buttons.load_data_button, 'enable', 'on')
        set(menu_buttons.pre_process_button, 'enable', 'on')
        set(menu_buttons.track_button, 'enable', 'on')
        set(menu_buttons.results_button, 'enable', 'off')
        
    elseif state == 4
        
        set(menu_buttons.load_data_button, 'enable', 'on')
        set(menu_buttons.pre_process_button, 'enable', 'on')
        set(menu_buttons.track_button, 'enable', 'on')
        set(menu_buttons.results_button, 'enable', 'on')
        
    end
catch
end



