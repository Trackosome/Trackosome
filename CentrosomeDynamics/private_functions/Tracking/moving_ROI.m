function moving_ROI(pos)

imrect_ROIs = getappdata(0,'gui_track_imrect_ROIs');
ROI_xy = imrect_ROIs.ROI_xy;
ROI_xz = imrect_ROIs.ROI_xz;
ROI_yz = imrect_ROIs.ROI_yz;

if pos == getPosition(ROI_xy{1}) | pos == getPosition(ROI_xz{1}) | pos == getPosition(ROI_yz{1})
    CS_dragged = 1;
    setappdata(0, 'gui_track_CS_dragged', CS_dragged);
elseif pos == getPosition(ROI_xy{2}) | pos == getPosition(ROI_xz{2}) | pos == getPosition(ROI_yz{2})
    CS_dragged = 2;
    setappdata(0, 'gui_track_CS_dragged', CS_dragged);
end


if ~getappdata(0, 'gui_track_dragging') % save original position of ROIs 
    
    ROI_pos = getappdata(0, 'gui_track_ROI_pos');
    ROI_pos_orig = getappdata(0, 'gui_track_ROI_pos_orig');
        
    if isempty(ROI_pos_orig)
        ROI_pos_orig = ROI_pos;
    end
    
    ROI_pos_orig.xi(:,CS_dragged) = ROI_pos.xi(:,CS_dragged);
    ROI_pos_orig.yi(:,CS_dragged) = ROI_pos.yi(:,CS_dragged);
    ROI_pos_orig.zi(:,CS_dragged) = ROI_pos.zi(:,CS_dragged);
    ROI_pos_orig.lx(:,CS_dragged) = ROI_pos.lx(:,CS_dragged);
    ROI_pos_orig.ly(:,CS_dragged) = ROI_pos.ly(:,CS_dragged);
    ROI_pos_orig.lz(:,CS_dragged) = ROI_pos.lz(:,CS_dragged);
    
    setappdata(0, 'gui_track_ROI_pos_orig', ROI_pos_orig)
    
end

set(gcf,'WindowButtonUpFcn',{@my_mouse_up, pos});
setappdata(0, 'gui_track_dragging', 1)

end



function my_mouse_up(hObject,~, pos)

if getappdata(0, 'gui_track_dragging')
    
    setappdata(0, 'gui_track_dragging', 0)
    handles = guidata( ancestor(hObject, 'figure') );
    f = getappdata(0, 'gui_track_currentFrame');
    imrect_ROIs = getappdata(0,'gui_track_imrect_ROIs');
    CS_dragged = getappdata(0, 'gui_track_CS_dragged');
    roi_ids = getappdata(0, 'gui_track_roi_ids');
    
    ROI_xy = imrect_ROIs.ROI_xy;
    ROI_xz = imrect_ROIs.ROI_xz;
    ROI_yz = imrect_ROIs.ROI_yz;
    id_xy = roi_ids.id_xy;
    id_xz = roi_ids.id_xz;
    id_yz = roi_ids.id_yz;
    
    removeNewPositionCallback(ROI_xy{CS_dragged},id_xy{CS_dragged});
    removeNewPositionCallback(ROI_xz{CS_dragged},id_xz{CS_dragged});
    removeNewPositionCallback(ROI_yz{CS_dragged},id_yz{CS_dragged});
    
    
    ROI_pos = getappdata(0, 'gui_track_ROI_pos');


    axes_clicked = gca;
    if axes_clicked.Position == handles.XY_proj_axes.Position
        ROI_pos.xi(f,CS_dragged) = pos(1);
        ROI_pos.yi(f,CS_dragged) = pos(2);
        ROI_pos.lx(f,CS_dragged) = pos(3);
        ROI_pos.ly(f,CS_dragged) = pos(4);
        
    elseif axes_clicked.Position == handles.XZ_proj_axes.Position
        ROI_pos.xi(f,CS_dragged) = pos(1);
        ROI_pos.zi(f,CS_dragged) = pos(2);
        ROI_pos.lx(f,CS_dragged) = pos(3);
        ROI_pos.lz(f,CS_dragged) = pos(4);
        
    elseif axes_clicked.Position == handles.YZ_proj_axes.Position
        ROI_pos.yi(f,CS_dragged) = pos(1);
        ROI_pos.zi(f,CS_dragged) = pos(2);
        ROI_pos.ly(f,CS_dragged) = pos(3);
        ROI_pos.lz(f,CS_dragged) = pos(4);
    else
        disp('STRANGE ERROR IN "my_mouse_up" CALLBACK FROM "moving_h1" FUNCTION')
    end
    
    delete(ROI_xy{CS_dragged})
    delete(ROI_xz{CS_dragged})
    delete(ROI_yz{CS_dragged})
    roi_ids.id_xy{CS_dragged} = [];
    roi_ids.id_xz{CS_dragged} = [];
    roi_ids.id_yz{CS_dragged} = [];
    
    setappdata(0, 'gui_track_roi_ids',roi_ids)    
    setappdata(0, 'gui_track_ROI_pos', ROI_pos)    
    plot_ROIs(handles, CS_dragged);
end
end


