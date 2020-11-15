function noRoi = plot_ROIs(handles, CS) 

setappdata(0, 'gui_track_dragging', 0)

noRoi = 0;

ROI_pos = getappdata(0, 'gui_track_ROI_pos');
xi = ROI_pos.xi;
yi = ROI_pos.yi;
zi = ROI_pos.zi;
lx = ROI_pos.lx;
ly = ROI_pos.ly;
lz = ROI_pos.lz;

f = getappdata(0, 'gui_track_currentFrame');
imrect_ROIs = getappdata(0,'gui_track_imrect_ROIs');
roi_ids = getappdata(0, 'gui_track_roi_ids');
metadata = getappdata(0, 'gui_metadata');

if isempty(imrect_ROIs)
    imrect_ROIs.ROI_xy{1} = [];
    imrect_ROIs.ROI_xy{2} = [];
    imrect_ROIs.ROI_xz{1} = [];
    imrect_ROIs.ROI_xz{2} = [];
    imrect_ROIs.ROI_yz{1} = [];
    imrect_ROIs.ROI_yz{2} = [];
    roi_ids.id_xy{1} = [];
    roi_ids.id_xz{1} = [];
    roi_ids.id_yz{1} = [];
    roi_ids.id_xy{2} = [];
    roi_ids.id_xz{2} = [];
    roi_ids.id_yz{2} = [];
end

xLims = [handles.xy_borders, metadata.SizeX - handles.xy_borders];
yLims = [handles.xy_borders, metadata.SizeY - handles.xy_borders];

if lx(f,1) ~= 0
    % ROIs in XY:
    h_xy = imrect(handles.XY_proj_axes, [xi(f,CS), yi(f,CS), lx(f,CS), ly(f,CS)]);
    h_xy.Deletable = false;
    fcn = makeConstrainToRectFcn('imrect',xLims,yLims);
    setPositionConstraintFcn(h_xy,fcn);
    roi_ids.id_xy{CS} = addNewPositionCallback(h_xy, @moving_ROI);
    imrect_ROIs.ROI_xy{CS} = h_xy;
    
    % ROIs in XZ
    h_xz = imrect(handles.XZ_proj_axes, [xi(f,CS), zi(f,CS), lx(f,CS), lz(f,CS)]);
    h_xz.Deletable = false;
    fcn = makeConstrainToRectFcn('imrect',xLims,get(handles.XZ_proj_axes,'YLim'));
    setPositionConstraintFcn(h_xz,fcn);
    roi_ids.id_xz{CS} = addNewPositionCallback(h_xz, @moving_ROI);
    imrect_ROIs.ROI_xz{CS} = h_xz;
    
    % ROIs in YZ
    h_yz = imrect(handles.YZ_proj_axes, [yi(f,CS), zi(f,CS), ly(f,CS), lz(f,CS)]);
    h_yz.Deletable = false;
    fcn = makeConstrainToRectFcn('imrect',yLims,get(handles.YZ_proj_axes,'YLim'));
    setPositionConstraintFcn(h_yz,fcn);
    roi_ids.id_yz{CS} = addNewPositionCallback(h_yz, @moving_ROI);
    imrect_ROIs.ROI_yz{CS} = h_yz;
        
% Set color of ROIs
    if CS == 1
       setColor(h_xy, [1 0  0])
       setColor(h_xz, [1 0  0])
       setColor(h_yz, [1 0  0])
    else
       setColor(h_xy, [0 0  1])
       setColor(h_xz, [0 0  1])
       setColor(h_yz, [0 0  1])
    end
    
    setappdata(0, 'gui_track_roi_ids', roi_ids);
    setappdata(0,'gui_track_imrect_ROIs', imrect_ROIs);
    
else
    noRoi = 1;
end