function varargout = GUI_Tracking_Results(varargin)
% Domingos Leite de Castro, domingos.castro@i3s.up.pt
% Paulo de Castro Aguiar, pauloaguiar@ineb.up.pt

% GUI_TRACKING_RESULTS MATLAB code for GUI_Tracking_Results.fig
%      GUI_TRACKING_RESULTS, by itself, creates a new GUI_TRACKING_RESULTS or raises the existing
%      singleton*.
%
%      H = GUI_TRACKING_RESULTS returns the handle to a new GUI_TRACKING_RESULTS or the handle to
%      the existing singleton*.
%
%      GUI_TRACKING_RESULTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_TRACKING_RESULTS.M with the given input arguments.
%
%      GUI_TRACKING_RESULTS('Property','Value',...) creates a new GUI_TRACKING_RESULTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_Tracking_Results_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_Tracking_Results_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_Tracking_Results

% Last Modified by GUIDE v2.5 08-Oct-2020 12:15:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_Tracking_Results_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_Tracking_Results_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GUI_Tracking_Results is made visible.
function GUI_Tracking_Results_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_Tracking_Results (see VARARGIN)

% Choose default command line output for GUI_Tracking_Results
handles.output = hObject;

set(handles.figure1, 'Name', 'Results'); %, 'CloseRequestFcn',@my_closereq);

current_window = getappdata(0, 'gui_current_window');
if current_window ~= 4
    handles = initialize_GUI(handles);
end
setappdata(0, 'gui_current_window', 4)

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_Tracking_Results wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function handles = initialize_GUI(handles)

%% struct with all buttons:
handles.all_buttons = [handles.center_button, handles.fig_CS_traj, handles.fig_reconstruction, handles.fig_axis_3D, handles.fig_CS_dist, ...
    handles.fig_CS_angles, handles.fig_axis_angles, handles.back_button, handles.save_button, handles.CS_show_button, ...
    handles.NM_show_button, handles.CM_show_button, handles.right_button, handles.left_button, handles.menu_button];


%% Load Data:
CS_x_px = getappdata(0, 'gui_track_CS_x_px');
CS_y_px = getappdata(0, 'gui_track_CS_y_px');
CS_z_stack = getappdata(0, 'gui_track_CS_z_stack');
metadata = getappdata(0, 'gui_metadata');
Img_NM = getappdata(0, 'gui_Img_NM');
Img_CM = getappdata(0, 'gui_Img_CM');
NM_vars = getappdata(0, 'gui_results_NM_vars');
CM_vars = getappdata(0, 'gui_results_CM_vars');
CS_angles = getappdata(0, 'gui_results_CS_angles');
activatedFrames = getappdata(0, 'gui_track_activatedFrames');
first_activated_frame = getappdata(0, 'gui_track_first_activated_frame');
last_activated_frame = getappdata(0, 'gui_track_last_activated_frame');

blue_color = getappdata(0, 'gui_color_3');
green_color = getappdata(0, 'gui_color_4');
red_color = getappdata(0, 'gui_color_6');

%% Generate Frame Buttons
if isempty(activatedFrames)
    activatedFrames = ones(metadata.nFrames, 1);
    first_activated_frame = 1;
    last_activated_frame = metadata.nFrames;
end

tracking_state = getappdata(0, 'gui_track_tracking_state');
frame_state_buttons = generate_frame_buttons(handles, metadata.nFrames, @click_frame_button);
update_button_color(frame_state_buttons, [],tracking_state.frame_states, activatedFrames, false);
setappdata(0, 'gui_results_frame_state_buttons', frame_state_buttons)


%% Calculate Results:
t = (0:metadata.nFrames-1) * metadata.frame_step;

frames_to_keep = activatedFrames;
frames_to_keep(frames_to_keep == 0) = nan;

% Membrane Segmentation
if isempty(NM_vars) || (~isempty(Img_CM) && isempty(CM_vars.metrics.pca))
    thresh_level = getappdata(0, 'gui_results_thresh_level');
    if isempty(thresh_level)
        thresh_level = 1;
    end
                
    to_filt = 1;
    [Img_NM_filt, NM_vars.memb_BW,  Img_CM_filt, CM_vars.memb_BW] = ...
        NM_CM_reconstruction(Img_NM, Img_CM, metadata.px2um, [], to_filt);
    
    setappdata(0, 'gui_Img_NM', Img_NM_filt);
    setappdata(0, 'gui_Img_CM', Img_CM_filt);
    to_calc_metrics = 1;
else
    to_calc_metrics = getappdata(0, 'Img_results_to_calc_metrics');
end   
   
% Calculate Membrane Metrics:
if to_calc_metrics
        NM_vars.metrics = calc_membrane_metrics(NM_vars.memb_BW, metadata);
        CM_vars.metrics = calc_membrane_metrics(CM_vars.memb_BW, metadata);
end

% Raw CS trajectories
[CS_coords_um, CS_dist] = calc_trajectories(CS_x_px, CS_y_px, CS_z_stack, frames_to_keep, metadata);
 
% CS trajectories normalized to NM centroid position
CS_coords_um_centered = normalize_CS_coords_with_Median_NM(CS_coords_um, NM_vars.metrics.centroid);
   
[NM_vars.CS_NM_axis_ang_degrees, CM_vars.CS_CM_axis_ang_degrees, CM_vars.NM_CM_axis_ang_degrees] = ...
    calc_orientation_axis(NM_vars.metrics.pca, CM_vars.metrics.pca, metadata.nFrames, CS_coords_um, frames_to_keep);
CS_angles = angles_between_CS(CS_coords_um.x, CS_coords_um.y, CS_coords_um.z, NM_vars.metrics.centroid, frames_to_keep, false);


%% Plot Results: 
LoadData_vars = getappdata(0, 'gui_LoadData_vars');
imgs_to_show = [LoadData_vars.with_CS LoadData_vars.with_NM LoadData_vars.with_CM];
setappdata(0, 'gui_results_imgs_to_show', imgs_to_show) % [show CS, show NM, show CM]

[NM_memb_BW, CM_memb_BW, centroid, CS_coords_um_f] = defineReconstInputs(imgs_to_show, CS_coords_um, NM_vars, CM_vars, 1);

visualize_reconstruction(handles.reconstruction_axes, NM_memb_BW, CM_memb_BW,...
    centroid, CS_coords_um_f.x, CS_coords_um_f.y, CS_coords_um_f.z, metadata, tracking_state.CS_states(1,:))


plot_trajectories(handles.CS_traj_axes, CS_coords_um, tracking_state.CS_states, metadata);
plot_curve(handles.CS_dists_axes, CS_dist, t, tracking_state.frame_states, 'Time [sec]',  'Distance [um]', blue_color);
plot_curve(handles.CS_angles_axes, CS_angles, t, tracking_state.frame_states, 'Time [sec]', 'Angle [degrees]', blue_color);
obj = plot_curve(handles.axis_angles_axes, NM_vars.CS_NM_axis_ang_degrees, t, tracking_state.frame_states, 'Time [sec]', 'Angle [degrees]', blue_color);


if isempty(CM_vars.CS_CM_axis_ang_degrees)
    set(handles.title_axis_angles, 'string', 'Angle between Nucleus major axis and Centrosomes')
else
    red_color = getappdata(0, 'gui_color_6');
    obj2 = plot_curve(gca, CM_vars.CS_CM_axis_ang_degrees, t, tracking_state.frame_states, 'Time [sec]', 'Angle [degrees]', green_color);
    obj3 = plot_curve(gca, CM_vars.NM_CM_axis_ang_degrees, t, tracking_state.frame_states, 'Time [sec]', 'Angle [degrees]', red_color);
    legend([obj3 obj2 obj], {'Nuclear/Cell Memb', 'Centrosomes/Cell Memb' 'Centrosomes/Nuclear Memb' }, 'Location', 'best', 'AutoUpdate','off')
    set(handles.title_axis_angles, 'string', 'Angle between Nucleus/Cell major axis and Centrosomes')
end
plot_CS_NM_CM_orientation_axis(handles.orientations_axes, metadata.nFrames, NM_vars.metrics.pca, CM_vars.metrics.pca, CS_coords_um)

%% Set Application Data:

setappdata(0, 'gui_track_currentFrame', 1)
setappdata(0, 'gui_results_NM_vars', NM_vars);
setappdata(0, 'gui_results_CM_vars', CM_vars);
setappdata(0, 'gui_results_CS_dist', CS_dist);
setappdata(0, 'gui_results_CS_angles', CS_angles);
setappdata(0, 'gui_results_CS_coords_um', CS_coords_um)
setappdata(0, 'gui_results_CS_coords_um_centered', CS_coords_um_centered)
setappdata(0, 'gui_track_activatedFrames', activatedFrames)
setappdata(0, 'gui_track_first_activated_frame', first_activated_frame)
setappdata(0, 'gui_track_last_activated_frame', last_activated_frame)
setappdata(0, 'gui_results_remove_frames_state', 0)
setappdata(0, 'gui_results_traj_plot_mode', 1)

try
close(m)   
catch
end

handles.all_buttons = [handles.all_buttons frame_state_buttons];


function [CS_coords_um, CS_dist] = calc_trajectories(CS_x_px, CS_y_px, CS_z_stack, frames_to_keep, metadata)

px2um = metadata.px2um;
z_step = metadata.z_step;

%% Trajectories:
% Convert to um:
CS_x_um = CS_x_px * px2um .* frames_to_keep;
CS_y_um = CS_y_px * px2um .* frames_to_keep;
CS_z_um = CS_z_stack * z_step .* frames_to_keep;

CS_coords_um.x = CS_x_um;
CS_coords_um.y = CS_y_um;
CS_coords_um.z = CS_z_um;

%% Distances between centrosomes:
CS_dist = sqrt(   (CS_x_um(:,1) - CS_x_um(:,2)).^2 + ...
    (CS_y_um(:,1) - CS_y_um(:,2)).^2 + (CS_z_um(:,1) - CS_z_um(:,2)).^2 )  .* frames_to_keep;


function plot_trajectories(CS_traj_axes, CS_coords_um, CS_states, metadata)

nFrames = metadata.nFrames; 
offset = 3;

Xmin = round( min( CS_coords_um.x(:) ) ) - offset;
Xmax = round( max( CS_coords_um.x(:) ) ) + offset;
Ymin = round( min( CS_coords_um.y(:) ) ) - offset;
Ymax = round( max( CS_coords_um.y(:) ) ) + offset;
Zmax = round( max( CS_coords_um.z(:) ) ) + offset;

%% Plot Trajectories
axes(CS_traj_axes)
blue = getappdata(0, 'gui_color_3');
red = getappdata(0, 'gui_color_6');
hold on

plot3( CS_coords_um.x(1:nFrames,1), CS_coords_um.y(1:nFrames,1), CS_coords_um.z(1:nFrames,1), 'color', red, 'LineWidth', 1);
plot3( CS_coords_um.x(1:nFrames,2), CS_coords_um.y(1:nFrames,2), CS_coords_um.z(1:nFrames,2), 'color', blue, 'LineWidth', 1);

%% Plot Points:
goodFrames = CS_states == 2; 
warningFrames = CS_states == 3;
manualFrames = CS_states == 4;
plot3( CS_coords_um.x(goodFrames(:,1),1), CS_coords_um.y(goodFrames(:,1),1), CS_coords_um.z(goodFrames(:,1),1), '.', 'color', red, 'markersize', 5);
plot3( CS_coords_um.x(goodFrames(:,2),2), CS_coords_um.y(goodFrames(:,2),2), CS_coords_um.z(goodFrames(:,2),2), '.', 'color', blue, 'markersize', 5);
plot3( CS_coords_um.x(warningFrames(:,1),1), CS_coords_um.y(warningFrames(:,1),1), CS_coords_um.z(warningFrames(:,1),1), 'y.', 'markersize', 7);
plot3( CS_coords_um.x(warningFrames(:,2),2), CS_coords_um.y(warningFrames(:,2),2), CS_coords_um.z(warningFrames(:,2),2), 'y.', 'markersize', 7);
plot3( CS_coords_um.x(warningFrames(:,1),1), CS_coords_um.y(warningFrames(:,1),1), CS_coords_um.z(warningFrames(:,1),1), 'ko', 'markersize', 3);
plot3( CS_coords_um.x(warningFrames(:,2),2), CS_coords_um.y(warningFrames(:,2),2), CS_coords_um.z(warningFrames(:,2),2), 'ko', 'markersize', 3);
plot3( CS_coords_um.x(manualFrames(:,1),1), CS_coords_um.y(manualFrames(:,1),1), CS_coords_um.z(manualFrames(:,1),1), '.', 'color', [0.5 0.5 0.5], 'markersize', 7);
plot3( CS_coords_um.x(manualFrames(:,2),2), CS_coords_um.y(manualFrames(:,2),2), CS_coords_um.z(manualFrames(:,2),2), '.', 'color', [0.5 0.5 0.5], 'markersize', 7);
plot3( CS_coords_um.x(manualFrames(:,1),1), CS_coords_um.y(manualFrames(:,1),1), CS_coords_um.z(manualFrames(:,1),1), 'ko', 'markersize', 3);
plot3( CS_coords_um.x(manualFrames(:,2),2), CS_coords_um.y(manualFrames(:,2),2), CS_coords_um.z(manualFrames(:,2),2), 'ko', 'markersize', 3);

axis auto equal
xlabel('position in x [um]', 'FontSize', 8);
ylabel('position in y [um]', 'FontSize', 8);
zlabel('position in z [um]', 'FontSize', 8);
grid on
hold off


function obj = plot_curve(h_axes, y, t, frame_states, xlabel_txt, ylabel_txt, color)

axes(h_axes)
hold on
obj = plot(t,y, 'color', color, 'linewidth', 1.3);

warningFrames = frame_states == 3;
manualFrames = frame_states == 4;

plot( t, y, '.', 'color', color,  'markersize', 8);
plot( t(warningFrames), y(warningFrames), 'y.', 'markersize', 8);
plot( t(warningFrames), y(warningFrames), 'ko', 'markersize', 3);
plot( t(manualFrames),  y(manualFrames), '.', 'color', [0.5 0.5 0.5], 'markersize', 8);
plot( t(manualFrames),  y(manualFrames), 'ko', 'markersize', 3);

xlabel( xlabel_txt, 'FontSize', 8); 
ylabel( ylabel_txt, 'FontSize', 8);
xlim([0 t(end)])


    
function [CS_NM_axis_ang_degrees, CS_CM_axis_ang_degrees, NM_CM_axis_ang_degrees] = calc_orientation_axis(NM_pca, CM_pca, nFrames, CS_coords_um, frames_to_keep)

CS_x_um = CS_coords_um.x;
CS_y_um = CS_coords_um.y;
CS_z_um = CS_coords_um.z;

% centrosomes
CS_axis = [ CS_x_um(:,1) - CS_x_um(:,2), CS_y_um(:,1) - CS_y_um(:,2), CS_z_um(:,1) - CS_z_um(:,2) ]';
n = sqrt( sum( CS_axis.^2, 1) );
CS_axis = CS_axis ./ repmat(n,3,1);

%% CALCULATE ANGLE BETWEEN CS AXIS AND NUCLEUS MAIN AXIS
CS_NM_axis_ang_degrees = zeros(1,nFrames);

if ~isempty(CM_pca)
    CS_CM_axis_ang_degrees = zeros(1,nFrames);
    NM_CM_axis_ang_degrees = zeros(1,nFrames);
else
    CS_CM_axis_ang_degrees = [];   
    NM_CM_axis_ang_degrees = [];
end

for f = 1:nFrames 
    % angle between Centrosome axis Nucleus Mebrane:
    u_NM = NM_pca(:,1,f);        
    v = CS_axis(:,f);       
    CS_NM_axis_ang_degrees(f) = acos( -u_NM'*v ) * 180.0 / pi .* frames_to_keep(f);
    
    if CS_NM_axis_ang_degrees(f) > 90
       CS_NM_axis_ang_degrees(f) = acos( u_NM'*v ) * 180.0 / pi .* frames_to_keep(f);
    end
         
    if ~isempty(CM_pca)        
        u_CM = CM_pca(:,1,f);
        
        % angle between Centrosome axis Cell Mebrane:   
        CS_CM_axis_ang_degrees(f) = acos( u_CM'*v ) * 180.0 / pi .* frames_to_keep(f);
        if CS_CM_axis_ang_degrees(f) > 90
            CS_CM_axis_ang_degrees(f) = acos( -u_CM'*v ) * 180.0 / pi .* frames_to_keep(f);
        end
        
        % angle between Nucleus Membrane and Cell Mebrane:   
        NM_CM_axis_ang_degrees(f) = acos( u_CM'*u_NM ) * 180.0 / pi .* frames_to_keep(f);
        if NM_CM_axis_ang_degrees(f) > 90
            NM_CM_axis_ang_degrees(f) = acos( -u_CM'*u_NM ) * 180.0 / pi .* frames_to_keep(f);
        end
        
    end   

end


function plot_CS_NM_CM_orientation_axis(orientations_axes, nFrames, NM_pca, CM_pca, CS_coords_um)

blue = getappdata(0, 'gui_color_3');
green = getappdata(0, 'gui_color_4');
yellow = getappdata(0, 'gui_color_5');

CS_x_um = CS_coords_um.x;
CS_y_um = CS_coords_um.y;
CS_z_um = CS_coords_um.z;

CS_axis = [ CS_x_um(:,1) - CS_x_um(:,2), CS_y_um(:,1) - CS_y_um(:,2), CS_z_um(:,1) - CS_z_um(:,2) ]';
n = sqrt( sum( CS_axis.^2, 1) );
CS_axis = CS_axis ./ repmat(n,3,1);

axes(orientations_axes)
hold on

z = [1:nFrames]*0.2;

% Centrosomes Axis:
quiver3(zeros(1,nFrames),zeros(1,nFrames),z, 0.5*CS_axis(1,:), 0.5*CS_axis(2,:), 0.5*CS_axis(3,:), 'color', blue, 'autoscale', 'off', 'MaxHeadSize', 0.02, 'LineWidth', 1.2)

% Nuclear Membrane Axis:
u1 = squeeze(NM_pca(:,1, :) .* NM_pca(1,4, :));
u2 = squeeze(NM_pca(:,2, :) .* NM_pca(2,4, :));

quiver3(zeros(1,nFrames),zeros(1,nFrames),z, u1(1,:), u1(2,:), u1(3,:), ...
    'color', yellow, 'autoscale', 'off', 'MaxHeadSize', 0.02, 'LineWidth', 1.2)
quiver3(zeros(1,nFrames),zeros(1,nFrames),z, u2(1,:), u2(2,:), u2(3,:), ...
    'color', yellow, 'autoscale', 'off', 'MaxHeadSize', 0.02, 'LineWidth', 1.2)

l(1) = plot(nan, nan, 'linewidth', 2, 'color', blue);
l(2) = plot(nan, nan, 'linewidth', 2, 'color', yellow);

% Cell Membrane axis
if ~isempty(CM_pca)
    v1 = CM_pca(:,1,:) .* CM_pca(1,4,:);
    v2 = CM_pca(:,2,:) .* CM_pca(2,4,:);
    quiver3(zeros(1,nFrames),zeros(1,nFrames),z, v1(1,:), v1(2,:), v1(3,:), ...
        'color', green, 'autoscale', 'off', 'MaxHeadSize', 0.02, 'LineWidth', 1.2)
    quiver3(zeros(1,nFrames),zeros(1,nFrames),z, v2(1,:), v2(2,:), v2(3,:), ...
        'color', green, 'autoscale', 'off', 'MaxHeadSize', 0.02, 'LineWidth', 1.2)
    l(3) = plot(nan, nan, 'linewidth', 2, 'color', green);
    legend(l, {'CS axis', 'NM axis', 'CM axis'})
else
    legend(l, {'CS axis', 'NM axis'})
end


xlim([-1 1])
ylim([-1 1])
orientations_axes.XTickLabel = [];
orientations_axes.YTickLabel = [];
orientations_axes.ZTickLabel = [];
xlabel('X')
ylabel('Y')
zlabel('Time')

hold off
axis equal
axis 'auto z'
grid off


% --- Executes on button press in save_button.
function save_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

savePath = getappdata(0, 'savePath');
metadata = getappdata(0, 'gui_metadata');
gui_results_CS_dist   = getappdata(0, 'gui_results_CS_dist');
gui_results_CS_angles = getappdata(0, 'gui_results_CS_angles');
gui_results_CS_coords_um_centered = getappdata(0, 'gui_results_CS_coords_um_centered');
gui_results_CS_coords_um = getappdata(0, 'gui_results_CS_coords_um');

NM_vars   = getappdata(0, 'gui_results_NM_vars');
CM_vars   = getappdata(0, 'gui_results_CM_vars');

finalFilename = getappdata(0, 'gui_finalFilename');

%% Save results as CSV
nFrames = metadata.nFrames;
time_step = metadata.frame_step;
time = [1:nFrames]'*time_step;
CS_matrix = [time, gui_results_CS_coords_um.x(:,1), gui_results_CS_coords_um.y(:,1), gui_results_CS_coords_um.z(:,1), ...
    gui_results_CS_coords_um.x(:,2), gui_results_CS_coords_um.y(:,2), gui_results_CS_coords_um.z(:,2),...
    gui_results_CS_coords_um_centered.x(:,1), gui_results_CS_coords_um_centered.y(:,1), gui_results_CS_coords_um_centered.z(:,1), ...
    gui_results_CS_coords_um_centered.x(:,2), gui_results_CS_coords_um_centered.y(:,2), gui_results_CS_coords_um_centered.z(:,2), ...
    gui_results_CS_dist, gui_results_CS_angles];

if isempty(NM_vars.metrics.centroid)
    NM_matrix = NaN(length(gui_results_CS_dist), 6);
else
    NM_matrix = [NM_vars.metrics.centroid, NM_vars.CS_NM_axis_ang_degrees', ...
    NM_vars.metrics.eccentricity, NM_vars.metrics.eccentricity];
end

if isempty(CM_vars.metrics.centroid)
    CM_matrix = NaN(length(gui_results_CS_dist), 7);
else
    CM_matrix = [CM_vars.metrics.centroid, CM_vars.CS_CM_axis_ang_degrees', CM_vars.NM_CM_axis_ang_degrees', ...
       CM_vars.metrics.eccentricity, CM_vars.metrics.irregularity];
end

results_matrix = [CS_matrix, NM_matrix, CM_matrix];

csvwrite([savePath finalFilename '.csv'], results_matrix)

headers = {'Time_s', 'CS_Raw_X1', 'CS_Raw_Y1', 'CS_Raw_Z1', 'CS_Raw_X2', 'CS_Raw_Y2', 'CS_Raw_Z2', 'CS_Centered_X1', 'CS_Centered_Y1', 'CS_Centered_Z1', ...
    'CS_Centered_X2', 'CS_Centered_Y2', 'CS_Centered_Z2', 'CS_distances', 'CS_centroid_angles',...
    'NM_centroid_X', 'NM_centroid_Y', 'NM_centroid_Z', 'CS_vector_NM_axis_angles', 'NM_eccentricity','NM_irregularity', ...
    'CM_centroid_X', 'CM_centroid_Y', 'CM_centroid_Z', 'CS_vector_CM_axis_angles', 'NM_CM_axis_angles', 'CM_eccentricity','CM_irregularity' };


T = array2table(results_matrix, 'VariableNames', headers);
writetable(T, [savePath finalFilename '.xlsx']);
msgbox('Results saved in Excel and CSV files')

%% Save .mat file
answer = questdlg('Save .mat data? This allows you to recover all application data after restarting Matlab');

if strcmp(answer, 'Yes')
    try
    m = msgbox('Saving .mat file...');

    Trackosome_version = getappdata(0, 'gui_Trackosome_version');
    gui_Preprocess_vars = getappdata(0, 'gui_Preprocess_vars');
    Img_CS = getappdata(0, 'gui_Img_C');
    Img_NM = getappdata(0, 'gui_Img_NM');
    Img_CM = getappdata(0, 'gui_Img_CM');
    gui_LoadData_vars = getappdata(0, 'gui_LoadData_vars');
    gui_LoadData_state = getappdata(0, 'gui_LoadData_state');
    gui_track_CS_x_px = getappdata(0, 'gui_track_CS_x_px');
    gui_track_CS_y_px = getappdata(0, 'gui_track_CS_y_px');
    gui_track_CS_z_stack = getappdata(0, 'gui_track_CS_z_stack');
    metadata = getappdata(0, 'gui_metadata');
    gui_track_ROI_pos = getappdata(0, 'gui_track_ROI_pos');
    gui_track_tracking_state = getappdata(0, 'gui_track_tracking_state');
    gui_track_results_available = getappdata(0, 'gui_track_results_available');
    gui_track_activatedFrames = getappdata(0, 'gui_track_activatedFrames');
    gui_track_default_settings = getappdata(0, 'gui_track_default_settings');
    
    
    %% Organize CS variables:
    CS_vars.coords_px_stack.x_px = gui_track_CS_x_px;
    CS_vars.coords_px_stack.y_px = gui_track_CS_y_px;
    CS_vars.coords_px_stack.z_stack = gui_track_CS_z_stack;
    CS_vars.coords_um_centered = gui_results_CS_coords_um_centered;
    CS_vars.coords_um = gui_results_CS_coords_um;
    CS_vars.CS_dist = gui_results_CS_dist;
    CS_vars.CS_angles = gui_results_CS_angles;

    %% Organize GUI variables 
    GUI_vars.Trackosome_version = Trackosome_version;
    GUI_vars.LoadData_vars = gui_LoadData_vars;
    GUI_vars.LoadData_vars.state = gui_LoadData_state;    
    GUI_vars.Preprocess_vars = gui_Preprocess_vars;
    GUI_vars.Track_vars.ROI_pos = gui_track_ROI_pos;
    GUI_vars.Track_vars.tracking_state = gui_track_tracking_state;
    GUI_vars.Track_vars.results_available = gui_track_results_available;
    GUI_vars.Track_vars.activatedFrames = gui_track_activatedFrames;
    GUI_vars.Track_vars.default_settings = gui_track_default_settings;
        
    
    %% Save                              
    save([ savePath finalFilename '.mat'], 'savePath', 'Img_CS', 'Img_NM', 'Img_CM', 'metadata',...
        'CS_vars', 'NM_vars', 'CM_vars', 'GUI_vars')


    close(m)
    msgbox('Matlab file saved!');
    catch
    msgbox('Error saving .mat file...')
    end

end




% --- Outputs from this function are returned to the command line.
function varargout = GUI_Tracking_Results_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function click_frame_button(hObject, ~, handles, f)

tracking_state = getappdata(0, 'gui_track_tracking_state');
activatedFrames = getappdata(0, 'gui_track_activatedFrames');

update_results_current_frame(handles, hObject, f, tracking_state, activatedFrames)


function update_results_current_frame(handles, buttonObject, f, tracking_state, activatedFrames)

%% Freeze all buttons:
set(handles.all_buttons, 'enable', 'off')
frame_state_buttons = getappdata(0, 'gui_results_frame_state_buttons');
set(frame_state_buttons , 'enable', 'off')


%% Update frame button:
if isempty(buttonObject) 
    % Update frame button
    button_tag = ['button_' num2str(f)];
    buttonObject = findobj('Tag', button_tag);
end

update_frame_button(buttonObject, frame_state_buttons, f, tracking_state.frame_states, activatedFrames)
update_plots(handles, f, tracking_state);
setappdata(0, 'gui_track_currentFrame', f)

set(handles.current_frame_text, 'string', f)

%% Unfreeze buttons:
set(handles.all_buttons, 'enable', 'on')
set(frame_state_buttons , 'enable', 'on')
LoadData_vars = getappdata(0, 'gui_LoadData_vars');
if ~LoadData_vars.with_CM
    set(handles.CM_show_button, 'enable', 'off')
end


function update_plots(handles, f, tracking_state)

metadata = getappdata(0, 'gui_metadata');
imgs_to_show = getappdata(0, 'gui_results_imgs_to_show');
NM_vars = getappdata(0, 'gui_results_NM_vars');
CM_vars = getappdata(0, 'gui_results_CM_vars');
CS_angles = getappdata(0, 'gui_results_CS_angles');
CS_dist = getappdata(0, 'gui_results_CS_dist');
traj_plot_mode = getappdata(0, 'gui_results_traj_plot_mode');
CS_coords_um = getappdata(0, 'gui_results_CS_coords_um');
blue = getappdata(0, 'gui_color_3');
green = getappdata(0, 'gui_color_4');
yellow = getappdata(0, 'gui_color_5');
red = getappdata(0, 'gui_color_6');

t = (0:metadata.nFrames-1) * metadata.frame_step;

%% 3D visualization:
% Define elements to visualize in the reconstruction:
[Img_NM_BW, Img_CM_BW, centroid, CS_coords_um_f] = defineReconstInputs(imgs_to_show, CS_coords_um, NM_vars, CM_vars, f);

visualize_reconstruction(handles.reconstruction_axes, Img_NM_BW, Img_CM_BW,...
    centroid, CS_coords_um_f.x, CS_coords_um_f.y, CS_coords_um_f.z, metadata, tracking_state.CS_states(f,:))


%% Highlight current frame in plots:
if traj_plot_mode == 2
    CS_coords_um = getappdata(0, 'gui_results_CS_coords_um_centered');
end

update_plot( CS_coords_um.x(f,1), CS_coords_um.y(f,1), CS_coords_um.z(f,1), handles.CS_traj_axes, tracking_state.CS_states(f,1), red, true)
update_plot( CS_coords_um.x(f,2), CS_coords_um.y(f,2), CS_coords_um.z(f,2), handles.CS_traj_axes, tracking_state.CS_states(f,2), blue, false)  
update_plot( t(f) , CS_dist(f), [], handles.CS_dists_axes, tracking_state.frame_states(f), blue, false)
update_plot( t(f) , CS_angles(f), [], handles.CS_angles_axes, tracking_state.frame_states(f), blue, false)

if ~isnan(NM_vars.metrics.pca)
update_plot( t(f) , NM_vars.CS_NM_axis_ang_degrees(f), [], handles.axis_angles_axes, tracking_state.frame_states(f), blue, false)
end

if ~isnan(CM_vars.metrics.pca)
    update_plot( t(f) , CM_vars.CS_CM_axis_ang_degrees(f), [], handles.axis_angles_axes, tracking_state.frame_states(f), green, false)
    update_plot( t(f) , CM_vars.NM_CM_axis_ang_degrees(f), [], handles.axis_angles_axes, tracking_state.frame_states(f), red, false)
end


function update_plot( x, y, z, axes_h, frame_state, color, toDelete)
    
previousPoints = getappdata(0, 'gui_results_previousPoints');

if toDelete
    delete(previousPoints)
end

if frame_state == 3
    color = 'y';
elseif frame_state == 4
    color = [0.5 0.5 0.5];
end

axes(axes_h)
hold on
if isempty(z)
    previousPoints = [previousPoints plot(x, y, '.', 'color', color, 'markersize', 16)];
    previousPoints = [previousPoints plot(x, y, 'ko', 'markersize', 5)];
else    
    previousPoints = [previousPoints plot3(x, y, z, '.', 'color', color, 'markersize', 16)];
    previousPoints = [previousPoints plot3(x, y, z,  'ko', 'markersize', 5)];
end
setappdata(0, 'gui_results_previousPoints',previousPoints)

    
% --- Executes on button press in right_button.
function right_button_Callback(hObject, eventdata, handles)
% hObject    handle to right_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
metadata = getappdata(0, 'gui_metadata');
f = getappdata(0, 'gui_track_currentFrame');
f = min(metadata.nFrames, f+1);
tracking_state = getappdata(0, 'gui_track_tracking_state');
activatedFrames = getappdata(0, 'gui_track_activatedFrames');
update_results_current_frame(handles, [], f, tracking_state, activatedFrames)


% --- Executes on button press in left_button.
function left_button_Callback(hObject, eventdata, handles)
% hObject    handle to left_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
f = getappdata(0, 'gui_track_currentFrame');
f = max(1, f-1);
tracking_state = getappdata(0, 'gui_track_tracking_state');
activatedFrames = getappdata(0, 'gui_track_activatedFrames');
update_results_current_frame(handles, [], f, tracking_state, activatedFrames)


% --- Executes on button press in back_button.
function back_button_Callback(hObject, eventdata, handles)
% hObject    handle to back_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(GUI_Tracking_Results)
GUI_TrackCentrosomes


% --- Executes on button press in fig_CS_traj.
function fig_CS_traj_Callback(hObject, eventdata, handles)
% hObject    handle to fig_CS_traj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

traj_plot_mode = getappdata(0, 'gui_results_traj_plot_mode');
tracking_state = getappdata(0, 'gui_track_tracking_state');
metadata = getappdata(0, 'gui_metadata');

if traj_plot_mode == 1
    CS_coords_um = getappdata(0, 'gui_results_CS_coords_um');
else
    CS_coords_um = getappdata(0, 'gui_results_CS_coords_um_centered');
end

fig = figure;
plot_trajectories(fig, CS_coords_um, tracking_state.CS_states, metadata)


% --- Executes on button press in fig_CS_dist.
function fig_CS_dist_Callback(hObject, eventdata, handles)
% hObject    handle to fig_CS_dist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CS_dist = getappdata(0, 'gui_results_CS_dist');
tracking_state = getappdata(0, 'gui_track_tracking_state');
metadata = getappdata(0, 'gui_metadata');
t = (0:metadata.nFrames-1) * metadata.frame_step;
blue_color = getappdata(0, 'gui_color_3');
fig = figure;
plot_curve(fig, CS_dist, t, tracking_state.frame_states, 'Time [sec]',  'Distance [um]', blue_color);


% --- Executes on button press in fig_reconstruction.
function fig_reconstruction_Callback(hObject, eventdata, handles)
% hObject    handle to fig_reconstruction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
LoadData_vars = getappdata(0, 'gui_LoadData_vars');
f = getappdata(0, 'gui_track_currentFrame');
CS_coords_um = getappdata(0, 'gui_results_CS_coords_um');
NM_vars = getappdata(0, 'gui_results_NM_vars');
CM_vars = getappdata(0, 'gui_results_CM_vars');
metadata = getappdata(0, 'gui_metadata');
tracking_state = getappdata(0, 'gui_track_tracking_state');

imgs_to_show = [LoadData_vars.with_CS LoadData_vars.with_NM LoadData_vars.with_CM];
setappdata(0, 'gui_results_imgs_to_show', imgs_to_show) % [show CS, show NM, show CM]

[Img_CM_BW, Img_NM_BW, centroid, CS_coords_um_f] = defineReconstInputs(imgs_to_show, CS_coords_um, NM_vars, CM_vars, f);

fig = figure;
visualize_reconstruction(fig, Img_CM_BW, Img_NM_BW,...
    centroid, CS_coords_um_f.x, CS_coords_um_f.y, CS_coords_um_f.z, metadata, tracking_state.CS_states(f,:))


% --- Executes on button press in fig_CS_angles.
function fig_CS_angles_Callback(hObject, eventdata, handles)
% hObject    handle to fig_CS_angles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CS_anglss = getappdata(0, 'gui_results_CS_angles');
tracking_state = getappdata(0, 'gui_track_tracking_state');
metadata = getappdata(0, 'gui_metadata');
t = (0:metadata.nFrames-1) * metadata.frame_step;
blue_color = getappdata(0, 'gui_color_3');
fig = figure;
plot_curve(fig, CS_anglss, t, tracking_state.frame_states, 'Time [sec]',  'Angles [deg]', blue_color);


% --- Executes on button press in fig_axis_angles.
function fig_axis_angles_Callback(hObject, eventdata, handles)
% hObject    handle to fig_axis_angles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% tracking_state = getappdata(0, 'gui_track_tracking_state');
% NM_vars = getappdata(0, 'gui_results_NM_vars');
% CM_vars = getappdata(0, 'gui_results_CM_vars');
% metadata = getappdata(0, 'gui_metadata');
% t = (0:metadata.nFrames-1) * metadata.frame_step;
% blue_color = getappdata(0, 'gui_color_3');
% fig = figure;
% obj = plot_curve(fig, NM_vars.CS_NM_axis_ang_degrees, t, tracking_state.frame_states, 'Time [sec]', 'Angle [degrees]', blue_color);
% 
% if  isempty(CM_vars.CS_CM_axis_ang_degrees)
%     set(handles.title_axis_angles, 'string', 'Angle between Nucleus major axis and Centrosomes')
% else
%     green_color = getappdata(0, 'gui_color_4');
%     obj2 = plot_curve(gca, CM_vars.CS_CM_axis_ang_degrees, t, tracking_state.frame_states, 'Time [sec]', 'Angle [degrees]', green_color);
%     legend([obj2 obj], {'Centrosomes/Cell Memb' 'Centrosomes/Nuclear Memb' }, 'Location', 'best', 'AutoUpdate','off')
%     set(handles.title_axis_angles, 'string', 'Angle between Nucleus/Cell major axis and Centrosomes')
% end
tracking_state = getappdata(0, 'gui_track_tracking_state');
NM_vars = getappdata(0, 'gui_results_NM_vars');
CM_vars = getappdata(0, 'gui_results_CM_vars');
metadata = getappdata(0, 'gui_metadata');
t = (0:metadata.nFrames-1) * metadata.frame_step;
blue_color = getappdata(0, 'gui_color_3');
fig = figure;
obj = plot_curve(fig, NM_vars.CS_NM_axis_ang_degrees, t, tracking_state.frame_states, 'Time [sec]', 'Angle [degrees]', blue_color);

if  isempty(CM_vars.CS_CM_axis_ang_degrees)
    set(handles.title_axis_angles, 'string', 'Angle between Nucleus major axis and Centrosomes')
else
    green_color = getappdata(0, 'gui_color_4');
    red_color = getappdata(0, 'gui_color_6');
    obj2 = plot_curve(gca, CM_vars.CS_CM_axis_ang_degrees, t, tracking_state.frame_states, 'Time [sec]', 'Angle [degrees]', green_color);
    obj3 = plot_curve(gca, CM_vars.NM_CM_axis_ang_degrees, t, tracking_state.frame_states, 'Time [sec]', 'Angle [degrees]', red_color);
    legend([obj3 obj2 obj], {'Nuclear/Cell Memb', 'Centrosomes/Cell Memb' 'Centrosomes/Nuclear Memb' }, 'Location', 'best', 'AutoUpdate','off')
    set(handles.title_axis_angles, 'string', 'Angle between Nucleus/Cell major axis and Centrosomes')
end


% --- Executes on button press in fig_axis_3D.
function fig_axis_3D_Callback(hObject, eventdata, handles)
% hObject    handle to fig_axis_3D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

metadata = getappdata(0, 'gui_metadata');
NM_vars = getappdata(0, 'gui_results_NM_vars');
CM_vars = getappdata(0, 'gui_results_CM_vars');
CS_coords_um = getappdata(0, 'gui_results_CS_coords_um');

figure
plot_CS_NM_CM_orientation_axis(gca, metadata.nFrames, NM_vars.metrics.pca, CM_vars.metrics.pca, CS_coords_um)


function last_frame_box_Callback(hObject, eventdata, handles)
% hObject    handle to last_frame_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of last_frame_box as text
%        str2double(get(hObject,'String')) returns contents of last_frame_box as a double

tracking_state = getappdata(0, 'gui_track_tracking_state');
frame_state_buttons = getappdata(0, 'gui_results_frame_state_buttons');
metadata = getappdata(0, 'gui_metadata');
activatedFrames = getappdata(0, 'gui_track_activatedFrames');
prev_last_activated_frame = getappdata(0, 'gui_track_last_activated_frame');
first_activated_frame = getappdata(0, 'gui_track_first_activated_frame');

last_activated_frame = str2double(get(hObject,'String'));

% Check if input is valid:
if last_activated_frame > metadata.nFrames
    last_activated_frame = metadata.nFrames;
    str2double(set(hObject,'string', last_activated_frame));
elseif last_activated_frame < first_activated_frame
    last_activated_frame = first_activated_frame;
    str2double(set(hObject,'string', last_activated_frame));
end

% Update activated frames and buttons:
if last_activated_frame > prev_last_activated_frame 
    activatedFrames(prev_last_activated_frame:last_activated_frame) = 1;
    frames = prev_last_activated_frame:last_activated_frame;    
else
    activatedFrames(last_activated_frame + 1:metadata.nFrames) = 0;
    frames = last_activated_frame + 1:metadata.nFrames;
end

setappdata(0, 'gui_track_tracking_state', tracking_state)
setappdata(0, 'gui_track_last_activated_frame', last_activated_frame)
setappdata(0, 'gui_track_activatedFrames', activatedFrames);

update_button_color(frame_state_buttons, frames, tracking_state.frame_states, activatedFrames, false)    
update_plots(handles, frames, 1, activatedFrames)


% --- Executes during object creation, after setting all properties.
function last_frame_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to last_frame_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
metadata = getappdata(0, 'gui_metadata');
set(hObject, 'string', metadata.nFrames)


function first_frame_box_Callback(hObject, eventdata, handles)
% hObject    handle to first_frame_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of first_frame_box as text
%        str2double(get(hObject,'String')) returns contents of first_frame_box as a double
tracking_state = getappdata(0, 'gui_track_tracking_state');
frame_state_buttons = getappdata(0, 'gui_results_frame_state_buttons');
activatedFrames = getappdata(0, 'gui_track_activatedFrames');
prev_first_activated_frame = getappdata(0, 'gui_track_first_activated_frame');
last_activated_frame = getappdata(0, 'gui_track_last_activated_frame');
first_activated_frame = str2double(get(hObject,'String'));

% Check if input is valid:
if first_activated_frame < 1
    first_activated_frame = 1;
    str2double(set(hObject,'string', first_activated_frame));
elseif first_activated_frame >= last_activated_frame
    first_activated_frame = last_activated_frame;
    str2double(set(hObject,'string', first_activated_frame));
end

% Update activated frames and buttons:
if first_activated_frame < prev_first_activated_frame
    activatedFrames(first_activated_frame:prev_first_activated_frame) = 1;
    frames = first_activated_frame:prev_first_activated_frame;
else
    activatedFrames(1:first_activated_frame - 1) = 0;
    frames = 1:first_activated_frame;
end

setappdata(0, 'gui_track_tracking_state', tracking_state)
setappdata(0, 'gui_track_first_activated_frame', first_activated_frame)
setappdata(0, 'gui_track_activatedFrames', activatedFrames);

update_button_color(frame_state_buttons, frames, tracking_state.frame_states, activatedFrames, false)    
update_plots(handles, frames, 1, activatedFrames)


% --- Executes during object creation, after setting all properties.
function first_frame_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to first_frame_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function CM_show_button_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

blue_color = getappdata(0, 'gui_color_1');

if isempty(blue_color)
    blue_color = [0.3 0.75 0.93];
    setappdata(0, 'gui_color_3', blue_color)
end

LoadData_vars = getappdata(0, 'gui_LoadData_vars');

if LoadData_vars.with_CM
   set(hObject, 'enable', 'on')
   set(hObject, 'backgroundcolor', blue_color)
else
   set(hObject, 'enable', 'off')
   set(hObject, 'backgroundcolor', [0.94 0.94 0.94])
end
    

% --- Executes on button press in CM_show_button.
function CM_show_button_Callback(hObject, eventdata, handles)
% hObject    handle to CM_show_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
imgs_to_show = getappdata(0, 'gui_results_imgs_to_show');
metadata = getappdata(0, 'gui_metadata');
f = getappdata(0, 'gui_track_currentFrame');

set(handles.all_buttons, 'enable', 'off')

CS_coords_um = getappdata(0, 'gui_results_CS_coords_um'); 
NM_vars = getappdata(0, 'gui_results_NM_vars');
CM_vars = getappdata(0, 'gui_results_CM_vars');
tracking_state = getappdata(0, 'gui_track_tracking_state');

if imgs_to_show(3)     
    imgs_to_show(3) = 0; 
    set(hObject, 'backgroundcolor', [0.94 0.94 0.94])
else
    imgs_to_show(3) = 1;
    set(hObject, 'backgroundcolor', getappdata(0, 'gui_color_1'))
end

[Img_NM_BW, Img_CM_BW, centroid, CS_coords_um] = defineReconstInputs(imgs_to_show, CS_coords_um, NM_vars, CM_vars, f);

visualize_reconstruction(handles.reconstruction_axes, Img_NM_BW, Img_CM_BW,...
    centroid, CS_coords_um.x, CS_coords_um.y, CS_coords_um.z, metadata, tracking_state.CS_states(f,:))

setappdata(0, 'gui_results_imgs_to_show', imgs_to_show)

set(handles.all_buttons, 'enable', 'on')


% --- Executes during object creation, after setting all properties.
function NM_show_button_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in NM_show_button.
function NM_show_button_Callback(hObject, eventdata, handles)
% hObject    handle to NM_show_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
imgs_to_show = getappdata(0, 'gui_results_imgs_to_show');
metadata = getappdata(0, 'gui_metadata');
f = getappdata(0, 'gui_track_currentFrame');
LoadData_vars = getappdata(0, 'gui_LoadData_vars');
tracking_state = getappdata(0, 'gui_track_tracking_state');

set(handles.all_buttons, 'enable', 'off')

CS_coords_um = getappdata(0, 'gui_results_CS_coords_um');  
CM_vars = getappdata(0, 'gui_results_CM_vars');
NM_vars = getappdata(0, 'gui_results_NM_vars');
  
if imgs_to_show(2)     
    imgs_to_show(2) = 0; 
    set(hObject, 'backgroundcolor', [0.94 0.94 0.94])
else
    imgs_to_show(2) = 1; 
    set(hObject, 'backgroundcolor', getappdata(0, 'gui_color_1'))
end

[Img_NM_BW, Img_CM_BW, centroid, CS_coords_um] = defineReconstInputs(imgs_to_show, CS_coords_um, NM_vars, CM_vars, f);

visualize_reconstruction(handles.reconstruction_axes, Img_NM_BW, Img_CM_BW,...
    centroid, CS_coords_um.x, CS_coords_um.y, CS_coords_um.z, metadata, tracking_state.CS_states(f,:))

setappdata(0, 'gui_results_imgs_to_show', imgs_to_show)

set(handles.all_buttons, 'enable', 'on')

if ~LoadData_vars.with_CM
    set(handles.CM_show_button, 'enable', 'off')
end


% --- Executes during object creation, after setting all properties.
function CS_show_button_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CS_show_button.
function CS_show_button_Callback(hObject, eventdata, handles)
% hObject    handle to CS_show_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
imgs_to_show = getappdata(0, 'gui_results_imgs_to_show');
metadata = getappdata(0, 'gui_metadata');
f = getappdata(0, 'gui_track_currentFrame');
CS_coords_um = getappdata(0, 'gui_results_CS_coords_um');  
CM_vars = getappdata(0, 'gui_results_CM_vars');
NM_vars = getappdata(0, 'gui_results_NM_vars');
LoadData_vars = getappdata(0, 'gui_LoadData_vars');
tracking_state = getappdata(0, 'gui_track_tracking_state');

set(handles.all_buttons, 'enable', 'off')

if imgs_to_show(1)     
    imgs_to_show(1) = 0; 
    set(hObject, 'backgroundcolor', [0.94 0.94 0.94])
else
    imgs_to_show(1) = 1; 
    set(hObject, 'backgroundcolor', getappdata(0, 'gui_color_1'))
end

[NM_memb_BW, CM_memb_BW, centroid, CS_coords_um] = defineReconstInputs(imgs_to_show, CS_coords_um, NM_vars, CM_vars, f);

visualize_reconstruction(handles.reconstruction_axes, NM_memb_BW, CM_memb_BW,...
    centroid, CS_coords_um.x, CS_coords_um.y, CS_coords_um.z, metadata, tracking_state.CS_states(f,:))

setappdata(0, 'gui_results_imgs_to_show', imgs_to_show)

set(handles.all_buttons, 'enable', 'on')

if ~LoadData_vars.with_CM
    set(handles.CM_show_button, 'enable', 'off')
end




function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function axis_angles_axes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axis_angles_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axis_angles_axes

% --- Executes during object creation, after setting all properties.
function CS_dists_axes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axis_angles_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axis_angles_axes


% --- Executes on button press in center_button.
function center_button_Callback(hObject, ~, handles)
% hObject    handle to center_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

traj_plot_mode = getappdata(0, 'gui_results_traj_plot_mode');
tracking_state = getappdata(0, 'gui_track_tracking_state');
metadata = getappdata(0, 'gui_metadata');
    
if traj_plot_mode == 1 % Show Centered Trajectories
    
    CS_coords_um_centered = getappdata(0, 'gui_results_CS_coords_um_centered');
    
%     if isempty(CS_coords_um_centered)
%         
%         CS_raw_coords_um = getappdata(0, 'gui_results_CS_coords_um');
%         NM_vars = getappdata(0, 'gui_results_NM_vars');
%         
%         CS_coords_um_centered = normalize_CS_coords_with_Median_NM(CS_raw_coords_um, NM_vars.metrics.centroid);
%         setappdata(0, 'gui_results_CS_coords_um_centered', CS_coords_um_centered)
%     end    

    %% Update interface
    set(hObject, 'String', 'Show Raw Coords')
    traj_plot_mode = 2;  
    cla(handles.CS_traj_axes)
    plot_trajectories( handles.CS_traj_axes, CS_coords_um_centered, tracking_state.CS_states, metadata)
    hold on
    scatter3( 0, 0, 0, 'o', 'filled', 'MarkerFaceColor', getappdata(0, 'gui_color_5'));

else
    %% Raw Trajectories
    traj_plot_mode = 1;
    CS_coords_um = getappdata(0, 'gui_results_CS_coords_um');
    set(hObject, 'String', 'Show Normalized Coords')
    cla(handles.CS_traj_axes)
    plot_trajectories( handles.CS_traj_axes, CS_coords_um, tracking_state.CS_states, metadata)
end

setappdata(0, 'gui_results_traj_plot_mode', traj_plot_mode)



function CS_coords_norm_um = normalize_CS_coords_with_Median_NM(CS_raw_coords_um, centroid)

%% Filter Centroid Trajectory
plotCentroid = 0;
filterWindow = 3;
[filtered_centroid] = Filter_NM_Centroid(centroid, filterWindow, plotCentroid );

%% Normalize Centrosomes:
CS_coords_norm_um.x = CS_raw_coords_um.x - filtered_centroid(:,1);
CS_coords_norm_um.y = CS_raw_coords_um.y - filtered_centroid(:,2);
CS_coords_norm_um.z = CS_raw_coords_um.z - filtered_centroid(:,3);


% --- Executes on button press in menu_button.
function menu_button_Callback(hObject, eventdata, handles)
% hObject    handle to menu_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(GUI_Tracking_Results)
GUI_Main_Menu


% --- Executes on button press in chose_path_button.
function chose_path_button_Callback(hObject, eventdata, handles)
% hObject    handle to chose_path_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
path = getappdata(0, 'savePath');

try
    new_path = uigetdir(path);
catch
    new_path = uigetdir(pwd);
end

if ~new_path
    new_path = pwd;
end

new_path = [new_path '\'];
set(handles.save_path_box, 'string', new_path)
pause(0.01)
setappdata(0, 'savePath', new_path)




function save_path_box_Callback(hObject, eventdata, handles)
% hObject    handle to save_path_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of save_path_box as text
%        str2double(get(hObject,'String')) returns contents of save_path_box as a double
new_path = get(hObject,'String');
new_path = [new_path '\'];
setappdata(0, 'savePath', new_path)


% --- Executes during object creation, after setting all properties.
function save_path_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to save_path_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
path = getappdata(0, 'savePath');

if isempty(path)
    path = pwd;
    path = [path '\'];
end

setappdata(0, 'savePath', path)
set(hObject, 'string', path)


function filename_box_Callback(hObject, eventdata, handles)
% hObject    handle to filename_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filename_box as text
%        str2double(get(hObject,'String')) returns contents of filename_box as a double
finalFilename = get(hObject,'String');
setappdata(0, 'gui_finalFilename', finalFilename)


% --- Executes during object creation, after setting all properties.
function filename_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filename_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
finalFilename = getappdata(0, 'gui_finalFilename');
set(hObject, 'string', finalFilename)



function thresh_level_edit_Callback(hObject, eventdata, handles)
% hObject    handle to thresh_level_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of thresh_level_edit as text
%        str2double(get(hObject,'String')) returns contents of thresh_level_edit as a double


% --- Executes during object creation, after setting all properties.
function thresh_level_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thresh_level_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

thresh_level = getappdata(0, 'gui_results_thresh_level');
set(hObject, 'string', num2str(thresh_level))

function my_closereq(src,callbackdata)
% setappdata(0, 'gui_current_window', 0);
% delete(GUI_Tracking_Results)


% --- Executes on button press in correct_memb_button.
function correct_memb_button_Callback(hObject, eventdata, handles)
% hObject    handle to correct_memb_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(GUI_Tracking_Results)
Correct_Membranes

% --- Executes during object creation, after setting all properties.
function correct_memb_button_CreateFcn(hObject, eventdata, handles)
% hObject    handle to correct_memb_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
