function varargout = Correct_Membranes(varargin)
% Domingos Leite de Castro, domingos.castro@i3s.up.pt
% Paulo de Castro Aguiar, pauloaguiar@ineb.up.pt

% Correct_Membranes MATLAB code for GUI_Correct_Membranes.fig
%      Correct_Membranes, by itself, creates a new GUI_Correct_Membranes or raises the existing
%      singleton*.
%
%      H = Correct_Membranes returns the handle to a new Correct_Membranes or the handle to
%      the existing singleton*.
%
%      Correct_Membranes('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in Correct_Membranes.M with the given input arguments.
%
%      Correct_Membranes('Property','Value',...) creates a new Correct_Membranes or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Correct_Membranes_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Correct_Membranes_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Correct_Membranes

% Last Modified by GUIDE v2.5 14-Oct-2020 11:26:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Correct_Membranes_OpeningFcn, ...
    'gui_OutputFcn',  @Correct_Membranes_OutputFcn, ...
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


% --- Executes just before Correct_Membranes is made visible.
function Correct_Membranes_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Correct_Membranes (see VARARGIN)

% Choose default command line output for Correct_Membranes
handles.output = hObject;
setappdata(0, 'gui_current_window', 5)
set(handles.figure1, 'Name', 'Correct Membranes');
% UIWAIT makes Correct_Membranes wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%% Load Data:
metadata = getappdata(0, 'gui_metadata');
activatedFrames = getappdata(0, 'gui_track_activatedFrames');

handles.memb_type = 'NM';
handles.z = round(metadata.nStacks/2);

%% Generate Frame Buttons
if isempty(activatedFrames)
    activatedFrames = ones(metadata.nFrames, 1);
end

tracking_state = getappdata(0, 'gui_track_tracking_state');

frame_state_buttons = generate_frame_buttons(handles, metadata.nFrames, @click_frame_button);
update_button_color(frame_state_buttons, [],tracking_state.frame_states, activatedFrames, false);
setappdata(0, 'gui_correct_memb_state_buttons', frame_state_buttons)

%% Get thresholds:
threshs = getappdata(0, 'gui_Img_threshs');

if isempty(threshs)
    Img_NM = getappdata(0, 'gui_Img_NM');    
    Img_CM = getappdata(0, 'gui_Img_CM');
    
    threshs.NM = nan(metadata.nFrames, 1);
    threshs.CM = nan(metadata.nFrames, 1);
    
    for f = 1:metadata.nFrames
        threshs.NM(f) = graythresh(Img_NM(:,:,:,f)); % Auto
        if ~isempty(Img_CM)
            threshs.CM(f) = graythresh(Img_CM(:,:,:,f)); % Auto
        end
    end
    
    setappdata(0, 'gui_Img_threshs', threshs);
end


%% Set GUI
setappdata(0, 'gui_track_currentFrame', 1);
plot_frame(handles, metadata)

if strcmp(handles.memb_type, 'NM')
    file = 'Nuclear Membrane';
    
elseif strcmp(handles.memb_type, 'CM')
    file = 'Cell Membrane';
end

set(handles.slice_txt, 'string', [file ' [z = ' num2str(handles.z) ']'])


%% Update handles structure
guidata(hObject, handles);



function plot_frame(handles, metadata)

Img_NM = getappdata(0, 'gui_Img_NM');
Img_CM = getappdata(0, 'gui_Img_CM');
NM_vars = getappdata(0, 'gui_results_NM_vars');
CM_vars = getappdata(0, 'gui_results_CM_vars');
threshs = getappdata(0, 'gui_Img_threshs');
frame = getappdata(0, 'gui_track_currentFrame');

memb_type = handles.memb_type;
z = handles.z;

if isempty(Img_CM)
    to_plot = [0 1 0]; % only NM
else
    to_plot = [0 1 1]; % NM and CM
end


% 3D Plot:
[NM_BW_filled, memb_BW, centroid, ~] = defineReconstInputs(to_plot, [], NM_vars, CM_vars, frame);
visualize_reconstruction(handles.reconstruction_axes, NM_BW_filled, memb_BW,...
    centroid, [], [], [], metadata, [])


% Select Membrane data:
if strcmp(memb_type, 'NM')
    img_stack = Img_NM(:,:,:,frame);
    memb = bwmorph(NM_vars.memb_BW(:,:,z,frame), 'remove');
    thresh = round(threshs.NM(frame, 1).*100)./100;
else
    img_stack = Img_CM(:,:,:,frame);
    memb = bwmorph(CM_vars.memb_BW(:,:,z,frame), 'remove');
    thresh = round(threshs.CM(frame, 1).*100)./100;
end

plot_memb_stack(handles, memb, img_stack, z, thresh)



function plot_memb_stack(handles, memb, img_stack, z, thresh)

% Plot histogram
histogram(handles.hist_axes, img_stack, 50);

set(handles.hist_axes, 'yscale', 'log')
hold(handles.hist_axes, 'on')
plot(handles.hist_axes, [thresh thresh], [1 10^6], 'r', 'linewidth',3 )
hold(handles.hist_axes, 'off')
set(handles.edit_thresh, 'string', num2str(thresh))

% Plot Slice:
memb_intens = max(max(img_stack(:,:,z)));
set(handles.z_slider,'Value', z );
imagesc(handles.z_slice_axes, img_stack(:,:,z) + memb_intens*memb)
set(handles.z_slice_axes, 'xtick', [], 'ytick', [])
axis(handles.z_slice_axes, 'equal')


% --- Outputs from this function are returned to the command line.
function varargout = Correct_Membranes_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function last_fr_CM_Callback(hObject, eventdata, handles)
% hObject    handle to last_fr_CM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of last_fr_CM as text
%        str2double(get(hObject,'String')) returns contents of last_fr_CM as a double


% --- Executes during object creation, after setting all properties.
function last_fr_CM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to last_fr_CM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function last_fr_Callback(hObject, eventdata, handles)
% hObject    handle to last_fr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of last_fr as text
%        str2double(get(hObject,'String')) returns contents of last_fr as a double
last_f = str2double(get(hObject, 'string'));
first_f = str2double(get(handles.first_fr, 'string'));
metadata = getappdata(0, 'gui_metadata');

if first_f > last_f
    set(hObject, 'string', num2str(first_f))
elseif last_f > metadata.nFrames
    set(hObject, 'string', num2str(metadata.nFrames))
end

% --- Executes during object creation, after setting all properties.
function last_fr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to last_fr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in apply_btn.
function apply_btn_Callback(hObject, eventdata, handles)
% hObject    handle to apply_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

metadata = getappdata(0, 'gui_metadata');

frame_i = str2double(get(handles.first_fr, 'string'));
frame_f = str2double(get(handles.last_fr, 'string'));

if isnan(frame_f)
    frame_f = frame_i;
end

frames = [frame_i:frame_f];
thresh = str2double(get(handles.edit_thresh, 'string'));

type = handles.memb_type;
threshs = getappdata(0, 'gui_Img_threshs');

if strcmp(type, 'NM')
    Img_NM = getappdata(0, 'gui_Img_NM');
    NM_vars = getappdata(0, 'gui_results_NM_vars');
    [~, NM_vars.memb_BW(:,:,:,frames), ~, ~] = ...
        NM_CM_reconstruction(Img_NM(:,:,:,frames), [], metadata.px2um, thresh, 0);
    
    threshs.NM(frames) = thresh;
    
    setappdata(0, 'gui_results_NM_vars', NM_vars);
    setappdata(0, 'gui_Img_threshs', threshs);
    
elseif strcmp(type, 'CM')
    Img_CM = getappdata(0, 'gui_Img_CM');
    CM_vars = getappdata(0, 'gui_results_CM_vars');
    [~, ~, ~, CM_vars.memb_BW(:,:,:,frames)]  = ...
        NM_CM_reconstruction([], Img_CM(:,:,:,frames), metadata.px2um, thresh, 0);
    
    threshs.CM(frames) = thresh;
    
    setappdata(0, 'gui_results_CM_vars', CM_vars);
    setappdata(0, 'gui_Img_threshs', threshs);
end

plot_frame(handles, metadata)
setappdata(0, 'Img_results_to_calc_metrics', 1)


function first_fr_Callback(hObject, eventdata, handles)
% hObject    handle to first_fr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of first_fr as text
%        str2double(get(hObject,'String')) returns contents of first_fr as a double
first_f = str2double(get(hObject, 'string'));
last_f = str2double(get(handles.last_fr, 'string'));

if first_f > last_f
    set(hObject, 'string', num2str(last_f))
elseif first_f < 1
    set(hObject, 'string', num2str(1))
end

% --- Executes during object creation, after setting all properties.
function first_fr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to first_fr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function auto_thresh_radio_CreateFcn(hObject, eventdata, handles)
% hObject    handle to auto_thresh_radio_CreateFcn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% --- Executes on button press in right_button.
function right_button_Callback(hObject, eventdata, handles)
% hObject    handle to right_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

f = getappdata(0, 'gui_track_currentFrame');
tracking_state = getappdata(0, 'gui_track_tracking_state');
activatedFrames = getappdata(0, 'gui_track_activatedFrames');
frame_state_buttons = getappdata(0, 'gui_correct_memb_state_buttons');
metadata = getappdata(0, 'gui_metadata');

f = min(metadata.nFrames, f+1);

set(handles.frame_text, 'string', num2str(f))
set(handles.first_fr, 'string', num2str(f))
set(handles.last_fr, 'string', '')
% Update Button
button_tag = ['button_' num2str(f)];
buttonObject = findobj('Tag', button_tag);
update_frame_button(buttonObject, frame_state_buttons, f, tracking_state.frame_states, activatedFrames)

% Update Plots
setappdata(0, 'gui_track_currentFrame', f);
plot_frame(handles, metadata)




% --- Executes on button press in left_button.
function left_button_Callback(hObject, eventdata, handles)
% hObject    handle to left_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

f = getappdata(0, 'gui_track_currentFrame');
tracking_state = getappdata(0, 'gui_track_tracking_state');
activatedFrames = getappdata(0, 'gui_track_activatedFrames');
frame_state_buttons = getappdata(0, 'gui_correct_memb_state_buttons');
metadata = getappdata(0, 'gui_metadata');

f = max(1, f-1);

set(handles.frame_text, 'string', num2str(f))
set(handles.first_fr, 'string', num2str(f))
set(handles.last_fr, 'string', '')

% Update Button
button_tag = ['button_' num2str(f)];
buttonObject = findobj('Tag', button_tag);
update_frame_button(buttonObject, frame_state_buttons, f, tracking_state.frame_states, activatedFrames)

% Update Plots
setappdata(0, 'gui_track_currentFrame', f);
plot_frame(handles, metadata)








% --- Executes on slider movement.
function z_slider_Callback(hObject, eventdata, handles)
% hObject    handle to z_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
f = getappdata(0, 'gui_track_currentFrame');
z=round(get(hObject,'Value'));

if get(handles.NM_select_radio, 'value')
    Img = getappdata(0, 'gui_Img_NM');    
    memb_vars = getappdata(0, 'gui_results_NM_vars');
    memb = bwmorph(memb_vars.memb_BW(:,:,z,f), 'remove');
       
elseif get(handles.CM_select_radio, 'value')
    Img = getappdata(0, 'gui_Img_CM');
    memb_vars = getappdata(0, 'gui_results_CM_vars');
    memb = bwmorph(memb_vars.memb_BW(:,:,z,f), 'remove');
end
Img = Img/max(Img(:));

memb_intens = max(max(Img(:,:,z,f)));
imagesc(handles.z_slice_axes, Img(:,:,z,f) + memb_intens*memb),
set(handles.z_slice_axes, 'xtick', [], 'ytick', [])
axis(handles.z_slice_axes, 'equal')

type = handles.memb_type;

if strcmp(type, 'NM')
    file = 'Nuclear Membrane';
    
elseif strcmp(type, 'CM')
    file = 'Cell Membrane';
end

set(handles.slice_txt, 'string', [file ' - z = ' num2str(z)])
% Update handles:
handles.z = z;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function z_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
set_slider_limitis(hObject)




function set_slider_limitis(hObject)
metadata = getappdata(0, 'gui_metadata');
nStacks = metadata.nStacks;
smallstep=1/(nStacks-1);  %Step the slider will take when moved using the arrow buttons: 1 frame
largestep=smallstep*3;
set(hObject,'BackgroundColor',[.9 .9 .9], 'Value', 1, 'Min', 1, 'Max', metadata.nStacks, 'SliderStep', [smallstep largestep] );



% --- Executes on button press in NM_select_radio.
function NM_select_radio_Callback(hObject, eventdata, handles)
% hObject    handle to NM_select_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of NM_select_radio
handles.memb_type = 'NM';
set(hObject,'Value', 1)
set(handles.CM_select_radio,'Value', 0)

Img_NM = getappdata(0, 'gui_Img_NM');
NM_vars = getappdata(0, 'gui_results_NM_vars');
threshs = getappdata(0, 'gui_Img_threshs');
frame = getappdata(0, 'gui_track_currentFrame');

% Img_NM = Img_NM/max(Img_NM(:));

z = handles.z;
img_stack = Img_NM(:,:,:,frame);
memb = bwmorph(NM_vars.memb_BW(:,:,z,frame), 'remove');


thresh = round(threshs.NM(frame, 1).*100)./100;
plot_memb_stack(handles, memb, img_stack, z, thresh)


set(handles.slice_txt, 'string', ['Nuclear Membrane [z = ' num2str(z) ']'])

% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in CM_select_radio.
function CM_select_radio_Callback(hObject, eventdata, handles)
% hObject    handle to CM_select_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CM_select_radio
handles.memb_type = 'CM';
set(hObject,'Value', 1)
set(handles.NM_select_radio,'Value', 0)

Img_CM = getappdata(0, 'gui_Img_CM');
CM_vars = getappdata(0, 'gui_results_CM_vars');
threshs = getappdata(0, 'gui_Img_threshs');
frame = getappdata(0, 'gui_track_currentFrame');

z = handles.z;
img_stack = Img_CM(:,:,:,frame);
memb = bwmorph(CM_vars.memb_BW(:,:,z,frame), 'remove');

thresh = round(threshs.CM(frame, 1).*100)./100;
plot_memb_stack(handles, memb, img_stack, z, thresh)

set(handles.slice_txt, 'string', ['Cell Membrane [z = ' num2str(z) ']'])


% Update handles structure
guidata(hObject, handles);




function edit_thresh_Callback(hObject, eventdata, handles)
% hObject    handle to edit_thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_thresh as text
%        str2double(get(hObject,'String')) returns contents of edit_thresh as a double

% new_thresh = str2double(get(hObject, 'string'));
% hold(handles.hist_axes, 'on')
% plot(handles.hist_axes, [new_thresh new_thresh], [1 10^6], 'color', [0.5 0.5 0.5],...
%     'linewidth',3 )


% --- Executes during object creation, after setting all properties.
function edit_thresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in filter_button.
function filter_button_Callback(hObject, eventdata, handles)
% hObject    handle to filter_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

type = handles.memb_type;

if strcmp(type, 'NM')
    Img_NM = getappdata(0, 'gui_Img_NM');
    Img_NM_filt = filter_4D(Img_NM, [7,7,1,3]);
    setappdata(0, 'gui_Img_NM', Img_NM_filt);
elseif strcmp(type, 'CM')
    Img_CM = getappdata(0, 'gui_Img_CM');
    Img_CM_filt = filter_4D(Img_CM, [7,7,1,3]);
    setappdata(0, 'gui_Img_CM', Img_CM_filt);
end

metadata = getappdata(0, 'gui_metadata');
plot_frame(handles, metadata)


% --- Executes on button press in auto_segment_button.
function auto_segment_button_Callback(hObject, eventdata, handles)
% hObject    handle to auto_segment_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

metadata = getappdata(0, 'gui_metadata');
threshs = getappdata(0, 'gui_Img_threshs');
type = handles.memb_type;

if strcmp(type, 'NM')
    Img_NM = getappdata(0, 'gui_Img_NM');
    NM_vars = getappdata(0, 'gui_results_NM_vars');
    [~, NM_vars.memb_BW, ~, ~] = ...
        NM_CM_reconstruction(Img_NM, [], metadata.px2um, [], 0);
    
    setappdata(0, 'gui_results_NM_vars', NM_vars);
    
    for f = 1:metadata.nFrames
        threshs.NM(f) = graythresh(Img_NM(:,:,:,f)); % Auto
    end
        
elseif strcmp(type, 'CM')
    Img_CM = getappdata(0, 'gui_Img_CM');
    CM_vars = getappdata(0, 'gui_results_CM_vars');
    [~, ~, ~, CM_vars.memb_BW]  = ...
        NM_CM_reconstruction([], Img_CM, metadata.px2um, [], 0);
    
    setappdata(0, 'gui_results_CM_vars', CM_vars);
    
    for f = 1:metadata.nFrames
        threshs.CM(f) = graythresh(Img_CM(:,:,:,f)); % Auto
    end
end

setappdata(0, 'gui_Img_threshs', threshs);

plot_frame(handles, metadata)

setappdata(0, 'Img_results_to_calc_metrics', 1)


function click_frame_button(hObject, ~, ~, f)

tracking_state = getappdata(0, 'gui_track_tracking_state');
activatedFrames = getappdata(0, 'gui_track_activatedFrames');
frame_state_buttons = getappdata(0, 'gui_correct_memb_state_buttons');
metadata = getappdata(0, 'gui_metadata');

update_frame_button(hObject, frame_state_buttons, f, tracking_state.frame_states, activatedFrames)

h = get(hObject,'parent');
handles = guidata(h);
set(handles.frame_text, 'string', num2str(f))
set(handles.first_fr, 'string', num2str(f))
set(handles.last_fr, 'string', '')

setappdata(0, 'gui_track_currentFrame', f);
plot_frame(handles, metadata)


% --- Executes on button press in back_button.
function back_button_Callback(hObject, eventdata, handles)
% hObject    handle to back_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(Correct_Membranes)
GUI_Tracking_Results

% --- Executes during object creation, after setting all properties.
function back_button_CreateFcn(hObject, eventdata, handles)
% hObject    handle to back_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function CM_select_radio_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CM_select_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

Img_CM = getappdata(0, 'gui_Img_CM');
if isempty(Img_CM)
    set(hObject, 'enable', 'off')
end
