function update_button_color(frame_state_buttons, frames, frame_states, activatedFrames, darker)
%% Update color from Frame Buttons
% Domingos Leite de Castro, domingos.castro@i3s.up.pt
% Paulo de Castro Aguiar, pauloaguiar@ineb.up.pt

%% state colors:
%               1 - empty   - white : [1 1 1]
%               2 - good    - gui_color_1 (blue)
%               3 - warning - yellow: [1 1 0]
%               4 - manual  - grey  : [0.8 0.8 0.8]
%               5 - error   - red   : [1 0 0]

state_colors{1} = [1 1 1];
state_colors{2} = getappdata(0, 'gui_color_1');
state_colors{3} = [1 1 0];
state_colors{4} = [0.5 0.5 0.5];
state_colors{5} = [1 0 0];


if isempty(activatedFrames )
    activatedFrames = ones(length(frame_states), 1);
end
    
if isempty(frames)
    frames = 1:length(frame_state_buttons);
end

for i = frames    
    state = frame_states(i);
    
    if darker
        brightness = 0.75;
    else
        brightness = 1;
    end
    
    if activatedFrames(i) == 0
        set(frame_state_buttons(i), 'backgroundcolor', [1 1 1]*brightness)
    else    
        set(frame_state_buttons(i), 'backgroundcolor', state_colors{state}*brightness)
    end    
end