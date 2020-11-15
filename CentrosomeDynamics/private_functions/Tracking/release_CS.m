function release_CS(pos, fig)

handles = guidata(fig);
impoint_CS = getappdata(0,'gui_track_impoint_CS');
CS_xy = impoint_CS.CS_xy;
CS_xz = impoint_CS.CS_xz;
CS_yz = impoint_CS.CS_yz;

if pos == getPosition(CS_xy{1}) | pos == getPosition(CS_xz{1}) | pos == getPosition(CS_yz{1})
    CS_dragged = 1;
elseif pos == getPosition(CS_xy{2}) | pos == getPosition(CS_xz{2}) | pos == getPosition(CS_yz{2})
    CS_dragged = 2;
end

f = getappdata(0, 'gui_track_currentFrame');

CS_xy = impoint_CS.CS_xy;
CS_xz = impoint_CS.CS_xz;
CS_yz = impoint_CS.CS_yz;

CS_x_px_temp = getappdata(0, 'gui_track_CS_x_px_temp');
CS_y_px_temp = getappdata(0, 'gui_track_CS_y_px_temp');
CS_z_stack_temp = getappdata(0, 'gui_track_CS_z_stack_temp');
if isempty(CS_z_stack_temp)
    CS_x_px_temp = getappdata(0, 'gui_track_CS_x_px');
    CS_y_px_temp = getappdata(0, 'gui_track_CS_y_px');
    CS_z_stack_temp = getappdata(0, 'gui_track_CS_z_stack');
end


axes_clicked = gca;
if axes_clicked.Position == handles.XY_proj_axes.Position
    CS_x_px_temp(f,CS_dragged) = pos(1);
    CS_y_px_temp(f,CS_dragged) = pos(2);
    
elseif axes_clicked.Position == handles.XZ_proj_axes.Position
    CS_x_px_temp(f,CS_dragged) = pos(1);
    CS_z_stack_temp(f,CS_dragged) = pos(2);
    
elseif axes_clicked.Position == handles.YZ_proj_axes.Position
    CS_y_px_temp(f,CS_dragged) = pos(1);
    CS_z_stack_temp(f,CS_dragged) = pos(2);
else
    disp('STRANGE ERROR IN "my_mouse_up_for_CS" CALLBACK FROM "moving_CS" FUNCTION')
end

delete(CS_xy{CS_dragged})
delete(CS_xz{CS_dragged})
delete(CS_yz{CS_dragged})

setappdata(0, 'gui_track_CS_x_px_temp', CS_x_px_temp);
setappdata(0, 'gui_track_CS_y_px_temp', CS_y_px_temp);
setappdata(0, 'gui_track_CS_z_stack_temp', CS_z_stack_temp);
setappdata(0, 'gui_track_CS_dragged', CS_dragged);
plot_draggable_CS(handles, CS_dragged);


%% Enable Save Button
set(handles.save_CS_coords, 'enable', 'on')

end



