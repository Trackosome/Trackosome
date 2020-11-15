function update_menu_buttons(menu_state)
% Domingos Leite de Castro, domingos.castro@i3s.up.pt
% Paulo de Castro Aguiar, pauloaguiar@ineb.up.pt

if isempty(menu_state)
    menu_state = get_menu_state();
end

menu_buttons = getappdata(0, 'gui_menu_buttons');
manage_Menu_Buttons(menu_buttons, menu_state)
setappdata(0, 'gui_menu_state', menu_state)
