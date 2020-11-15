function varargout = GUI_TrackCentrosomes(varargin)
% GUI_TRACKCENTROSOMES MATLAB code for GUI_TrackCentrosomes.fig
%      GUI_TRACKCENTROSOMES, by itself, creates a new GUI_TRACKCENTROSOMES or raises the existing
%      singleton*.
%
%      H = GUI_TRACKCENTROSOMES returns the handle to a new GUI_TRACKCENTROSOMES or the handle to
%      the existing singleton*.
%
%      GUI_TRACKCENTROSOMES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_TRACKCENTROSOMES.M with the given input arguments.
%
%      GUI_TRACKCENTROSOMES('Property','Value',...) creates a new GUI_TRACKCENTROSOMES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_TrackCentrosomes_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_TrackCentrosomes_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_TrackCentrosomes

% Last Modified by GUIDE v2.5 02-May-2019 18:49:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GUI_TrackCentrosomes_OpeningFcn, ...
    'gui_OutputFcn',  @GUI_TrackCentrosomes_OutputFcn, ...
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


% --- Executes just before GUI_TrackCentrosomes is made visible.
function GUI_TrackCentrosomes_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_TrackCentrosomes (see VARARGIN)

%% States:
%         0 - Stooped, ROIs not visible, CSs not visible
%         1 - Running
%         2 - Stooped, ROIs visible
%         3 - Stooped, ROIs not visible, CSs visible

% Choose default command line output for GUI_TrackCentrosomes

handles.output = hObject;
set(handles.figure1, 'Name', 'Track Centrosomes');
setappdata(0, 'gui_current_window', 3)


%% Load Variables:
metadata = getappdata(0, 'gui_metadata');
metadata.threshFactor_XY = 1.5;

activatedFrames = getappdata(0, 'gui_track_activatedFrames');
first_activated_frame = getappdata(0, 'gui_track_first_activated_frame');
last_activated_frame = getappdata(0, 'gui_track_last_activated_frame');

if isempty(activatedFrames)
    activatedFrames = ones(metadata.nFrames, 1);
    first_activated_frame = 1;
    last_activated_frame = metadata.nFrames;
end

%% Check what initializations are needed:
CS_x_px = getappdata(0, 'gui_track_CS_x_px');
CS_y_px = getappdata(0, 'gui_track_CS_y_px');
Preprocess_vars = getappdata(0, 'gui_Preprocess_vars');

if isempty(CS_x_px)
    initialize_variables(metadata)      
elseif Preprocess_vars.X ~= CS_x_px(1,:) & Preprocess_vars.Y ~= CS_y_px(1,:) 
    % Data was loaded, but user changed initial positions of centrosomes
    X = Preprocess_vars.X;
    Y = Preprocess_vars.Y;
    ROI_pos = getappdata(0, 'gui_track_ROI_pos');
    
    % Change ROI positions for frame 1:
    [CS_mask_ROI_XY, CS_mask_ROI_XZ, metadata] = initialize_masks(metadata, X, Y);
    [ROI_pos.xi(1,:), ROI_pos.yi(1,:), ROI_pos.zi(1,:), ROI_pos.lx(1,:), ROI_pos.ly(1,:), ROI_pos.lz(1,:)] ...
        = from_masks_to_ROI_pos(CS_mask_ROI_XY , CS_mask_ROI_XZ);
    setappdata(0, 'gui_track_ROI_pos', ROI_pos)    
end

%% Generate Frame Buttons
tracking_state = getappdata(0, 'gui_track_tracking_state');
frame_state_buttons = generate_frame_buttons(handles, metadata.nFrames, @click_frame_button);
update_button_color(frame_state_buttons, [],tracking_state.frame_states, activatedFrames, false);
setappdata(0, 'gui_track_frame_state_buttons', frame_state_buttons)

%% Set buttons states
handles.state = 0;
manage_buttons(handles)

%% Plot initial Frame
Img_C = getappdata(0, 'gui_Img_C');
CS_x_px = getappdata(0, 'gui_track_CS_x_px');
CS_y_px = getappdata(0, 'gui_track_CS_y_px');
CS_z_stack = getappdata(0, 'gui_track_CS_z_stack');
plot_frame_and_CS_coords(handles, Img_C(:,:,:,1), CS_x_px(1,:), CS_y_px(1,:), CS_z_stack(1,:), '.')

%% Remove XY borders of 0's from filtering:
proj_y = squeeze(sum(sum(sum(Img_C, 4),3),2));
handles.xy_borders = round( (length(proj_y) - length(nonzeros(proj_y))) /2 );


%% Set Menu Buttons
update_menu_buttons([])

%% Save variables:
setappdata(0, 'gui_track_activatedFrames', activatedFrames)
setappdata(0, 'gui_track_first_activated_frame', first_activated_frame)
setappdata(0, 'gui_track_last_activated_frame', last_activated_frame)
setappdata(0, 'gui_track_remove_frames_state', 0)

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_TrackCentrosomes wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_TrackCentrosomes_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function initialize_variables(metadata)

%% Initialize Masks:
Preprocess_vars = getappdata(0, 'gui_Preprocess_vars');
X = Preprocess_vars.X;
Y = Preprocess_vars.Y;
[CS_mask_ROI_XY, CS_mask_ROI_XZ, metadata] = initialize_masks(metadata, X, Y);

%% Initialize CSs:
CS_x_px    = zeros(metadata.nFrames, 2);
CS_y_px    = zeros(metadata.nFrames, 2);
CS_z_stack = zeros(metadata.nFrames, 2);

%% Initialize positions of ROIs:
ROI_pos.xi = zeros(metadata.nFrames, 2);
ROI_pos.yi = zeros(metadata.nFrames, 2);
ROI_pos.zi = zeros(metadata.nFrames, 2);
ROI_pos.lx = zeros(metadata.nFrames, 2);
ROI_pos.ly = zeros(metadata.nFrames, 2);
ROI_pos.lz = zeros(metadata.nFrames, 2);

[ROI_pos.xi(1,:), ROI_pos.yi(1,:), ROI_pos.zi(1,:), ROI_pos.lx(1,:), ROI_pos.ly(1,:), ROI_pos.lz(1,:)] ...
    = from_masks_to_ROI_pos(CS_mask_ROI_XY , CS_mask_ROI_XZ);

%% Initialize Frame Buttons
tracking_state.frame_states = ones(metadata.nFrames, 1);
tracking_state.CS_states = ones( metadata.nFrames, 2);

%% Default Settings
default_settings.centrosome_radius_stacks = metadata.centrosome_radius_stacks;
default_settings.centrosome_radius_px = metadata.centrosome_radius_px;
default_settings.lengthROI_px = metadata.lengthROI_px;
default_settings.lengthROI_stacks = metadata.lengthROI_stacks;

%% Save data
setappdata(0, 'gui_metadata', metadata)
setappdata(0, 'gui_track_CS_x_px', CS_x_px)
setappdata(0, 'gui_track_CS_y_px', CS_y_px)
setappdata(0, 'gui_track_CS_z_stack', CS_z_stack)
setappdata(0, 'gui_track_ROI_pos', ROI_pos)
setappdata(0, 'gui_track_startingFrame', 1)
setappdata(0, 'gui_track_stopTracking', false)
setappdata(0, 'gui_track_currentFrame', 1)
setappdata(0, 'gui_track_warnings', []);
setappdata(0, 'gui_track_tracking_state', tracking_state)
setappdata(0, 'gui_track_default_settings', default_settings)


% --- Executes on slider movement.
function frame_slider_Callback(hObject, eventdata, handles)
% hObject    handle to frame_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% Set Buttons states:
handles.state = 0;
manage_buttons(handles);

CS_x_px = getappdata(0, 'gui_track_CS_x_px');
CS_y_px = getappdata(0, 'gui_track_CS_y_px');
CS_z_stack = getappdata(0, 'gui_track_CS_z_stack');
Img_C = getappdata(0, 'gui_Img_C');
currentFrame = round(get(hObject,'Value'));
setappdata(0, 'gui_track_currentFrame', currentFrame)
set(handles.current_frame_text,'string', currentFrame)
plot_frame_and_CS_coords(handles, Img_C(:,:,:,currentFrame), currentFrame, CS_x_px, CS_y_px, CS_z_stack, '.')

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function frame_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frame_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
set_slider_limitis(hObject)


function set_slider_limitis(hObject)
metadata = getappdata(0, 'gui_metadata');
nFrames = metadata.nFrames;
smallstep=1/(nFrames-1);                                                %Step the slider will take when moved using the arrow buttons: 1 frame
largestep=smallstep*10;
set(hObject,'BackgroundColor',[.9 .9 .9], 'Value', 1, 'Min', 1, 'Max', metadata.nFrames, 'SliderStep', [smallstep largestep],'Units','normalized' );


% --- Executes on button press in run_button.
function run_button_Callback(hObject, eventdata, handles)
% hObject    handle to run_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set buttons states:
handles.state = 1;
manage_buttons(handles)



%% Load Data
CS_x_px = getappdata(0, 'gui_track_CS_x_px');
CS_y_px = getappdata(0, 'gui_track_CS_y_px');
CS_z_stack = getappdata(0, 'gui_track_CS_z_stack');
metadata = getappdata(0, 'gui_metadata');
Img_C = getappdata(0, 'gui_Img_C');
f = getappdata(0, 'gui_track_startingFrame');
ROI_pos = getappdata(0, 'gui_track_ROI_pos');
tracking_state = getappdata(0, 'gui_track_tracking_state');
activatedFrames = getappdata(0, 'gui_track_activatedFrames');
setappdata(0, 'gui_track_stopTracking', false)
tracking_error = false;


%% Update handles structure
guidata(hObject, handles);


%% Tracking Cycle:
while f <= metadata.nFrames && ~getappdata(0, 'gui_track_stopTracking') && ~tracking_error
    
    % Generate Masks based on the positions of the ROI rectangles:
    [CS_mask_ROI_XY, CS_mask_ROI_XZ] = generate_frame_masks(f, ROI_pos, metadata);    
    
    % Find Centrosome coordinates:
    for c = 1:2
        [CS_x_px(f,c), CS_y_px(f,c),CS_z_stack(f,c), CS_mask_ROI_XY(:,:,c), CS_mask_ROI_XZ(:,:,c), danger, coordsFound] ...
            = from_frame_to_CS_coords(Img_C(:,:,:,f), CS_mask_ROI_XY(:,:,c), CS_mask_ROI_XZ(:,:,c), metadata, handles.xy_borders);        
       
        [tracking_state, tracking_error] = checkCoords(handles.warning_list, danger, coordsFound, tracking_state, c, f);
        
        if tracking_error
            handles = stop_tracking(handles, false);
            guidata(hObject, handles);
            break
        end
    end
    
    % Store positions of Masks for next frame. Masks positions are saved as positions of imrect
    if f < metadata.nFrames && ~tracking_error
        [ROI_pos.xi(f+1,:), ROI_pos.yi(f+1,:), ROI_pos.zi(f+1,:), ROI_pos.lx(f+1,:), ROI_pos.ly(f+1,:), ROI_pos.lz(f+1,:)] ...
            = from_masks_to_ROI_pos(CS_mask_ROI_XY , CS_mask_ROI_XZ);
    
    % Final Frame:    
    elseif ~tracking_error 
        setappdata(0, 'gui_track_results_available', 1)
        handles = stop_tracking(handles, true);
        guidata(hObject, handles);
    end
    
     tracking_state = update_current_frame(handles, Img_C(:,:,:,f), CS_x_px(f,:), CS_y_px(f,:), ...
         CS_z_stack(f,:), f,  tracking_state, activatedFrames, []);
     f = f + 1;
end

f = min(f, metadata.nFrames);

if tracking_error
    % if there is error, returns to frame before error:
    f =  max(1, f - 2);
    set(handles.resume_frame_text, 'String', f)   
end

set(handles.resume_frame_text, 'String', f)

%% Set data:
setappdata(0, 'gui_metadata', metadata);
setappdata(0, 'gui_track_CS_x_px', CS_x_px);
setappdata(0, 'gui_track_CS_y_px', CS_y_px);
setappdata(0, 'gui_track_CS_z_stack', CS_z_stack);
setappdata(0, 'gui_track_ROI_pos', ROI_pos);
setappdata(0, 'gui_track_tracking_state', tracking_state)

if f == metadata.nFrames
    resume_Frame = 1;
	set(handles.resume_frame_text, 'string', 1)
else
    resume_Frame = f;
end

setappdata(0, 'gui_track_startingFrame', resume_Frame);
setappdata(0, 'gui_track_to_save', 1)


function handles = stop_tracking(handles, finished_tracking)

handles.state = 0;
manage_buttons(handles)
if finished_tracking
    set(handles.results_button, 'enable', 'on')
end


function [CS_mask_ROI_XY, CS_mask_ROI_XZ, metadata] = initialize_masks(metadata, X, Y)

z_step = metadata.z_step;
frame_step = metadata.frame_step;

rCentrosome_px = metadata.centrosome_radius_px;
centrosome_radius_stacks = ceil(rCentrosome_px*metadata.px2um / z_step);


%% Default Masks Dimensions
lengthROI_px = ceil(5*rCentrosome_px); 
lengthROI_stacks = min(metadata.nStacks, ceil(3 * centrosome_radius_stacks)); 
kernelROI_XY = strel('rectangle',[lengthROI_px, lengthROI_px]);
kernelROI_Zproj = strel('rectangle',[lengthROI_stacks lengthROI_px]); % Region of Interest XZ for frame i+1

metadata.centrosome_radius_stacks = centrosome_radius_stacks;
metadata.lengthROI_px = lengthROI_px;
metadata.lengthROI_stacks = lengthROI_stacks;
metadata.kernelROI_XY = kernelROI_XY;
metadata.kernelROI_Zproj = kernelROI_Zproj;

%% Initial Masks - based on 2 Coords only:
[CS_mask_ROI_XY, CS_mask_ROI_XZ] = masks_2coords(X, Y, metadata);



function plot_frame_and_CS_coords(handles, Img_plot, CS_x_px, CS_y_px, CS_z_stack, mark)

plot_frame_projection(Img_plot, handles.XY_proj_axes, 3)
plot(CS_x_px(1), CS_y_px(1), ['r' mark], 'markersize', 10)
plot(CS_x_px(2), CS_y_px(2), ['b' mark], 'markersize', 10)
xlabel('X'), ylabel('Y')
set(handles.XY_proj_axes, 'fontsize', 7)
legend('CS 1', 'CS 2');

plot_frame_projection(Img_plot, handles.XZ_proj_axes, 1)
plot(CS_x_px(1), CS_z_stack(1), ['r' mark], 'markersize', 10)
plot(CS_x_px(2), CS_z_stack(2), ['b' mark], 'markersize', 10)
xlabel('X'), ylabel('Z')
set(handles.XZ_proj_axes, 'fontsize', 7)

plot_frame_projection(Img_plot, handles.YZ_proj_axes, 2)
plot(CS_y_px(1), CS_z_stack(1), ['r' mark], 'markersize', 10)
plot(CS_y_px(2), CS_z_stack(2), ['b' mark], 'markersize', 10)
xlabel('Y'), ylabel('Z')
set(handles.YZ_proj_axes, 'fontsize', 7)


% --- Executes during object creation, after setting all properties.
function XZ_proj_axes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XZ_proj_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate XZ_proj_axes


% --- Executes on button press in stop_button.
function stop_button_Callback(hObject, eventdata, handles)
% hObject    handle to stop_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setappdata(0, 'gui_track_stopTracking', true)

%% Update last frame box
metadata = getappdata(0, 'gui_metadata');
f = getappdata(0, 'gui_track_startingFrame');

if f > metadata.nFrames
% 	metadata.lastFrame = f;
    set(handles.last_frame_box, 'string', f)
end

%% Set buttons states:
handles.state = 0;
manage_buttons(handles)

% Update handles structure
guidata(hObject, handles);


function current_frame_text_Callback(hObject, eventdata, handles)
% hObject    handle to current_frame_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of current_frame_text as text
%        str2double(get(hObject,'String')) returns contents of current_frame_text as a double


% --- Executes during object creation, after setting all properties.
function current_frame_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to current_frame_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function resume_frame_text_Callback(hObject, eventdata, handles)
% hObject    handle to resume_frame_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of resume_frame_text as text
%        str2double(get(hObject,'String')) returns contents of resume_frame_text as a double
resumeFrame    = str2double(get(hObject,'String'));
ROI_pos = getappdata(0, 'gui_track_ROI_pos');

if resumeFrame <= length(ROI_pos.xi)
    if ~ROI_pos.xi(resumeFrame,1)
        m = msgbox('There is no region of interest for this frame. Analyse the previous frame first');
        waitfor(m)
        resumeFrame = getappdata(0, 'gui_track_startingFrame');
        set(hObject, 'String', resumeFrame)
    end
else
    resumeFrame = getappdata(0, 'gui_track_startingFrame');
    set(hObject, 'String', resumeFrame);
end

setappdata(0, 'gui_track_startingFrame', resumeFrame);


% --- Executes on button press in test_ROIs_button.
function test_ROIs_button_Callback(hObject, eventdata, handles)
% hObject    handle to test_ROIs_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% Load Variables:
imrect_ROIs = getappdata(0, 'gui_track_imrect_ROIs');
f = getappdata(0, 'gui_track_currentFrame');
metadata = getappdata(0, 'gui_metadata');
Img_C = getappdata(0, 'gui_Img_C');
CS_x_px = getappdata(0, 'gui_track_CS_x_px');
CS_y_px = getappdata(0, 'gui_track_CS_y_px');
CS_z_stack = getappdata(0, 'gui_track_CS_z_stack');
tracking_state = getappdata(0, 'gui_track_tracking_state');
frame_state_buttons = getappdata(0, 'gui_track_frame_state_buttons');
activatedFrames = getappdata(0, 'gui_track_activatedFrames');


%% Generate Masks:
CS_mask_ROI_XY(:,:,1) = from_ROI_rect_to_masks(imrect_ROIs.ROI_xy{1}, metadata.SizeX, metadata.SizeY);
CS_mask_ROI_XY(:,:,2) = from_ROI_rect_to_masks(imrect_ROIs.ROI_xy{2}, metadata.SizeX, metadata.SizeY);
CS_mask_ROI_XZ(:,:,1) = from_ROI_rect_to_masks(imrect_ROIs.ROI_xz{1}, metadata.SizeX, metadata.nStacks);
CS_mask_ROI_XZ(:,:,2) = from_ROI_rect_to_masks(imrect_ROIs.ROI_xz{2}, metadata.SizeX, metadata.nStacks);

%% Calculate New Coordinates of Centrosomes
CS_x_px_test = zeros(metadata.nFrames, 2);
CS_y_px_test = zeros(metadata.nFrames, 2);
CS_z_stack_test = zeros(metadata.nFrames, 2);
with_error = [0 0];

for c = 1:2
    [CS_x_px_test(f, c), CS_y_px_test(f, c),CS_z_stack_test(f, c), CS_mask_ROI_XY(:,:,c), CS_mask_ROI_XZ(:,:,c), danger, coordsFound]...
        = from_frame_to_CS_coords(Img_C(:,:,:,f), CS_mask_ROI_XY(:,:,c), CS_mask_ROI_XZ(:,:,c), metadata, handles.xy_borders);  

    [tracking_state, with_error(c)] = checkCoords(handles.warning_list, danger, coordsFound, tracking_state, c, f);
end

delete_ROIs_rects()
plot_frame_and_CS_coords(handles, Img_C(:,:,:,f), CS_x_px_test(f, :), CS_y_px_test(f, :), CS_z_stack_test(f, :), '*')
plot_ROIs(handles, 1);
plot_ROIs(handles, 2);

%% If it found all coordinates, ask to save:
if  sum(with_error) == 0
    answer = questdlg('Save new coordinates?');
    
    if strcmp(answer, 'Yes')        
        CS_x_px(f, :) = CS_x_px_test(f, :);
        CS_y_px(f, :) = CS_y_px_test(f, :);
        CS_z_stack(f, :) = CS_z_stack_test(f, :);
        setappdata(0, 'gui_track_CS_x_px', CS_x_px)
        setappdata(0, 'gui_track_CS_y_px', CS_y_px)
        setappdata(0, 'gui_track_CS_z_stack', CS_z_stack)
        
        % Store positions of Masks for next frame: masks positions are saved as positions from imrect:
        ROI_pos = getappdata(0, 'gui_track_ROI_pos');
        [ROI_pos.xi(f+1,:), ROI_pos.yi(f+1,:), ROI_pos.zi(f+1,:), ROI_pos.lx(f+1,:), ROI_pos.ly(f+1,:), ROI_pos.lz(f+1,:)]...
            = from_masks_to_ROI_pos(CS_mask_ROI_XY , CS_mask_ROI_XZ);        
        setappdata(0, 'gui_track_to_save', 1)
    else
        % if the user does not save, ROIs return to original position
        ROI_pos = getappdata(0, 'gui_track_ROI_pos_orig');
    end
   
    setappdata(0, 'gui_track_ROI_pos', ROI_pos);
end

%% Set state
handles.state = 0;
manage_buttons(handles)

%% Update frame state buttons
tracking_state = from_CS_state_to_frame_state(f, tracking_state);
update_button_color(frame_state_buttons, f, tracking_state.frame_states, activatedFrames,  true)
setappdata(0, 'gui_track_tracking_state', tracking_state)

%% Plot new frame
delete_ROIs_rects()
plot_frame_and_CS_coords(handles, Img_C(:,:,:,f), CS_x_px(f,:), CS_y_px(f,:), CS_z_stack(f,:), '.')

% Update handles structure
guidata(hObject, handles);


% --- Executes on selection change in warning_list.
function warning_list_Callback(hObject, eventdata, handles)
% hObject    handle to warning_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns warning_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from warning_list


% --- Executes during object creation, after setting all properties.
function warning_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to warning_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in show_ROIs_button.
function show_ROIs_button_Callback(hObject, eventdata, handles)
% hObject    handle to show_ROIs_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.state == 0 % ROIs button is in "Show" mode
    
    noROI1 = plot_ROIs(handles, 1);
    noROI2 = plot_ROIs(handles, 2);
    
    if noROI1 || noROI2
        msgbox('No ROIs for this Frame.');
    else
        % Set buttons states:
        handles.state = 2;
        manage_buttons(handles)
    end
    
else % ROIs button is in "Hide" mode
    
    delete_ROIs_rects()
    handles.state = 0;
    manage_buttons(handles)
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in change_CS_coords.
function change_CS_coords_Callback(hObject, eventdata, handles)
% hObject    handle to change_CS_coords (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tracking_state = getappdata(0, 'gui_track_tracking_state');
f = getappdata(0, 'gui_track_currentFrame');
frame_state = tracking_state.frame_states(f);

if handles.state == 0 && frame_state ~= 5 % Show Mode, and frame without error
    
    noCS1 = plot_draggable_CS(handles, 1);
    noCS2 = plot_draggable_CS(handles, 2);
    
    if noCS1 || noCS2
        msgbox('No centrosomes for this Frame - it may not have been analysed yet')
    else        
        % Set state:
        handles.state = 3;
        manage_buttons(handles)        
    end

elseif frame_state ~= 5 % Cancel Mode (frame without error)
    handles.state = 0;
    manage_buttons(handles)
    
    CS_x_px_temp = getappdata(0, 'gui_track_CS_x_px');
    CS_y_px_temp = getappdata(0, 'gui_track_CS_y_px');
    CS_z_stack_temp = getappdata(0, 'gui_track_CS_z_stack');
    
    setappdata(0, 'gui_track_CS_x_px_temp', CS_x_px_temp)
    setappdata(0, 'gui_track_CS_y_px_temp', CS_y_px_temp)
    setappdata(0, 'gui_track_CS_z_stack_temp', CS_z_stack_temp)
    
    delete_CS_points()
    clear_temp_CS()
else
    msgbox('Error in this frame. Centrosomes coordinates were not determined yet. Try to adjust ROIs')
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in save_CS_coords.
function save_CS_coords_Callback(hObject, eventdata, handles)
% hObject    handle to save_CS_coords (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% Set State:
handles.state = 0;
manage_buttons(handles)

%% Load Variables:
Img_C = getappdata(0, 'gui_Img_C');
metadata = getappdata(0, 'gui_metadata');
f = getappdata(0, 'gui_track_currentFrame');
ROI_pos = getappdata(0, 'gui_track_ROI_pos');
CS_dragged = getappdata(0,'gui_track_CS_dragged');
CS_x_px = getappdata(0, 'gui_track_CS_x_px_temp');
CS_y_px = getappdata(0, 'gui_track_CS_y_px_temp');
CS_z_stack = getappdata(0, 'gui_track_CS_z_stack_temp');
tracking_state = getappdata(0, 'gui_track_tracking_state');
frame_state_buttons = getappdata(0, 'gui_track_frame_state_buttons');
activatedFrames = getappdata(0, 'gui_track_activatedFrames');

%% Define masks for next frame - based on 3 Coords:
[CS_mask_ROI_XY(:,:,1), CS_mask_ROI_XZ(:,:,1)] = from_CS_coords_to_masks(CS_x_px(f,1), CS_y_px(f,1), CS_z_stack(f,1), metadata);
[CS_mask_ROI_XY(:,:,2), CS_mask_ROI_XZ(:,:,2)] = from_CS_coords_to_masks(CS_x_px(f,2), CS_y_px(f,2), CS_z_stack(f,2), metadata);

%% Calculate ROIs positions for next frame based on masks:
[ROI_pos.xi(f+1,:), ROI_pos.yi(f+1,:), ROI_pos.zi(f+1,:), ROI_pos.lx(f+1,:), ROI_pos.ly(f+1,:), ROI_pos.lz(f+1,:)]...
    = from_masks_to_ROI_pos(CS_mask_ROI_XY , CS_mask_ROI_XZ);

%% Plot Frame:
delete_CS_points()
clear_temp_CS()
plot_frame_and_CS_coords(handles, Img_C(:,:,:,f), CS_x_px(f,:), CS_y_px(f,:), CS_z_stack(f,:), '.')

%% Update buttons states
tracking_state.CS_states(f, CS_dragged) = 4; % state 4 - Manual
tracking_state = from_CS_state_to_frame_state(f, tracking_state);
update_button_color(frame_state_buttons, f, tracking_state.frame_states, activatedFrames,  true)
setappdata(0, 'gui_track_tracking_state', tracking_state)

%% Set Data:
setappdata(0, 'gui_track_ROI_pos', ROI_pos)
setappdata(0, 'gui_track_CS_x_px', CS_x_px)
setappdata(0, 'gui_track_CS_y_px', CS_y_px)
setappdata(0, 'gui_track_CS_z_stack', CS_z_stack)
setappdata(0, 'gui_track_to_save', 1)
% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in cancel_CS_coords.
function cancel_CS_coords_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_CS_coords (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.state = 0;
manage_buttons(handles)

CS_x_px_temp = getappdata(0, 'gui_track_CS_x_px');
CS_y_px_temp = getappdata(0, 'gui_track_CS_y_px');
CS_z_stack_temp = getappdata(0, 'gui_track_CS_z_stack');

setappdata(0, 'gui_track_CS_x_px_temp', CS_x_px_temp)
setappdata(0, 'gui_track_CS_y_px_temp', CS_y_px_temp)
setappdata(0, 'gui_track_CS_z_stack_temp', CS_z_stack_temp)

delete_CS_points()
clear_temp_CS()

% Update handles structure
guidata(hObject, handles);


function manage_buttons(handles)

% save_CS_coords is only enabled when centrosomes are release in release_CS.m

state = handles.state;
frame_state_buttons = getappdata(0, 'gui_track_frame_state_buttons');
results_available = getappdata(0, 'gui_track_results_available');

if state == 0 % Stopped - no ROIs - no CSs
    
    set(handles.run_button, 'enable', 'on')
    set(handles.stop_button, 'enable', 'off')
    set(handles.show_ROIs_button, 'enable', 'on'), set(handles.show_ROIs_button, 'String', 'Show')
    set(handles.test_ROIs_button, 'enable', 'off')
    set(handles.change_CS_coords, 'Enable', 'on', 'String', 'Show')
    set(handles.save_CS_coords, 'Enable', 'off')
    set(handles.left_button, 'Enable', 'on')
    set(handles.right_button, 'Enable', 'on')
    set(frame_state_buttons, 'Enable', 'on')
    set(handles.settings_button, 'Enable', 'on')
    set(handles.remove_button, 'Enable', 'on')
    set(handles.restore_button, 'Enable', 'on')    
    set(handles.menu_button, 'Enable', 'on') 
    
    if results_available
         set(handles.results_button, 'Enable', 'on')
    end
    update_menu_buttons([])
    
elseif state == 1 % Running
    
    set(handles.run_button, 'enable', 'off')
    set(handles.stop_button, 'enable', 'on')
    set(handles.show_ROIs_button, 'enable', 'off')
    set(handles.test_ROIs_button, 'enable', 'off')
    set(handles.change_CS_coords, 'Enable', 'off')
    set(handles.save_CS_coords, 'Enable', 'off')
    set(handles.left_button, 'Enable', 'off')
    set(handles.right_button, 'Enable', 'off')
    set(frame_state_buttons, 'Enable', 'off')
    set(handles.settings_button, 'Enable', 'off')
    set(handles.remove_button, 'Enable', 'off')
    set(handles.restore_button, 'Enable', 'off')
    set(handles.results_button, 'Enable', 'off')  
    set(handles.menu_button, 'Enable', 'off') 
    lock_menu_buttons
    
elseif state == 2 % Stopped - with ROIs - no CSs
    
    set(handles.run_button, 'enable', 'off')
    set(handles.stop_button, 'enable', 'off')
    set(handles.show_ROIs_button, 'enable', 'on'), set(handles.show_ROIs_button, 'String', 'Cancel')
    set(handles.test_ROIs_button, 'enable', 'on')
    set(handles.change_CS_coords, 'Enable', 'off')
    set(handles.save_CS_coords, 'Enable', 'off')
    set(handles.left_button, 'Enable', 'off')
    set(handles.right_button, 'Enable', 'off')
    set(frame_state_buttons, 'Enable', 'off')
    set(handles.settings_button, 'Enable', 'off')
    set(handles.remove_button, 'Enable', 'off')
    set(handles.restore_button, 'Enable', 'off')
    set(handles.results_button, 'Enable', 'off')  
    set(handles.menu_button, 'Enable', 'off') 
    
elseif state == 3 % Stopped - no ROIs - with CSs
    
    set(handles.run_button, 'enable', 'off')
    set(handles.stop_button, 'enable', 'off')
    set(handles.show_ROIs_button, 'enable', 'off')
    set(handles.test_ROIs_button, 'enable', 'off')
    set(handles.change_CS_coords, 'Enable', 'on', 'string', 'Cancel')
    set(handles.save_CS_coords, 'Enable', 'off')
    set(handles.left_button, 'Enable', 'off')
    set(handles.right_button, 'Enable', 'off')
    set(frame_state_buttons, 'Enable', 'off')
    set(handles.settings_button, 'Enable', 'off')
    set(handles.remove_button, 'Enable', 'off')
    set(handles.restore_button, 'Enable', 'off')
    set(handles.results_button, 'Enable', 'off')  
    set(handles.menu_button, 'Enable', 'off') 
end


function delete_ROIs_rects()

imrect_ROIs = getappdata(0,'gui_track_imrect_ROIs');
roi_ids = getappdata(0, 'gui_track_roi_ids');
for CS = 1:2
    delete(imrect_ROIs.ROI_xy{CS})
    delete(imrect_ROIs.ROI_xz{CS})
    delete(imrect_ROIs.ROI_yz{CS})
    roi_ids.id_xy{CS} = [];
    roi_ids.id_xz{CS} = [];
    roi_ids.id_yz{CS} = [];
end


function delete_CS_points()

impoint_CS = getappdata(0, 'gui_track_impoint_CS');
for CS = 1:2
    delete(impoint_CS.CS_xy{CS})
    delete(impoint_CS.CS_xz{CS})
    delete(impoint_CS.CS_yz{CS})
end


function [tracking_state, tracking_error] = checkCoords(warning_list, warning_flag, coordsFound, tracking_state, c, f)

tracking_error = 0;

% Warning when centrosome if out of borders:
if warning_flag
    warnings = getappdata(0, 'gui_track_warnings');
    warnings = [{['Centrosome ' num2str(c) ' may exceed boundaries in frame ' num2str(f)]} warnings];
    set(warning_list,'String', warnings);
    setappdata(0, 'gui_track_warnings', warnings)        
end

msg_coord = [];
show_msg = 0;

% Message box if any coordinate was not found
if ~coordsFound.X
    msg_coord = ' X ';
    show_msg = 1;
end

if ~coordsFound.Y
    msg_coord = [msg_coord ' Y '];
    show_msg = 1;
end

if ~coordsFound.Z
    msg_coord = [msg_coord ' Z '];
    show_msg = 1;
end

if show_msg
    m = msgbox(['Error in frame ' num2str(f) ': ' msg_coord ' not found for centrosome ' num2str(c) '. Try a larger ROI for this centrosome']);
    waitfor(m)
    tracking_error = 1;
end

%%  Update tracking centrosome state:
% state colors:
%               1 - empty   
%               2 - good    
%               3 - warning
%               4 - manual 
%               5 - error
if warning_flag
    tracking_state.CS_states(f,c) = 3; % warning state
elseif tracking_error
    if tracking_state.CS_states(f,c) == 1
    tracking_state.CS_states(f,c) = 5; % error state
    end
else
    tracking_state.CS_states(f,c) = 2; % good state
end



function click_frame_button(hObject, ~, handles, f)

Img_C = getappdata(0, 'gui_Img_C');
CS_x_px = getappdata(0, 'gui_track_CS_x_px');
CS_y_px = getappdata(0, 'gui_track_CS_y_px');
CS_z_stack = getappdata(0, 'gui_track_CS_z_stack');
tracking_state = getappdata(0, 'gui_track_tracking_state');
remove_frames_state = getappdata(0, 'gui_track_remove_frames_state');
activatedFrames = getappdata(0, 'gui_track_activatedFrames');
    
if remove_frames_state ~= 0
    
    if remove_frames_state == 1
        activatedFrames(f) = 0; % Deactivate frame
    else
        activatedFrames(f) = 1; % Restore frame  
    end
    setappdata(0, 'gui_track_activatedFrames', activatedFrames)
    setappdata(0, 'gui_track_to_save', 1)
end

update_current_frame(handles, Img_C(:,:,:,f), CS_x_px(f,:), CS_y_px(f,:), CS_z_stack(f,:), f, tracking_state, activatedFrames, hObject);

 
function tracking_state = update_current_frame(handles, frame_to_plot, CS_x_px, CS_y_px, CS_z_stack, f, tracking_state, activatedFrames, buttonObject)

%% Update Frame State (good, warning, manual):
tracking_state = from_CS_state_to_frame_state(f, tracking_state);

%% Update frame button:
if isempty(buttonObject) 
% Update frame button
button_tag = ['button_' num2str(f)];
buttonObject = findobj('Tag', button_tag);
end

frame_state_buttons = getappdata(0, 'gui_track_frame_state_buttons');
update_frame_button(buttonObject, frame_state_buttons, f, tracking_state.frame_states, activatedFrames);

%% Plot frame and coordinates
plot_frame_and_CS_coords(handles, frame_to_plot, CS_x_px, CS_y_px, CS_z_stack, '.');

%% Set Current Frames
setappdata(0, 'gui_track_currentFrame', f)
set(handles.current_frame_text,'string', f)


% --- Executes on button press in left_button.
function left_button_Callback(hObject, eventdata, handles)
% hObject    handle to left_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Img_C = getappdata(0, 'gui_Img_C');
CS_x_px = getappdata(0, 'gui_track_CS_x_px');
CS_y_px = getappdata(0, 'gui_track_CS_y_px');
CS_z_stack = getappdata(0, 'gui_track_CS_z_stack');
tracking_state = getappdata(0, 'gui_track_tracking_state');
activatedFrames = getappdata(0, 'gui_track_activatedFrames');
f = getappdata(0, 'gui_track_currentFrame');
f = max(1, f-1);

update_current_frame(handles, Img_C(:,:,:,f), CS_x_px(f,:), CS_y_px(f,:), CS_z_stack(f,:), f, tracking_state, activatedFrames, []);



function right_button_Callback(hObject, eventdata, handles)
% hObject    handle to left_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Img_C = getappdata(0, 'gui_Img_C');
CS_x_px = getappdata(0, 'gui_track_CS_x_px');
CS_y_px = getappdata(0, 'gui_track_CS_y_px');
CS_z_stack = getappdata(0, 'gui_track_CS_z_stack');
tracking_state = getappdata(0, 'gui_track_tracking_state');
metadata = getappdata(0, 'gui_metadata');
activatedFrames = getappdata(0, 'gui_track_activatedFrames');
f = getappdata(0, 'gui_track_currentFrame');
f = min(metadata.nFrames, f+1);

update_current_frame(handles, Img_C(:,:,:,f), CS_x_px(f,:), CS_y_px(f,:), CS_z_stack(f,:), f, tracking_state, activatedFrames, []);



% --- Executes on button press in results_button.
function results_button_Callback(hObject, eventdata, handles)
% hObject    handle to results_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    close(m)
catch
end

update_menu_buttons([]);
close(GUI_TrackCentrosomes)
GUI_Tracking_Results


% --- Executes on button press in settings_button.
function settings_button_Callback(hObject, eventdata, handles)
% hObject    handle to settings_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GUI_Track_Settings



function last_frame_box_Callback(hObject, eventdata, handles)
tracking_state = getappdata(0, 'gui_track_tracking_state');
frame_state_buttons = getappdata(0, 'gui_track_frame_state_buttons');
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
setappdata(0, 'gui_track_to_save', 1)
update_button_color(frame_state_buttons, frames, tracking_state.frame_states, activatedFrames, false)    
% update_plots(handles, frames, 1, activatedFrames)




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

last_activated_frame = getappdata(0, 'gui_track_last_activated_frame');
if isempty(last_activated_frame)
    metadata = getappdata(0, 'gui_metadata');
    set(hObject, 'string', metadata.nFrames)
else
    set(hObject, 'string', last_activated_frame)
end


function first_frame_box_Callback(hObject, eventdata, handles)

tracking_state = getappdata(0, 'gui_track_tracking_state');
frame_state_buttons = getappdata(0, 'gui_track_frame_state_buttons');
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
setappdata(0, 'gui_track_to_save', 1)
update_button_color(frame_state_buttons, frames, tracking_state.frame_states, activatedFrames, false)    
% update_plots(handles, frames, 1, activatedFrames)


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

first_activated_frame = getappdata(0, 'gui_track_first_activated_frame');
if isempty(first_activated_frame)
    set(hObject, 'string', 1)
else
    set(hObject, 'string', first_activated_frame)
end

% --- Executes during object creation, after setting all properties.
function resume_frame_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to resume_frame_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
startingFrame = getappdata(0, 'gui_track_startingFrame');
set(hObject, 'string', startingFrame)


% --- Executes on button press in remove_button.
function remove_button_Callback(hObject, eventdata, handles)
% Remove States:
%       0: doing nothing
%       1: removing frames
%       2: restoring frames
remove_frames_state = getappdata(0, 'gui_track_remove_frames_state');
blue = getappdata(0, 'gui_color_1');

if remove_frames_state == 0  
    remove_frames_state = 1; % Removing 
    set(hObject, 'backgroundcolor', blue)
elseif remove_frames_state == 1
    remove_frames_state = 0; % Doing Nothing
    set(hObject, 'backgroundcolor', [0.94 0.94 0.94])
else
    remove_frames_state = 1; % Removing 
    set(hObject, 'backgroundcolor', blue)
    set(handles.restore_button, 'backgroundcolor', [0.94 0.94 0.94])
end    
setappdata(0, 'gui_track_remove_frames_state', remove_frames_state)


% --- Executes on button press in restore_button.
function restore_button_Callback(hObject, eventdata, handles)
% Remove States:
%       0: doing nothing
%       1: removing frames
%       2: restoring frames
remove_frames_state = getappdata(0, 'gui_track_remove_frames_state');
blue = getappdata(0, 'gui_color_1');

if remove_frames_state == 0  
    remove_frames_state = 2; % Restoring 
    set(hObject, 'backgroundcolor', blue)
elseif remove_frames_state == 2
    remove_frames_state = 0; % Doing Nothing
    set(hObject, 'backgroundcolor', [0.94 0.94 0.94])
else
    remove_frames_state = 2; % Removing
    set(hObject, 'backgroundcolor', blue)
    set(handles.remove_button, 'backgroundcolor', [0.94 0.94 0.94])
end    
setappdata(0, 'gui_track_remove_frames_state', remove_frames_state)


% --- Executes on button press in menu_button.
function menu_button_Callback(hObject, eventdata, handles)
% hObject    handle to menu_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(GUI_TrackCentrosomes)
GUI_Main_Menu
