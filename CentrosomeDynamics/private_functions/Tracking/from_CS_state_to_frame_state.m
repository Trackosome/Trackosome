
function tracking_state = from_CS_state_to_frame_state(f, tracking_state)
%% frames/centrosomes states:
%               1 - empty 
%               2 - good   
%               3 - warning 
%               4 - manual 
%               5 - error

if tracking_state.CS_states(f,1) == 1 & tracking_state.CS_states(f,2) == 1 
    % if one centrosomes is empty, frame is empty
    tracking_state.frame_states(f) = 1;
    
elseif tracking_state.CS_states(f,1) == 2 & tracking_state.CS_states(f,2) == 2 
    % if both centrosomes are good, frame is good
    tracking_state.frame_states(f) = 2;
    
elseif tracking_state.CS_states(f,1) == 4 | tracking_state.CS_states(f,2) == 4
    % if one centrosomes is manual, frame is manual
    tracking_state.frame_states(f) = 4;

elseif tracking_state.CS_states(f,1) == 5 | tracking_state.CS_states(f,2) == 5
    % if one centrosomes has error, frame has error
    tracking_state.frame_states(f) = 5;
    
elseif tracking_state.CS_states(f,1) == 3 | tracking_state.CS_states(f,2) == 3
    % if one centrosomes has warning, frame has warning
    tracking_state.frame_states(f) = 3;
end    
    