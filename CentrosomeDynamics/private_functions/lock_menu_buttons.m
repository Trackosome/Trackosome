function lock_menu_buttons()
% Domingos Leite de Castro, domingos.castro@i3s.up.pt
% Paulo de Castro Aguiar, pauloaguiar@ineb.up.pt

menu_buttons = getappdata(0, 'gui_menu_buttons');
try
    set(menu_buttons.load_data_button , 'enable', 'off');
    set(menu_buttons.pre_process_button , 'enable', 'off');
    set(menu_buttons.track_button , 'enable', 'off');
    set(menu_buttons.results_button , 'enable', 'off');
catch
end

