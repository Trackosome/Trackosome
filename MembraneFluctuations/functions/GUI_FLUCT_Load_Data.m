function varargout = GUI_FLUCT_Load_Data(varargin)
% GUI_FLUCT_LOAD_DATA MATLAB code for GUI_FLUCT_Load_Data.fig
%      GUI_FLUCT_LOAD_DATA, by itself, creates a new GUI_FLUCT_LOAD_DATA or raises the existing
%      singleton*.
%
%      H = GUI_FLUCT_LOAD_DATA returns the handle to a new GUI_FLUCT_LOAD_DATA or the handle to
%      the existing singleton*.
%
%      GUI_FLUCT_LOAD_DATA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_FLUCT_LOAD_DATA.M with the given input arguments.
%
%      GUI_FLUCT_LOAD_DATA('Property','Value',...) creates a new GUI_FLUCT_LOAD_DATA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_FLUCT_Load_Data_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_FLUCT_Load_Data_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only
%      oneload_data
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_FLUCT_Load_Data

% Last Modified by GUIDE v2.5 22-Apr-2020 20:19:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GUI_FLUCT_Load_Data_OpeningFcn, ...
    'gui_OutputFcn',  @GUI_FLUCT_Load_Data_OutputFcn, ...
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



% --- Executes just before GUI_FLUCT_Load_Data is made visible.
function GUI_FLUCT_Load_Data_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_FLUCT_Load_Data (see VARARGIN)

set(hObject, 'Name', 'Membrane Segmentation');

% Choose default command line output for GUI_FLUCT_Load_Data
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%
% UIWAIT makes GUI_FLUCT_Load_Data wait for user response (see UIRESUME)
% uiwait(handles.figure1);

 set(hObject,'CloseRequestFcn', @seg_memb_closereq)

%%
%% Default Settings:
settings = getappdata(0, 'gui_main_fluct_settings');
if isempty(settings)
    settings.nPoints = 500; % nr of points in membranes
    settings.seg_smoothness = 10; % smoothness level of frame membranes
    settings.img_filt_size = 3; % side of median filter for images
    settings.ref_smoothness = 10; % smoothness level of reference membrane
    settings.space_time_filt = [1 1]; % size of gauss filter for fluctuations map [space_filt time_filt]
    setappdata(0, 'gui_main_fluct_settings', settings);
end

% States:
%       0 - load data
%       1 - loaded
%       2 - cropping
%       3 - segmenting membranes
%       4 - ready to proceed

I = getappdata(0, 'gui_fluct_I');
memb_coords = getappdata(0, 'gui_fluct_memb_coords');

if isempty(I)
    state = 0;   
else 
    if ~isempty(memb_coords)        
        state = 5; % ready for next
        initialize_img(I, handles)
        hold(handles.img_axes, 'on')
        plot(memb_coords(:,1,1), memb_coords(:,2,1), 'k', 'linewidth', 1)
        
    else
        state = 1; % img is already loaded
        initialize_img(I, handles)
    end
end

masks = getappdata(0, 'gui_fluct_masks');
if isempty(masks)
    metadata = getappdata(0, 'gui_fluct_metadata');
    setappdata(0, 'gui_fluct_masks', cell(metadata.nFrames, 1))
end

manage_buttons(handles, state);
setappdata(0, 'gui_fluct_Load_state', state)


%% Add subfolders:
folder = fileparts(which(mfilename));
addpath(genpath(folder));


% --- Outputs from this function are returned to the command line.
function varargout = GUI_FLUCT_Load_Data_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function initialize_img(I, handles)

axes(handles.img_axes)
imagesc(I(:,:,1))
colormap(handles.img_axes, 'jet')
set(handles.img_axes,'DataAspectRatio', [1 1 1]);
[~,~,nFrames] = size(I);

smallstep = 1/(nFrames-1);
largestep = smallstep*10;
h_slider = handles.slider;
set(h_slider,'BackgroundColor',[.9 .9 .9], 'Value', 1, 'Min', 1, 'Max', nFrames, ...
    'SliderStep', [smallstep largestep] );
addlistener(h_slider,'Value','PostSet',@slider_listener);

setappdata(0, 'gui_fluct_Load_current_frame', 1)



% --- Executes on button press in menu_button.
function menu_button_Callback(hObject, eventdata, handles)
% hObject    handle to menu_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GUI_FLUCT_Main_menu


% --- Executes on button press in metadata_button.
function metadata_button_Callback(hObject, eventdata, handles)
% hObject    handle to metadata_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
metadataInput([]);



% --- Executes on button press in crop_button.
function crop_button_Callback(hObject, eventdata, handles)
% hObject    handle to crop_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

manage_buttons(handles, 2) % --> Cropping

% Show Projection :
I = getappdata(0, 'gui_fluct_I');
Iproj = squeeze(median( I, 3));
show_img(Iproj, handles.img_axes)

% Rectangles:
h_rect = imrect(handles.img_axes);

manage_buttons(handles, 3) % Save/Cancel cropping

setappdata(0, 'gui_fluct_Load_state', 3)
handles.h_rect  = h_rect ;
guidata(hObject, handles)



% --- Executes on button press in save_crop_button.
function save_crop_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_crop_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

memb_coords = getappdata(0, 'gui_fluct_memb_coords');
answer = '';
if ~isempty(memb_coords)
    answer = questdlg('Membrane Coordinates will be deleted. Want to proceed?');
end

if ~strcmp(answer, 'No')
    
    I = getappdata(0, 'gui_fluct_I');
    metadata = getappdata(0, 'gui_fluct_metadata');
    
    % Select part of the image
    h_rect = handles.h_rect;
    pos_rect = h_rect.getPosition();
    pos_rect = ceil(pos_rect);
    [nlines, ncols] = size(I(:,:, 1));
    
    % Cut image
    li = max(pos_rect(2), 1);
    lf = min(pos_rect(2) + pos_rect(4), nlines);
    ci = max(pos_rect(1), 1);
    cf = min(pos_rect(1) + pos_rect(3), ncols);
    I = I(li:lf, ci:cf, :);
       
    [metadata.SizeY, metadata.SizeX, ~, ~] = size(I);
    
    setappdata(0, 'gui_fluct_memb_coords', [])
    setappdata(0, 'gui_fluct_metadata', metadata)
    setappdata(0, 'gui_fluct_I', I)
    
    % Show
    f = getappdata(0, 'gui_fluct_Load_current_frame');
    show_img(I(:,:,f), handles.img_axes)
    delete(h_rect)
end

%       0 - load data
%       1 - loaded
%       2 - cropping
%       3 - segmenting membranes
%       4 - ready to proceed

if strcmp(answer, 'No') % it kept the membranes so remains in state 4
    state = 4; % Ready to proceed
    
else % it didn't segment yet or deleted the membrane, so goes to state 1
    state = 1;
end
manage_buttons(handles, state)
setappdata(0, 'gui_fluct_Load_state', state)

guidata(hObject, handles)




% --- Executes on button press in cancel_crop_button.
function cancel_crop_button_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_crop_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h_rect = handles.h_rect;
delete(h_rect)

% Show image
I = getappdata(0, 'gui_fluct_I');
f = getappdata(0, 'gui_fluct_Load_current_frame');
show_img(I(:,:,f), handles.img_axes)

manage_buttons(handles, 1) % state = 1 --> go back to previous state after cropping
guidata(hObject, handles)



% --- Executes on slider movement.
function slider_Callback(hObject, eventdata, handles)
% hObject    handle to slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
% sliderCall(hObject, eventdata, handles)


function slider_listener(hObject, eventdata)
handles = guidata(eventdata.AffectedObject);
I = getappdata(0, 'gui_fluct_I');

frame = round(get(eventdata.AffectedObject,'Value'));
show_img(I(:,:,frame), handles.img_axes)

set(handles.img_axes,'DataAspectRatio', [1 1 1]);
set(handles.current_frame_text, 'string', frame)
setappdata(0, 'gui_fluct_Load_current_frame', frame)



% --- Executes during object creation, after setting all properties.
function slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end




% % function slider_Listener
% % I = getappdata(0, 'gui_fluct_I');
% % memb_coords = getappdata(0, 'gui_fluct_memb_coords');
% %
% % frame = round(get(hObject,'Value'));
% % axes(handles.img_axes)
% % imagesc(I(:,:,frame)), hold on
% % plot(memb_coords(:,1,frame), memb_coords(:,2,frame))
% % axis equal
% % set(handles.current_frame_text, 'string', frame)
% % setappdata(0, 'gui_fluct_Load_current_frame', frame)




function manage_buttons(handles, state)

%       0 - load data
%       1 - loaded
%       2 - cropping
%       3 - save cropping
%       4 - segmenting membranes
%       5 - ready to proceed

colors = getappdata(0, 'gui_colors_fluct');

if state == 0 % Load Data
    set(handles.metadata_button, 'enable', 'off')
    set(handles.results_button, 'enable', 'off', 'backgroundcolor', colors.normal)
    set(handles.crop_button, 'enable', 'off')
    set(handles.save_crop_button, 'enable', 'off')
    set(handles.cancel_crop_button, 'enable', 'off')
    set(handles.slider, 'enable', 'off')
    set(handles.draw_region_button, 'enable', 'off')
    set(handles.cancel_remove_button, 'enable', 'off')
    set(handles.remove_button, 'enable', 'off')
    set(handles.segment_all, 'enable', 'off')
    set(handles.break_button, 'enable', 'off')
    set(handles.draw_mask_button, 'enable', 'off')
    set(handles.preview_button, 'enable', 'off')
    set(handles.reset_view_button, 'enable', 'off')
    
elseif state == 1 % Loaded
    set(handles.metadata_button, 'enable', 'on')
    set(handles.results_button, 'enable', 'off', 'backgroundcolor', colors.normal)
    set(handles.crop_button, 'enable', 'on')
    set(handles.save_crop_button, 'enable', 'off')
    set(handles.cancel_crop_button, 'enable', 'off')
    set(handles.slider, 'enable', 'on')
    set(handles.draw_region_button, 'enable', 'on')
    set(handles.cancel_remove_button, 'enable', 'off')
    set(handles.remove_button, 'enable', 'off')
    set(handles.segment_all, 'enable', 'on', 'backgroundcolor', colors.ready)
    set(handles.break_button, 'enable', 'off', 'backgroundcolor', colors.normal)
    set(handles.draw_mask_button, 'enable', 'on')
    set(handles.preview_button, 'enable', 'on')
    set(handles.reset_view_button, 'enable', 'on')
    
elseif state == 2 % Cropping
    set(handles.metadata_button, 'enable', 'off')
    set(handles.results_button, 'enable', 'off')
    set(handles.crop_button, 'enable', 'off')
    set(handles.save_crop_button, 'enable', 'off')
    set(handles.cancel_crop_button, 'enable', 'off')
    set(handles.slider, 'enable', 'off')
    set(handles.draw_region_button, 'enable', 'off')
    set(handles.cancel_remove_button, 'enable', 'off')
    set(handles.remove_button, 'enable', 'off')
    set(handles.segment_all, 'enable', 'off')
    set(handles.break_button, 'enable', 'off')
    set(handles.draw_mask_button, 'enable', 'off')
    set(handles.preview_button, 'enable', 'off')
    set(handles.reset_view_button, 'enable', 'off')
    
elseif state == 3 % Save Crop?
    set(handles.metadata_button, 'enable', 'off')
    set(handles.results_button, 'enable', 'off')
    set(handles.crop_button, 'enable', 'off')
    set(handles.save_crop_button, 'enable', 'on')
    set(handles.cancel_crop_button, 'enable', 'on')
    set(handles.slider, 'enable', 'off')
    set(handles.draw_region_button, 'enable', 'off')
    set(handles.remove_button, 'enable', 'off')
    set(handles.cancel_remove_button, 'enable', 'off')
    set(handles.segment_all, 'enable', 'off')
    set(handles.break_button, 'enable', 'off')
    set(handles.draw_mask_button, 'enable', 'off')
    set(handles.preview_button, 'enable', 'off')
    set(handles.reset_view_button, 'enable', 'off')
    
elseif state == 4 % Segmenting Membranes
    set(handles.metadata_button, 'enable', 'off')
    set(handles.results_button, 'enable', 'off', 'backgroundcolor', colors.normal)
    set(handles.crop_button, 'enable', 'off')
    set(handles.save_crop_button, 'enable', 'off')
    set(handles.cancel_crop_button, 'enable', 'off')
    set(handles.slider, 'enable', 'off')
    set(handles.draw_region_button, 'enable', 'off')
    set(handles.remove_button, 'enable', 'off')
    set(handles.cancel_remove_button, 'enable', 'off')
    set(handles.segment_all, 'enable', 'off', 'backgroundcolor', colors.normal)
    set(handles.break_button, 'enable', 'on', 'backgroundcolor', colors.stop)
    set(handles.draw_mask_button, 'enable', 'off')
    set(handles.preview_button, 'enable', 'off')
    set(handles.reset_view_button, 'enable', 'off')
    
elseif state == 5 % Ready for Next!
    set(handles.metadata_button, 'enable', 'on')
    set(handles.results_button, 'enable', 'on', 'backgroundcolor', colors.ready)
    set(handles.crop_button, 'enable', 'on')
    set(handles.save_crop_button, 'enable', 'off')
    set(handles.cancel_crop_button, 'enable', 'off')
    set(handles.slider, 'enable', 'on')
    set(handles.draw_region_button, 'enable', 'on')
    set(handles.remove_button, 'enable', 'off')
    set(handles.cancel_remove_button, 'enable', 'off')
    set(handles.segment_all, 'enable', 'on')
    set(handles.break_button, 'enable', 'off', 'backgroundcolor', colors.normal)
    set(handles.draw_mask_button, 'enable', 'on')
    set(handles.preview_button, 'enable', 'on')
    set(handles.reset_view_button, 'enable', 'on')
    
end


% --- Executes on button press in draw_region_button.
function draw_region_button_Callback(hObject, eventdata, handles)
% hObject    handle to draw_region_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
draw_region_button_call(handles.img_axes)
frame = getappdata(0, 'gui_fluct_Load_current_frame');
set(handles.remove_button, 'enable', 'on')
set(handles.cancel_remove_button, 'enable', 'on')
set(handles.first_frame_remove_region, 'enable', 'on', 'string', num2str(frame))
set(handles.last_frame_remove_region, 'enable', 'on', 'string', num2str(frame))


function first_frame_remove_region_Callback(hObject, eventdata, handles)
% hObject    handle to first_frame_remove_region (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of first_frame_remove_region as text
%        str2double(get(hObject,'String')) returns contents of first_frame_remove_region as a double
lastFrame = str2double(get(handles.last_frame_remove_region, 'string'));
firstFrame = str2double(get(hObject, 'string'));

if firstFrame > lastFrame
    firstFrame = lastFrame;
elseif firstFrame < 1
    firstFrame = 1 ;
end
set(hObject, 'string', num2str(firstFrame))



% --- Executes during object creation, after setting all properties.
function first_frame_remove_region_CreateFcn(hObject, eventdata, handles)
% hObject    handle to first_frame_remove_region (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function last_frame_remove_region_Callback(hObject, eventdata, handles)
% hObject    handle to last_frame_remove_region (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of last_frame_remove_region as text
%        str2double(get(hObject,'String')) returns contents of last_frame_remove_region as a double
lastFrame = str2double(get(hObject, 'string'));
firstFrame = str2double(get(handles.first_frame_remove_region, 'string'));
metadata = getappdata(0, 'gui_fluct_metadata');

if lastFrame > metadata.nFrames
    lastFrame = metadata.nFrames;
elseif lastFrame < firstFrame
    lastFrame = firstFrame  ;
end
set(hObject, 'string', num2str(lastFrame))



% --- Executes during object creation, after setting all properties.
function last_frame_remove_region_CreateFcn(hObject, eventdata, handles)
% hObject    handle to last_frame_remove_region (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in remove_button.
function remove_button_Callback(hObject, eventdata, handles)
% hObject    handle to remove_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

I = getappdata(0, 'gui_fluct_I');
remove_mask = getappdata(0, 'gui_fluct_remove_mask');

[I_cut, ~] = cut_region_call(handles, I, remove_mask);

first_f =  get(handles.first_frame_remove_region, 'string');
last_f =  get(handles.last_frame_remove_region, 'string');

message = ['The selected region will be delected between frames ', first_f ' and ' last_f '. Want to proceed?'];

answer = questdlg(message);
if strcmp(answer, 'Yes')
    setappdata(0, 'gui_fluct_I', I_cut);
    show_img(I_cut(:,:,str2double(first_f)), handles.img_axes)
    
    % If there is a mask in the frames, remove the region from the masks:
    masks = getappdata(0, 'gui_fluct_masks');
    for f = str2double(first_f):str2double(last_f)
        if ~isempty(masks{f})
            masks{f} = masks{f} .* ~remove_mask;
        end
    end
    setappdata(0, 'gui_fluct_masks', masks);
    
end
set(handles.remove_button, 'enable', 'off')
set(handles.cancel_remove_button, 'enable', 'off')
set(handles.first_frame_remove_region, 'enable', 'off')
set(handles.last_frame_remove_region, 'enable', 'off')

% function set_all_app_data(gui_fluct)
%
% setappdata(0, 'gui_fluct_metadata', gui_fluct.metadata);
% setappdata(0, 'gui_fluct_I', gui_fluct.I);
% setappdata(0, 'gui_fluct_results_centered_I', gui_fluct.centered_I );
% setappdata(0, 'gui_fluct_results_centered_memb_coords', gui_fluct.centered_memb_coords);
% setappdata(0, 'gui_fluct_dist_memb_points_um', gui_fluct.dist_memb_points_um);
% setappdata(0, 'gui_fluct_finalFilename', gui_fluct.filename);
% setappdata(0, 'gui_fluct_results_fluctuations_um', gui_fluct.Results.fluctuations_map_um);
% setappdata(0, 'gui_fluct_results_fluctuations_um_filtered', gui_fluct.Results.fluctuations_map_um_filtered);
% setappdata(0, 'gui_fluct_results_fluctuations_px', gui_fluct.Results.fluctuations_map_px);
% setappdata(0, 'gui_fluct_results_fluctuations_map_px_filt', gui_fluct.Results.fluctuations_map_px_filtered);
% setappdata(0, 'gui_fluct_results_ffts_um_struct', gui_fluct.Results.ffts_um_struct);
% setappdata(0, 'gui_fluct_savePath', gui_fluct.savePath);
% setappdata(0, 'gui_fluct_searchPath', gui_fluct.searchPath);


function show_img(I, h_axes)

zoom_x = xlim(h_axes);
zoom_y = ylim(h_axes);

cla(h_axes)
imagesc(h_axes, I)
colormap(h_axes, 'jet')

memb_coords = getappdata(0, 'gui_fluct_memb_coords');

if ~isempty(memb_coords)
    frame = getappdata(0, 'gui_fluct_Load_current_frame');
    hold(h_axes, 'on')
    plot(h_axes, memb_coords(:,1, frame), memb_coords(:,2, frame), 'k', 'linewidth', 1)
    plot(h_axes, memb_coords(:,1, frame), memb_coords(:,2, frame), 'k.', 'markersize', 5)
end

axis(h_axes, 'equal')
xlim(h_axes, zoom_x)
ylim(h_axes, zoom_y)

drawnow


% --- Executes on button press in results_button.
function results_button_Callback(hObject, eventdata, handles)
% hObject    handle to results_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setappdata(0, 'clicked_results', 1);

close(GUI_FLUCT_Load_Data)
GUI_FLUCT_Results


% --- Executes on button press in preview_button.
function preview_button_Callback(hObject, eventdata, handles)
% hObject    handle to preview_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
I = getappdata(0, 'gui_fluct_I');
masks = getappdata(0, 'gui_fluct_masks');
frame = getappdata(0, 'gui_fluct_Load_current_frame');
settings = getappdata(0, 'gui_main_fluct_settings');
nPoints = settings.nPoints;
img_filter_width = settings.img_filt_size;
memb_filter_width = settings.seg_smoothness;
step = 2;

[memb_coords, masks_frame, centered_I, ~, error_signal] = Segment_Membs(I(:,:,frame), nPoints, img_filter_width, memb_filter_width, step, {masks{frame}});
masks{frame} = masks_frame{1};

if ~error_signal
    figure
    imagesc(centered_I), hold on
    plot(memb_coords(:,1), memb_coords(:,2), 'k', 'linewidth', 1)
    plot(memb_coords(:,1), memb_coords(:,2), 'k.', 'markersize', 5)
    colormap('jet')
    axis equal
    title(['Frame: ' num2str(frame)])
    setappdata(0, 'gui_fluct_masks', masks);
end

% --- Executes on button press in segment_all.
function segment_all_Callback(hObject, eventdata, handles)
% hObject    handle to segment_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
I = getappdata(0, 'gui_fluct_I');
masks = getappdata(0, 'gui_fluct_masks');
frame = getappdata(0, 'gui_fluct_Load_current_frame');
settings = getappdata(0, 'gui_main_fluct_settings');

nPoints = settings.nPoints;
memb_smooth_filter = settings.seg_smoothness;
img_filter_side = settings.img_filt_size;
step = 2;

state = getappdata(0, 'gui_fluct_Load_state');
manage_buttons(handles, 4)

[memb_coords_all, masks, centered_I, centroids, error_signal, stopped] = Segment_Membs(I, nPoints, img_filter_side, memb_smooth_filter, step, masks);

if ~error_signal && ~stopped
    manage_buttons(handles, 5)
    setappdata(0, 'gui_fluct_results', [])
    setappdata(0, 'gui_fluct_Load_state', 5) % Ready for Next!
    setappdata(0, 'gui_fluct_centroids', centroids)
    setappdata(0, 'gui_fluct_masks', masks)
    setappdata(0, 'gui_fluct_memb_coords', memb_coords_all)
    setappdata(0, 'gui_fluct_I', centered_I)

    clear_fluct_results
    show_img(centered_I(:,:,frame), handles.img_axes)
else
    
    manage_buttons(handles, state)
end



% --- Executes during object creation, after setting all properties.
function segment_all_CreateFcn(hObject, eventdata, handles)
% hObject    handle to segment_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function draw_region_button_CreateFcn(hObject, eventdata, handles)
% hObject    handle to segment_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% --- Executes on button press in reset_view_button.
function reset_view_button_Callback(hObject, eventdata, handles)
% hObject    handle to reset_view_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
metadata = getappdata(0, 'gui_fluct_metadata');
x_max = metadata.SizeX;
y_max = metadata.SizeY;

xlim(handles.img_axes, [1 x_max])
ylim(handles.img_axes, [1 y_max])

axis equal


% --- Executes on button press in break_button.
function break_button_Callback(hObject, eventdata, handles)
% hObject    handle to break_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setappdata(0, 'stop_cycle', 1)


function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function med_filter_side_Callback(hObject, eventdata, handles)
% hObject    handle to med_filter_side (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of med_filter_side as text
%        str2double(get(hObject,'String')) returns contents of med_filter_side as a double
settings = getappdata(0, 'gui_main_fluct_settings');
settings.img_filt_size = round(str2double(get(hObject, 'string')));
setappdata(0, 'gui_main_fluct_settings', settings);


% --- Executes during object creation, after setting all properties.
function med_filter_side_CreateFcn(hObject, eventdata, handles)
% hObject    handle to med_filter_side (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
settings = getappdata(0, 'gui_main_fluct_settings');
set(hObject, 'string', settings.img_filt_size)


function nPoints_edit_Callback(hObject, eventdata, handles)
% hObject    handle to nPoints_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nPoints_edit as text
%        str2double(get(hObject,'String')) returns contents of nPoints_edit as a double
settings = getappdata(0, 'gui_main_fluct_settings');
settings.nPoints = round(str2double(get(hObject, 'string')));
setappdata(0, 'gui_main_fluct_settings', settings);



% --- Executes during object creation, after setting all properties.
function nPoints_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nPoints_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
settings = getappdata(0, 'gui_main_fluct_settings');
set(hObject, 'string', settings.nPoints)


function filter_width_edit_Callback(hObject, eventdata, handles)
% hObject    handle to filter_width_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filter_width_edit as text
%        str2double(get(hObject,'String')) returns contents of filter_width_edit as a double
settings = getappdata(0, 'gui_main_fluct_settings');
settings.seg_smoothness = round(str2double(get(hObject, 'string')));
setappdata(0, 'gui_main_fluct_settings', settings);


% --- Executes during object creation, after setting all properties.
function filter_width_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filter_width_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
settings = getappdata(0, 'gui_main_fluct_settings');
set(hObject, 'string', settings.seg_smoothness)

% --- Executes on button press in draw_mask_button.
function draw_mask_button_Callback(hObject, eventdata, handles)
% hObject    handle to draw_mask_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
I = getappdata(0, 'gui_fluct_I');
frame = getappdata(0, 'gui_fluct_Load_current_frame');
metadata = getappdata(0, 'gui_fluct_metadata');
size_I = [metadata.SizeY metadata.SizeX];
state = getappdata(0, 'gui_fluct_Load_state');

radius = 10;
manage_buttons(handles, 2);
mask = from_draw_to_membrane_mask(size_I, handles.img_axes, radius);

imagesc(handles.img_axes, I(:,:,frame) .* mask)
axis(handles.img_axes, 'equal')
colormap(handles.img_axes, 'jet')
answer = questdlg('Save masked frame?');

if strcmp(answer, 'Yes')  
    masks = getappdata(0, 'gui_fluct_masks');
        if isempty(masks)
            masks = cell(metadata.nFrames, 1);
        end    
    masks{frame} = mask;
    I(:,:,frame) = I(:,:,frame) .* mask;
    setappdata(0, 'gui_fluct_I', I);
    setappdata(0, 'gui_fluct_masks', masks)
else
    imagesc(handles.img_axes, I(:,:,frame)) 
    axis(handles.img_axes, 'equal')
    colormap(handles.img_axes, 'jet')
end
manage_buttons(handles, state);

% --- Executes on button press in cancel_remove_button.
function cancel_remove_button_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_remove_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.remove_button, 'enable', 'off')
set(handles.cancel_remove_button, 'enable', 'off')
set(handles.first_frame_remove_region, 'enable', 'off')
set(handles.last_frame_remove_region, 'enable', 'off')


% --- Executes during object creation, after setting all properties.
function draw_mask_button_CreateFcn(hObject, eventdata, handles)
% hObject    handle to draw_mask_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function filename_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filename_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

filename = getappdata(0, 'gui_fluct_finalFilename');
[~, fname, ~] = fileparts(filename);
text = ['File: ' fname];
set(hObject, 'string', text)


function seg_memb_closereq(src,callbackdata)

state = getappdata(0, 'gui_main_fluct_states');
clicked_results = getappdata(0, 'clicked_results');      

if state > 2 % in batch Mode
    setappdata(0, 'clicked_results', []);
    
    if ~clicked_results
       selection = questdlg('You will lose all changes to this file. Close now?',...
               'Yes','No');          
        switch selection
            case 'Yes'
                delete(GUI_FLUCT_Load_Data)
            case 'No'
                return
        end
    else
        delete(GUI_FLUCT_Load_Data)
    end
    
else
    delete(GUI_FLUCT_Load_Data)    
end
