function frame_state_buttons = generate_frame_buttons(handles, nFrames, click_frame_button)
%% Generate frame buttons for GUI
% Domingos Leite de Castro, domingos.castro@i3s.up.pt
% Paulo de Castro Aguiar, pauloaguiar@ineb.up.pt

% Define Positions:
panel_pos = get(handles.frame_panel, 'Position');
pos_initial = get(handles.left_button, 'Position');
x_first = panel_pos(1) + panel_pos(3)*pos_initial(1) + pos_initial(3)*panel_pos(3);
y_first = panel_pos(2) + panel_pos(4)*pos_initial(2);
heigth = panel_pos(4) * pos_initial(4);
pos_final = get(handles.right_button, 'Position');
x_last = panel_pos(1) + panel_pos(3)*pos_final(1);

% Create Buttons:
for f = 1 : nFrames
  width = (x_last - x_first)/nFrames;
  xpos = x_first + width*(f - 1);
  
  button_tag = ['button_' num2str(f)];
  delete(findobj('Tag', button_tag));  
  
  frame_state_buttons(f) = uicontrol(handles.figure1, 'tag', button_tag, 'Style', 'pushbutton',  ...
      'Units', 'normalized','Position', [xpos y_first width heigth], 'Callback', {click_frame_button, handles, f});
  if nFrames < 50
       set(frame_state_buttons(f),'String', f,'Fontsize', 6)
  end  
end
