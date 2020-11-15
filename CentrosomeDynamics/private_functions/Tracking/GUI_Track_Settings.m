function varargout = GUI_Track_Settings(varargin)
% GUI_TRACK_SETTINGS MATLAB code for GUI_Track_Settings.fig
%      GUI_TRACK_SETTINGS, by itself, creates a new GUI_TRACK_SETTINGS or raises the existing
%      singleton*.
%
%      H = GUI_TRACK_SETTINGS returns the handle to a new GUI_TRACK_SETTINGS or the handle to
%      the existing singleton*.
%
%      GUI_TRACK_SETTINGS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_TRACK_SETTINGS.M with the given input arguments.
%
%      GUI_TRACK_SETTINGS('Property','Value',...) creates a new GUI_TRACK_SETTINGS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_Track_Settings_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_Track_Settings_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_Track_Settings

% Last Modified by GUIDE v2.5 30-Apr-2019 08:16:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_Track_Settings_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_Track_Settings_OutputFcn, ...
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


% --- Executes just before GUI_Track_Settings is made visible.
function GUI_Track_Settings_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_Track_Settings (see VARARGIN)

set(handles.figure1, 'Name', 'Tracking Settings');

% Choose default command line output for GUI_Track_Settings
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_Track_Settings wait for user response (see UIRESUME)
% uiwait(handles.figure1);
metadata = getappdata(0, 'gui_metadata');

set(handles.CS_radius_px_box, 'String', metadata.centrosome_radius_px)
set(handles.CS_radius_stacks_box, 'String', metadata.centrosome_radius_stacks)
set(handles.length_ROI_px_box, 'String', metadata.lengthROI_px)
set(handles.length_ROI_stacks_box, 'String', metadata.lengthROI_stacks)

% set(hObject,'CloseRequestFcn', @saveData)

function saveData(src,callbackdata)
pause(0.0001)
delete(gcf)

% --- Outputs from this function are returned to the command line.
function varargout = GUI_Track_Settings_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in allow_CS_outside_button.
function allow_CS_outside_button_Callback(hObject, eventdata, handles)
% hObject    handle to allow_CS_outside_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of allow_CS_outside_button


% --- Executes on button press in CS_inside_ROI_button.
function CS_inside_ROI_button_Callback(hObject, eventdata, handles)
% hObject    handle to CS_inside_ROI_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CS_inside_ROI_button



function CS_radius_px_box_Callback(hObject, eventdata, handles)
% hObject    handle to CS_radius_px_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CS_radius_px_box as text
%        str2double(get(hObject,'String')) returns contents of CS_radius_px_box as a double
metadata = getappdata(0, 'gui_metadata');

value = str2double(get(hObject, 'String'));

if value < 3
    msgbox('You must have at least 3 pixels to perform a gaussian fit')
    value = 3;    
    set(hObject, 'String', num2str(value));
end

metadata.centrosome_radius_px = value;
setappdata(0, 'gui_metadata', metadata)

% --- Executes during object creation, after setting all properties.
function CS_radius_px_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CS_radius_px_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CS_radius_stacks_box_Callback(hObject, eventdata, handles)
% hObject    handle to CS_radius_stacks_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CS_radius_stacks_box as text
%        str2double(get(hObject,'String')) returns contents of CS_radius_stacks_box as a double
metadata = getappdata(0, 'gui_metadata');

value = str2double(get(hObject, 'String'));

if value < 3
    msgbox('You must have at least 3 stacks to perform a gaussian fit')
    value = 3;    
    set(hObject, 'String', num2str(value));
end

metadata.centrosome_radius_stacks = value;
setappdata(0, 'gui_metadata', metadata)

% --- Executes during object creation, after setting all properties.
function CS_radius_stacks_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CS_radius_stacks_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function length_ROI_px_box_Callback(hObject, eventdata, handles)
% hObject    handle to length_ROI_px_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of length_ROI_px_box as text
%        str2double(get(hObject,'String')) returns contents of length_ROI_px_box as a double
metadata = getappdata(0, 'gui_metadata');

value = str2double(get(hObject, 'String'));

if value < 3
    msgbox('Your ROI must have at least 3 pixels')
    value = 3;    
    set(hObject, 'String', num2str(value));
end

metadata.lengthROI_px = value;
metadata.kernelROI_XY = strel('rectangle',[value value]); % Region of Interest XZ for frame i+1
setappdata(0, 'gui_metadata', metadata)


% --- Executes during object creation, after setting all properties.
function length_ROI_px_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to length_ROI_px_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function length_ROI_stacks_box_Callback(hObject, eventdata, handles)
% hObject    handle to length_ROI_stacks_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of length_ROI_stacks_box as text
%        str2double(get(hObject,'String')) returns contents of length_ROI_stacks_box as a double
metadata = getappdata(0, 'gui_metadata');

value = str2double(get(hObject, 'String'));

if value < 3
    msgbox('Your ROI must have at least 3 stacks ')
    value = 3;    
    set(hObject, 'String', num2str(value));
end

metadata.lengthROI_stacks = value;
metadata.kernelROI_Zproj = strel('rectangle',[metadata.lengthROI_stacks metadata.lengthROI_px]); % Region of Interest XZ for frame i+1
setappdata(0, 'gui_metadata', metadata)



% --- Executes during object creation, after setting all properties.
function length_ROI_stacks_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to length_ROI_stacks_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function ROI_px_default_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROI_px_default_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
default_settings = getappdata(0, 'gui_track_default_settings');
set(hObject, 'string', default_settings.lengthROI_px)


% --- Executes during object creation, after setting all properties.
function ROI_stacks_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROI_stacks_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
default_settings = getappdata(0, 'gui_track_default_settings');
set(hObject, 'string', default_settings.lengthROI_stacks)


% --- Executes during object creation, after setting all properties.
function CS_radius_px_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CS_radius_px_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
default_settings = getappdata(0, 'gui_track_default_settings');
set(hObject, 'string', default_settings.centrosome_radius_px)


% --- Executes during object creation, after setting all properties.
function CS_radius_stacks_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CS_radius_stacks_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
default_settings = getappdata(0, 'gui_track_default_settings');
set(hObject, 'string', default_settings.centrosome_radius_stacks)
