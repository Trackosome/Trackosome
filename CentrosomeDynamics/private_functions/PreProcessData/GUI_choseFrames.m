function varargout = GUI_choseFrames(varargin)
% Domingos Leite de Castro, domingos.castro@i3s.up.pt
% Paulo de Castro Aguiar, pauloaguiar@ineb.up.pt

% GUI_choseFrames MATLAB code for GUI_choseFrames.fig
%      GUI_choseFrames, by itself, creates a new GUI_choseFrames or raises the existing
%      singleton*.
%
%      H = GUI_choseFrames returns the handle to a new GUI_choseFrames or the handle to
%      the existing singleton*.
%
%      GUI_choseFrames('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_choseFrames.M with the given input arguments.
%
%      GUI_choseFrames('Property','Value',...) creates a new GUI_choseFrames or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_choseFrames_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_choseFrames_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_choseFrames

% Last Modified by GUIDE v2.5 13-Sep-2019 10:08:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GUI_choseFrames_OpeningFcn, ...
    'gui_OutputFcn',  @GUI_choseFrames_OutputFcn, ...
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


% --- Executes just before GUI_choseFrames is made visible.
function GUI_choseFrames_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_choseFrames (see VARARGIN)

set(handles.figure1, 'Name', 'Pre-process Data');

setappdata(0, 'gui_current_window', 2)

% States:
%       0 - choose frames
%       1 - choose initial CS coordinates
%       2 - ready to proceed

%% Load Data
Img = getappdata(0, 'gui_Img_C');
metadata = getappdata(0, 'gui_metadata');

%% Set State:
Preprocess_vars = getappdata(0, 'gui_Preprocess_vars');

if isempty(Preprocess_vars)
    Preprocess_vars.state = 0; 
    Preprocess_vars.X = [0 0];
    Preprocess_vars.Y = [0 0];
    Preprocess_vars.isFiltered = 0;
end

manage_buttons(handles, Preprocess_vars.state)
XYprojection = squeeze(max(Img(:,:,:,1),[],3));
set(handles.lastFrame_ed,'string',num2str(metadata.nFrames))

%% Display the first frame:
axes(handles.imageAxes); hold on
ax = gca;
ax.YDir = 'reverse';
imagesc(ax, XYprojection), 
caxis([min(XYprojection(:)) max(XYprojection(:))])

if Preprocess_vars.X(1) && Preprocess_vars.Y(1)
    plot(handles.imageAxes, Preprocess_vars.X(1), Preprocess_vars.Y(1), 'r.', 'markersize', 20)
    plot(handles.imageAxes, Preprocess_vars.X(2), Preprocess_vars.Y(2), 'b.', 'markersize', 20)
end
axis off

%% Set Data
setappdata(0, 'gui_Preprocess_vars', Preprocess_vars);

%% Define array with all buttons:
handles.h_all_buttons = [handles.firstFrame_ed, handles.lastFrame_ed, handles.slider, handles.undo_button, ...
    handles.ok_button, handles.back_button, handles.next_button, handles.break_button, handles.filter_button...
    handles.break_button, handles.menu_button];

%% Set Menu Buttons
update_menu_buttons([])

%% Choose default command line output for GUI_choseFrames
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_choseFrames wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_choseFrames_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider_Callback(hObject, eventdata, handles)
% hObject    handle to slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
%The slider called...

Img = getappdata(0, 'gui_Img_C');
Preprocess_vars = getappdata(0, 'gui_Preprocess_vars');

sliderValue=round(get(hObject,'Value'));
set(handles.currentFrame_txt,'string',sliderValue)   
XYprojection = squeeze(max(Img(:,:,:,sliderValue),[],3));
imagesc(handles.imageAxes, XYprojection), 

caxis([min(XYprojection(:)) max(XYprojection(:))])

if sliderValue == 1 & Preprocess_vars.X
    plot(handles.imageAxes, Preprocess_vars.X(1), Preprocess_vars.Y(1), 'r.', 'markersize', 20)
    plot(handles.imageAxes, Preprocess_vars.X(2), Preprocess_vars.Y(2), 'b.', 'markersize', 20)
end

% axis off
% set(handles.info_box,'string',state.info_state0)


% --- Executes during object creation, after setting all properties.
function slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider (see GCBO)
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
smallstep=1/(nFrames-1);  %Step the slider will take when moved using the arrow buttons: 1 frame
largestep=smallstep*10;
set(hObject,'BackgroundColor',[.9 .9 .9], 'Value', 1, 'Min', 1, 'Max', metadata.nFrames, 'SliderStep', [smallstep largestep] );


function firstFrame_ed_Callback(hObject, eventdata, handles)
% hObject    handle to firstFrame_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of firstFrame_ed as text
%        str2double(get(hObject,'String')) returns contents of firstFrame_ed as a double
metadata = getappdata(0, 'gui_metadata');
firstFrame = str2double(get(hObject,'String'));
lastFrame = firstFrame + metadata.nFrames - 1;

if firstFrame < 1
    firstFrame = 1;
    str2double(set(hObject,'string', firstFrame));
elseif firstFrame >= lastFrame
    firstFrame = lastFrame - 1;
    str2double(set(hObject,'string', firstFrame));
end
set(handles.slider,'Value', firstFrame)
slider_Callback(handles.slider, [], handles)
setappdata(0, 'gui_metadata', metadata);

clear_track_data;
clear_results_data;
lock_menu_buttons


% --- Executes during object creation, after setting all properties.
function firstFrame_ed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to firstFrame_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function lastFrame_ed_Callback(hObject, eventdata, handles)
% hObject    handle to lastFrame_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lastFrame_ed as text
%        str2double(get(hObject,'String')) returns contents of lastFrame_ed as a double
metadata = getappdata(0, 'gui_metadata');
lastFrame = str2double(get(hObject,'String'));
firstFrame = str2double(get(handles.firstFrame_ed,'String'));
if lastFrame > metadata.nFrames
    lastFrame = metadata.nFrames;
    str2double(set(hObject,'string', lastFrame));
elseif lastFrame <= firstFrame
    lastFrame = firstFrame + 1;
    str2double(set(hObject,'string', lastFrame));
end

set(handles.slider,'Value', lastFrame)
slider_Callback(handles.slider, [], handles);

clear_track_data;
clear_results_data;
lock_menu_buttons


% --- Executes during object creation, after setting all properties.
function lastFrame_ed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lastFrame_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white')
end


% --- Executes on button press in ok_button.
function ok_button_Callback(hObject, eventdata, handles)
% hObject    handle to ok_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Load Data
lock_menu_buttons
firstFrame = str2double(get(handles.firstFrame_ed,'String'));
set(handles.slider,'Value', firstFrame)
slider_Callback(handles.slider, [], handles)
Preprocess_vars = getappdata(0, 'gui_Preprocess_vars'); 

%% Set State:
Preprocess_vars.state = 1;
manage_buttons(handles, Preprocess_vars.state)
setappdata(0, 'gui_Preprocess_vars', Preprocess_vars)

%% Choose Coordinates
set(handles.info_box,'string','Click on Centrosome 1')
[X(1), Y(1)] = drawCoordinates(1,  'k*');
set(handles.info_box,'string','Click on Centrosome 2')
[X(2), Y(2)] = drawCoordinates(1,  'k*');
set(handles.info_box,'string','Ok?')

%% Set coordinates?
answer = questdlg('Coordinates ok?');

if strcmp(answer, 'Yes')            
    set(handles.info_box,'string','Ready!')    
    Preprocess_vars.X = X;
    Preprocess_vars.Y = Y;
    Preprocess_vars.state = 2;
    
else % Not Saved, go back to initial state
    Preprocess_vars.state = 0;
end
    
setappdata(0, 'gui_Preprocess_vars', Preprocess_vars)
manage_buttons(handles, Preprocess_vars.state)
update_menu_buttons([])


% --- Executes on button press in undo_button.
function undo_button_Callback(hObject, eventdata, handles)
% hObject    handle to undo_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Preprocess_vars = getappdata(0, 'gui_Preprocess_vars'); 
firstFrame = str2double(get(handles.firstFrame_ed,'String'));
Preprocess_vars.state = 0;
manage_buttons(handles, Preprocess_vars.state)
setappdata(0, 'gui_Preprocess_vars', Preprocess_vars)
set(handles.slider,'Value', firstFrame)
slider_Callback(handles.slider, [], handles)


% --- Executes on button press in next_button.
function next_button_Callback(hObject, eventdata, handles)
% hObject    handle to next_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% Load Data to Save:
gui_Preprocess_vars = getappdata(0, 'gui_Preprocess_vars');
gui_Img_C = getappdata(0, 'gui_Img_C');
gui_Img_NM = getappdata(0, 'gui_Img_NM');
gui_Img_CM = getappdata(0, 'gui_Img_CM');
gui_metadata = getappdata(0, 'gui_metadata');
gui_LoadData_vars = getappdata(0, 'gui_LoadData_vars');
gui_LoadData_state = getappdata(0, 'gui_LoadData_state');

%% Cut extra frames:
lastFrame = str2double(get(handles.lastFrame_ed,'String'));
firstFrame = str2double(get(handles.firstFrame_ed,'String'));

gui_metadata.nFrames = lastFrame - firstFrame + 1;
gui_Img_C = gui_Img_C(:,:,:,firstFrame:lastFrame);
gui_Img_NM = gui_Img_NM(:,:,:,firstFrame:lastFrame);

if ~isempty(gui_Img_CM)
    gui_Img_CM = gui_Img_CM(:,:,:,firstFrame:lastFrame);
end

%% Filter Image if needed
if ~gui_Preprocess_vars.isFiltered
    
    answer = questdlg('Filter Image?');
    if strcmp(answer, 'Yes')
        setappdata(0, 'gui_Img_C', gui_Img_C)
        filter_button_Callback(hObject, eventdata, handles)
        gui_Img_C = getappdata(0, 'gui_Img_C');
    end
end

setappdata(0, 'gui_Img_C', gui_Img_C)
setappdata(0, 'gui_Img_NM', gui_Img_NM)
setappdata(0, 'gui_Img_CM', gui_Img_CM)
setappdata(0, 'gui_metadata', gui_metadata)

try
    close(m)
catch
end

close(GUI_choseFrames)
GUI_TrackCentrosomes()


function  manage_buttons_during_filt(handles)
set(handles.break_button, 'backgroundcolor', [0.64 0.08 0.18])
set(handles.h_all_buttons, 'enable', 'off')
set(handles.break_button, 'enable', 'on')


% --- Executes on button press in back_button.
function back_button_Callback(hObject, eventdata, handles)
% hObject    handle to back_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close( GUI_choseFrames )
GUI_LoadData()


function manage_buttons(handles, state)

if state == 0  % Select Iniital and Final Frames
    set(handles.firstFrame_ed, 'enable', 'on')
    set(handles.lastFrame_ed, 'enable', 'on')
    set(handles.slider, 'enable', 'on')
    set(handles.undo_button, 'enable', 'off')
    set(handles.ok_button, 'enable', 'on')
    set(handles.back_button, 'enable', 'on')
    set(handles.next_button, 'enable', 'off')
    set(handles.break_button, 'enable', 'off')
    set(handles.menu_button, 'enable', 'on')
    set(handles.filter_button, 'enable', 'on')
    set(handles.info_box,'string', 'Select First and Last Frames')
    
elseif state == 1  % Select Centrosome Coordinates
    set(handles.firstFrame_ed, 'enable', 'off')
    set(handles.lastFrame_ed, 'enable', 'off')
    set(handles.slider, 'enable', 'off')
    set(handles.undo_button, 'enable', 'off')
    set(handles.ok_button, 'enable', 'off')
    set(handles.back_button, 'enable', 'of')
    set(handles.next_button, 'enable', 'off')
    set(handles.break_button, 'enable', 'off')
    set(handles.menu_button, 'enable', 'on')
    set(handles.filter_button, 'enable', 'on')
    
else % Finished, proceed
    set(handles.firstFrame_ed, 'enable', 'off')
    set(handles.lastFrame_ed, 'enable', 'off')
    set(handles.slider, 'enable', 'off')
    set(handles.undo_button, 'enable', 'on')
    set(handles.ok_button, 'enable', 'off')
    set(handles.back_button, 'enable', 'on')
    set(handles.next_button, 'enable', 'on')
    set(handles.break_button, 'enable', 'off')
    set(handles.info_box,'string', 'Ready!')
    set(handles.menu_button, 'enable', 'on')
    set(handles.filter_button, 'enable', 'on')
end


% --- Executes on button press in break_button.
function break_button_Callback(hObject, eventdata, handles)
% hObject    handle to break_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.break_button, 'enable', 'off')
set(handles.break_button, 'backgroundcolor', [0.9 0.9 0.9])

manage_buttons(handles, 2) % Put the buttons in state "ready"
update_menu_buttons([])
setappdata(0, 'gui_ChooseFrames_break', 1)


% --- Executes on button press in menu_button.
function menu_button_Callback(hObject, eventdata, handles)
% hObject    handle to menu_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close
GUI_Main_Menu


% --- Executes on button press in filter_button.
function filter_button_Callback(hObject, eventdata, handles)
% hObject    handle to filter_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gui_Img_C = getappdata(0, 'gui_Img_C');
gui_metadata = getappdata(0, 'gui_metadata');
gui_Preprocess_vars = getappdata(0, 'gui_Preprocess_vars');

% Freeze buttons:
manage_buttons_during_filt(handles)
lock_menu_buttons;

% Filter:
[gui_Img_C, is_filtered] = Spatial_Filtering_3D_LoG( gui_Img_C, ...
    gui_metadata.centrosome_radius_px, gui_metadata.ratio_z_xy_px);

if is_filtered
    gui_Preprocess_vars.isFiltered = 1;
end

% Release Buttons:
manage_buttons(handles, gui_Preprocess_vars.state)

% Set Data:
setappdata(0, 'gui_Preprocess_vars', gui_Preprocess_vars);
setappdata(0, 'gui_Img_C', gui_Img_C);
setappdata(0, 'gui_metadata', gui_metadata);

% Update Image
slider_Callback(handles.slider, eventdata, handles)
