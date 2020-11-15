function update_frame_button(hObject,frame_state_buttons, current_frame, frame_states, activatedFrames)
%% Update Frame Button hObjects
% Domingos Leite de Castro, domingos.castro@i3s.up.pt
% Paulo de Castro Aguiar, pauloaguiar@ineb.up.pt

previousFrame = getappdata(0, 'gui_track_currentFrame'); % current frame was not updated yet

previous_button_tag = ['button_' num2str(previousFrame)];
previous_button = findobj('Tag', previous_button_tag);
set(previous_button, 'FontWeight', 'normal')
set(previous_button, 'FontSize', 6)
update_button_color(frame_state_buttons, previousFrame, frame_states, activatedFrames, false)

set(hObject, 'FontWeight', 'bold')
set(hObject, 'FontSize', 8)

% Update color of current frame button
update_button_color(frame_state_buttons, current_frame, frame_states, activatedFrames,  true)