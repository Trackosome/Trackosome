function draw_region_button_call(image_axes)

I = getappdata(0, 'gui_fluct_I');
remove_mask = getappdata(0, 'gui_fluct_results_remove_mask');

if isempty(remove_mask)
    remove_mask = zeros([size(I,1),size(I,2)]);
end

[remove_mask, region_obj] = from_freehand_to_filled_mask(remove_mask, image_axes);

setappdata(0, 'gui_fluct_remove_mask', remove_mask)
setappdata(0, 'gui_fluct_results_region_obj', region_obj)