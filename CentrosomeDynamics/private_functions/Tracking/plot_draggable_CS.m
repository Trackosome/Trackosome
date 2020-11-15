function noCS = plot_draggable_CS(handles, CS)

%% Load data:
noCS = 0;
CS_x_px = getappdata(0, 'gui_track_CS_x_px_temp');
CS_y_px = getappdata(0, 'gui_track_CS_y_px_temp');
CS_z_stack = getappdata(0, 'gui_track_CS_z_stack_temp');
f = getappdata(0, 'gui_track_currentFrame');
metadata = getappdata(0, 'gui_metadata');
impoint_CS = getappdata(0, 'gui_track_impoint_CS');

%% Initialize variables:
if isempty(CS_z_stack)
    CS_x_px = getappdata(0, 'gui_track_CS_x_px');
    CS_y_px = getappdata(0, 'gui_track_CS_y_px');
    CS_z_stack = getappdata(0, 'gui_track_CS_z_stack');
end

if isempty(impoint_CS)
    impoint_CS.CS_xy{1} = [];
    impoint_CS.CS_yz{1} = [];
    impoint_CS.CS_yz{1} = [];
    impoint_CS.CS_xy{2} = [];
    impoint_CS.CS_yz{2} = [];
    impoint_CS.CS_yz{2} = [];
end

xLims = [handles.xy_borders, metadata.SizeX - handles.xy_borders];
yLims = [handles.xy_borders, metadata.SizeY - handles.xy_borders];

%% Plot impoints:

if CS_x_px(f,1) ~= 0
    
    set(handles.XY_proj_axes,'SortMethod', 'childorder');
    set(handles.XZ_proj_axes,'SortMethod', 'childorder');
    set(handles.YZ_proj_axes,'SortMethod', 'childorder');
    
    % CS in XY:
    CS_xy = my_impoint(handles.XY_proj_axes, [CS_x_px(f,CS), CS_y_px(f,CS)]);
    CS_xy.Deletable = false;
    fcn = makeConstrainToRectFcn('impoint',xLims,yLims);
    setPositionConstraintFcn(CS_xy,fcn);
    impoint_CS.CS_xy{CS} = CS_xy;
    
    % CS in XZ:
    CS_xz = my_impoint(handles.XZ_proj_axes, [CS_x_px(f,CS), CS_z_stack(f,CS)]);
    CS_xz.Deletable = false;
    fcn = makeConstrainToRectFcn('impoint',xLims,get(handles.YZ_proj_axes,'YLim'));
    setPositionConstraintFcn(CS_xz,fcn);
    impoint_CS.CS_xz{CS} = CS_xz;
    
    % CS in YZ:
    CS_yz = my_impoint(handles.YZ_proj_axes, [CS_y_px(f,CS), CS_z_stack(f,CS)]);
    CS_yz.Deletable = false;
    fcn = makeConstrainToRectFcn('impoint',yLims,get(handles.YZ_proj_axes,'YLim'));
    setPositionConstraintFcn(CS_yz,fcn);
    impoint_CS.CS_yz{CS} = CS_yz;
    
    
    % Set color of Points
    if CS == 1
        setColor(CS_xy, [1 0  0])
        setColor(CS_xz, [1 0  0])
        setColor(CS_yz, [1 0  0])
    else
        setColor(CS_xy, [0 0  1])
        setColor(CS_xz, [0 0  1])
        setColor(CS_yz, [0 0  1])
    end
   
    setappdata(0,'gui_track_impoint_CS', impoint_CS);
        
else
    noCS = 1;
end