function varargout = GUI_Main_Menu(varargin)
% Domingos Leite de Castro, domingos.castro@i3s.up.pt
% Paulo de Castro Aguiar, pauloaguiar@ineb.up.pt

% GUI_MAIN_MENU MATLAB code for GUI_Main_Menu.fig
%      GUI_MAIN_MENU, by itself, creates a new GUI_MAIN_MENU or raises the existing
%      singleton*.
%
%      H = GUI_MAIN_MENU returns the handle to a new GUI_MAIN_MENU or the handle to
%      the existing singleton*.
%
%      GUI_MAIN_MENU('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_MAIN_MENU.M with the given input arguments.


%      GUI_MAIN_MENU('Property','Value',...) creates a new GUI_MAIN_MENU or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_Main_Menu_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_Main_Menu_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_Main_Menu

% Last Modified by GUIDE v2.5 03-May-2019 09:50:11

% Begin initialization code - DO NOT EDIT


%% Add subfolders to Matlab path
folder = fileparts(which(mfilename)); 
addpath(genpath(folder));


%%
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_Main_Menu_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_Main_Menu_OutputFcn, ...
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



% --- Executes just before GUI_Main_Menu is made visible.
function GUI_Main_Menu_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_Main_Menu (see VARARGIN)

%% Trackosome Version:
version = 4.0;
setappdata(0, 'gui_Trackosome_version', version)

%% Choose default command line output for GUI_Main_Menu
handles.output = hObject;
set(handles.figure1, 'Name', '');


%% Manage Buttons
% States: 
%   - 1: Load Data Only
%   - 2: Pre-process data
%   - 3: Track centrosomes
%   - 4: Results
%
% Current Window:
%   - 0: none
%   - 1: Load data
%   - 2: Pre-process data
%   - 3: Track centrosomes
%   - 4: Results
%   - 5: Correct Membranes

menu_buttons.load_data_button = handles.load_data_button;
menu_buttons.pre_process_button = handles.pre_process_button;
menu_buttons.track_button = handles.track_button;
menu_buttons.results_button = handles.results_button;

state = get_menu_state();
manage_Menu_Buttons(menu_buttons, state)

setappdata(0, 'gui_menu_state', state)
setappdata(0, 'gui_menu_buttons', menu_buttons)
setappdata(0, 'gui_current_window', 0)


%% Set GUI colors
blue_color  = [0.3 0.75 0.93];
blue_color2 = [0.3 0.75 0.93] * 0.75;
gray_color  = [0.8 0.8 0.8];
green_color = [0 0.68 0.3];
yellow_color = [0.95 0.8 0.1];
red_color = [0.65 0.05 0.15];

setappdata(0, 'gui_color_1', blue_color)
setappdata(0, 'gui_color_2', gray_color)
setappdata(0, 'gui_color_3', blue_color2)
setappdata(0, 'gui_color_4', green_color)
setappdata(0, 'gui_color_5', yellow_color)
setappdata(0, 'gui_color_6', red_color)


%% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_Main_Menu wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_Main_Menu_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in load_data_button.
function load_data_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_data_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
manage_windows(1) % Load data
GUI_LoadData


function load_data_button_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pre_process_button.
function pre_process_button_Callback(hObject, eventdata, handles)
% hObject    handle to pre_process_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
manage_windows(2) % Pre process
GUI_choseFrames


% --- Executes on button press in track_button.
function track_button_Callback(hObject, eventdata, handles)
% hObject    handle to track_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
manage_windows(3) % Tracking
GUI_TrackCentrosomes


% --- Executes on button press in results_button.
function results_button_Callback(hObject, eventdata, handles)
% hObject    handle to results_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
manage_windows(4) % Results
GUI_Tracking_Results

function manage_windows(new_window)
% Current Window:
%   - 0: none
%   - 1: Load data
%   - 2: Pre-process data
%   - 3: Track centrosomes
%   - 4: Results

current_window = getappdata(0, 'gui_current_window');

if current_window == 1
        close( GUI_LoadData )
        
elseif current_window == 2
        close( GUI_choseFrames )
        
elseif current_window == 3
        close( GUI_TrackCentrosomes )
        
elseif current_window == 4
       close(GUI_Tracking_Results)
end
    
