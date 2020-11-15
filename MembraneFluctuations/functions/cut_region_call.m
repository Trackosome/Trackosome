function [I, frames] = cut_region_call(handles, I, remove_mask)

% Frames selected:
firstFrame = str2double(get(handles.first_frame_remove_region, 'string'));
lastFrame = str2double(get(handles.last_frame_remove_region, 'string'));
frames = firstFrame:lastFrame;

% Create binary masks from masked imgs:
old_masks = I(:,:,frames);
old_masks(old_masks>0) = 1;

% New Masks:
new_masks = old_masks - repmat(remove_mask, [1 1 length(frames)]);
new_masks(new_masks<0) = 0;
I(:,:,frames) = I(:,:,frames) .* new_masks;