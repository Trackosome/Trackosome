function varargout = GUI_FLUCT_Main_menu(varargin)
% GUI_FLUCT_MAIN_MENU MATLAB code for GUI_FLUCT_Main_menu.fig
%      GUI_FLUCT_MAIN_MENU, by itself, creates a new GUI_FLUCT_MAIN_MENU or raises the existing
%      singleton*.
%
%      H = GUI_FLUCT_MAIN_MENU returns the handle to a new GUI_FLUCT_MAIN_MENU or the handle to
%      the existing singleton*.
%
%      GUI_FLUCT_MAIN_MENU('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_FLUCT_MAIN_MENU.M with the given input arguments.
%
%      GUI_FLUCT_MAIN_MENU('Property','Value',...) creates a new GUI_FLUCT_MAIN_MENU or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_FLUCT_Main_menu_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_FLUCT_Main_menu_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_FLUCT_Main_menu

% Last Modified by GUIDE v2.5 09-May-2020 15:22:40

%% Add subfolders:
folder = fileparts(which(mfilename));
addpath(genpath(folder));

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_FLUCT_Main_menu_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_FLUCT_Main_menu_OutputFcn, ...
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


% --- Executes just before GUI_FLUCT_Main_menu is made visible.
function GUI_FLUCT_Main_menu_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_FLUCT_Main_menu (see VARARGIN)

set(hObject, 'Name', '');


%% Menu State

% 0 - empty
% 1 - Single Mode - Loaded
% 2 - Single Mode - Analysed
% 3 - Batch mode - Loaded

state = getappdata(0, 'gui_main_fluct_states');

if state == 1 | state == 2
    set(handles.analyse_button, 'enable', 'on');    
else
    set(handles.analyse_button, 'enable', 'off');   
    setappdata(0, 'gui_main_fluct_states', 0);
end

%% GUI Colors
ready = [0.3 0.75 0.9]; % blue
stop = [0.64 0.08 0.18]; % red
normal = [0.94 0.94 0.94]; % grey
warning = [1 1 0]; % yellow


gui_colors.ready = ready;
gui_colors.stop = stop;
gui_colors.normal = normal;
gui_colors.warning = warning;
setappdata(0, 'gui_colors_fluct', gui_colors)

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

% Choose default command line output for GUI_FLUCT_Main_menu
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_FLUCT_Main_menu wait for user response (see UIRESUME)
% uiwait(handles.load_button);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_FLUCT_Main_menu_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in load_data.
function load_data_Callback(hObject, eventdata, handles)
% hObject    handle to load_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% Choose Files:
searchPath = getappdata(0, 'fluct_searchPath');
if isempty(searchPath)
    searchPath = pwd;
    searchPath = [searchPath '\'];
    setappdata(0, 'fluct_searchPath', searchPath);
end

REFilter = '\.tif$|\.tiff$|\.nd2$|\.mat$';
filenames = uipickfiles('FilterSpec', searchPath, 'REFilter', REFilter);
nFiles = numel(filenames);

%% Open Analysis GUIs:
if  isa(filenames,'double')
    msgbox('No files selected')
    
elseif nFiles == 1
    % Single File Mode: 
    clear_fluct_data
    filename = filenames{1};
    [I, metadata] = Load_Files(filename);    
    [searchPath, ~, ~] = fileparts(filename);
    setappdata(0, 'gui_fluct_I', I);

    if ~isempty(I)        
        setappdata(0, 'gui_fluct_metadata', metadata);
        setappdata(0, 'gui_fluct_masks', cell(metadata.nFrames, 1))
        setappdata(0, 'gui_fluct_finalFilename', filename);        
                
        GUI_FLUCT_Load_Data
        setappdata(0, 'gui_main_fluct_states', 1); % 1 = Loaded: Single Mode
        setappdata(0, 'fluct_searchPath', searchPath);
        set(handles.analyse_button, 'enable', 'on')
    end
    
elseif nFiles > 1
    % Batch Mode:
    GUI_Fluct_Batch_Mode(filenames)
    setappdata(0, 'gui_main_fluct_states', 3); % 3 = Loaded: Batch mode
end


% --- Executes on button press in analyse_button.
function analyse_button_Callback(hObject, eventdata, handles)
% hObject    handle to analyse_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
state = getappdata(0, 'gui_main_fluct_states');

if state == 1 % Single Mode: Loaded
    GUI_FLUCT_Load_Data
elseif state == 2 % Single Mode: Results 
    GUI_FLUCT_Results    
end
    
% --- Executes on button press in load_saved_data.
function load_saved_data_Callback(hObject, eventdata, handles)
% hObject    handle to load_saved_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

path = getappdata(0, 'fluct_gui_savePath');

if isempty(path)   
    path = getappdata(0, 'fluct_searchPath');    
    if isempty(path)
        path = pwd;
    end    
end

try
    [filename, dirname] = uigetfile([path '\' '*.mat'], 'Choose a .mat previously exported with "Membrane Fluctuations" module');
    
    load([dirname filename], 'I', 'metadata', 'filename', 'results', 'settings')
    
    if exist('I','var')        
        setappdata(0, 'gui_fluct_I', I);
        setappdata(0, 'gui_fluct_metadata', metadata);
        setappdata(0, 'gui_fluct_results', results);
        setappdata(0, 'gui_fluct_finalFilename', filename);
        setappdata(0, 'gui_main_fluct_settings', settings)        
        Iproj = squeeze(median(I,3));
        setappdata(0, 'gui_fluct_Iproj', Iproj);
        setappdata(0, 'gui_fluct_memb_coords', results.memb_coords_raw);
        setappdata(0, 'gui_main_fluct_states', 1);
        GUI_FLUCT_Results
    else
        msgbox('ERROR! File does not contain image stack. It may have been analysed in batch mode, which does not store the images for memory purposes')
    end
catch
    msgbox('File not loaded. Make sure you select a file previously exported by "Membrane Fluctuations" module"')
end
