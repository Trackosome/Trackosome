function varargout = GUI_FLUCT_Filter_Flucts(varargin)
% GUI_FLUCT_FILTER_FLUCTS MATLAB code for GUI_FLUCT_Filter_Flucts.fig
%      GUI_FLUCT_FILTER_FLUCTS, by itself, creates a new GUI_FLUCT_FILTER_FLUCTS or raises the existing
%      singleton*.
%
%      H = GUI_FLUCT_FILTER_FLUCTS returns the handle to a new GUI_FLUCT_FILTER_FLUCTS or the handle to
%      the existing singleton*.
%
%      GUI_FLUCT_FILTER_FLUCTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_FLUCT_FILTER_FLUCTS.M with the given input arguments.
%
%      GUI_FLUCT_FILTER_FLUCTS('Property','Value',...) creates a new GUI_FLUCT_FILTER_FLUCTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_FLUCT_Filter_Flucts_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_FLUCT_Filter_Flucts_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_FLUCT_Filter_Flucts

% Last Modified by GUIDE v2.5 11-Apr-2020 21:14:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_FLUCT_Filter_Flucts_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_FLUCT_Filter_Flucts_OutputFcn, ...
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


% --- Executes just before GUI_FLUCT_Filter_Flucts is made visible.
function GUI_FLUCT_Filter_Flucts_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_FLUCT_Filter_Flucts (see VARARGIN)

set(handles.figure1, 'Name', 'Filter Fluctuations');

% Choose default command line output for GUI_FLUCT_Filter_Flucts
handles.output = hObject;

results = getappdata(0, 'gui_fluct_results');
unfiltered_flucts = results.fluctuations_px;
filtered_flucts = results.fluctuations_px_filt;

imagesc(handles.unfiltered_axes, unfiltered_flucts)
xlabel(handles.unfiltered_axes, 'Frames')
ylabel(handles.unfiltered_axes, 'Memb Points')

imagesc(handles.filtered_axes, filtered_flucts)
xlabel(handles.filtered_axes, 'Frames')
colormap('jet')
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_FLUCT_Filter_Flucts wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_FLUCT_Filter_Flucts_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function space_edit_Callback(hObject, eventdata, handles)
% hObject    handle to space_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of space_edit as text
%        str2double(get(hObject,'String')) returns contents of space_edit as a double
set(handles.apply_button, 'enable', 'on')
settings = getappdata(0, 'gui_main_fluct_settings');
space_time_filt = settings.space_time_filt;
space_time_filt(1) = round(str2double(get(hObject, 'string')));
settings.space_time_filt = space_time_filt;
setappdata(0, 'gui_main_fluct_settings', settings)


% --- Executes during object creation, after setting all properties.
function space_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to space_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
settings = getappdata(0, 'gui_main_fluct_settings');
space_time_filt = settings.space_time_filt;
set(hObject, 'string', space_time_filt(1))


function time_edit_Callback(hObject, eventdata, handles)
% hObject    handle to time_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time_edit as text
%        str2double(get(hObject,'String')) returns contents of time_edit as a double
set(handles.apply_button, 'enable', 'on')
settings = getappdata(0, 'gui_main_fluct_settings');
space_time_filt = settings.space_time_filt;
space_time_filt(2) = round(str2double(get(hObject, 'string')));
settings.space_time_filt = space_time_filt;
setappdata(0, 'gui_main_fluct_settings', settings)

% --- Executes during object creation, after setting all properties.
function time_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
settings = getappdata(0, 'gui_main_fluct_settings');
space_time_filt = settings.space_time_filt;
set(hObject, 'string', space_time_filt(2))


% --- Executes on button press in apply_button.
function apply_button_Callback(hObject, eventdata, handles)
% hObject    handle to apply_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

results = getappdata(0, 'gui_fluct_results');
space_filt = str2double(get(handles.space_edit, 'string'));
time_filt = str2double(get(handles.time_edit, 'string'));

% Filter Fluctuations:
[fluctuations_px_filt, fluctuations_vectors_filt, memb_coords_filt] = ...
    filter_fluctuations(results.fluctuations_px, results.ref_memb_struct.normals,...
     results.ref_memb_struct.vectors_base, space_filt, time_filt);

% Store Temporary Results:
filt_results.memb_coords_filt = memb_coords_filt;
filt_results.fluctuations_px_filt = fluctuations_px_filt;
filt_results.fluctuations_vectors_filt = fluctuations_vectors_filt;
filt_results.space_time_filt = [space_filt time_filt];
handles.temp_filt_results = filt_results;

% Update Figure
imagesc(handles.filtered_axes, fluctuations_px_filt)

set(handles.save_button, 'enable', 'on')
guidata(hObject, handles);


% --- Executes on button press in save_button.
function save_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

results = getappdata(0, 'gui_fluct_results');
metadata = getappdata(0, 'gui_fluct_metadata');
temp_filt_results = handles.temp_filt_results;

px2um = metadata.px2um;
dist_memb_points_um =  results.ref_memb_struct.dist_memb_points_um;
ffts_um_struct = results.ffts_um_struct;

% Calculate FFT:
[ffts_um_struct.full_ffts_filt, ffts_um_struct.mean_fft_filt, ffts_um_struct.max_fft_filt, ffts_um_struct.freqs] = ...
    fluctuations_fourier(temp_filt_results.fluctuations_px_filt * px2um, dist_memb_points_um);

% Update Results:
results.memb_coords_filt = temp_filt_results.memb_coords_filt;
results.ffts_um_struct = ffts_um_struct;
results.fluctuations_px_filt = temp_filt_results.fluctuations_px_filt;
results.fluctuations_vectors_filt = temp_filt_results.fluctuations_vectors_filt;
results.space_time_filts = temp_filt_results.space_time_filt;

%5 Update Settings:
space_filt = str2double(get(handles.space_edit, 'string'));
time_filt = str2double(get(handles.time_edit, 'string'));
settings = getappdata(0, 'gui_main_fluct_settings');
settings.space_time_filt = [space_filt time_filt];

setappdata(0, 'gui_fluct_results', results)

close(GUI_FLUCT_Filter_Flucts)
GUI_FLUCT_Results
