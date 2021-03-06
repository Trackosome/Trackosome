function varargout = GUI_LoadData(varargin)
% Domingos Leite de Castro, domingos.castro@i3s.up.pt
% Paulo de Castro Aguiar, pauloaguiar@ineb.up.pt

% GUI_LOADDATA MATLAB code for GUI_LoadData.fig
%      GUI_LOADDATA, by itself, creates a new GUI_LOADDATA or raises the existing
%      singleton*.
%
%      H = GUI_LOADDATA returns the handle to a new GUI_LOADDATA or the handle to
%      the existing singleton*.
%
%      GUI_LOADDATA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_LOADDATA.M with the given input arguments.
%
%      GUI_LOADDATA('Property','Value',...) creates a new GUI_LOADDATA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_LoadData_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_LoadData_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_LoadData

% Last Modified by GUIDE v2.5 14-Oct-2020 15:30:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GUI_LoadData_OpeningFcn, ...
    'gui_OutputFcn',  @GUI_LoadData_OutputFcn, ...
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


% --- Executes just before GUI_LoadData is made visible.
function GUI_LoadData_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_LoadData (see VARARGIN)

% Choose default command line output for GUI_LoadData
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

set(hObject, 'Name', 'Load Data');

setappdata(0, 'gui_current_window', 1)
%% Set the correct State:
% States:
%   0 - load CS
%   1 - load NM or CM
%   2 - Cropping Images

LoadData_vars = getappdata(0, 'gui_LoadData_vars');
LoadData_state = getappdata(0, 'gui_LoadData_state');

if isempty(LoadData_vars)
    [~, LoadData_state] = reset_LoadData_vars;
else % show
    metadata = getappdata(0, 'gui_metadata');
    try
        show_imgs(LoadData_vars, handles)
    catch
    end
end

% handles for all buttons:
handles.h_all_buttons = [handles.load_CS_button, handles.load_NM_button, handles.load_CM_button,...
    handles.next_button, handles.back_button, handles.crop_button, handles.save_crop_button, ...
    handles.cancel_trim_button, handles.metadata_button, handles.load_saved_data_button];

% set axes
set(handles.CS_axes, 'box', 'on','xcolor', [0.7 0.7 0.7], 'ycolor', [0.7 0.7 0.7],...
    'xticklabels', [], 'yticklabels', [], 'xtick', [], 'ytick', [])
set(handles.NM_axes, 'box', 'on','xcolor', [0.7 0.7 0.7], 'ycolor', [0.7 0.7 0.7],...
    'xticklabels', [], 'yticklabels', [], 'xtick', [], 'ytick', [])
set(handles.CM_axes, 'box', 'on','xcolor', [0.7 0.7 0.7], 'ycolor', [0.7 0.7 0.7],...
    'xticklabels', [], 'yticklabels', [], 'xtick', [], 'ytick', [])

guidata(hObject, handles)
manageButtons(handles, LoadData_state)

% UIWAIT makes GUI_LoadData wait for user response (see UIRESUME)
% uiwait(handles.figure1);


function [LoadData_vars,LoadData_state] = reset_LoadData_vars
LoadData_state = 0;
LoadData_vars.with_CS = 0;
LoadData_vars.with_NM = 0;
LoadData_vars.with_CM = 0;
LoadData_vars.CS_filename = [];
LoadData_vars.NM_filename = [];
LoadData_vars.CM_filename = [];
setappdata(0, 'gui_LoadData_vars', LoadData_vars)
setappdata(0, 'gui_LoadData_state', LoadData_state)



function show_imgs(LoadData_vars, handles)
text = 'No files in application data';
Img_C = getappdata(0, 'gui_Img_C');
Img_NM = getappdata(0, 'gui_Img_NM');
Img_CM = getappdata(0, 'gui_Img_CM');
metadata = getappdata(0, 'gui_metadata');

if ~isempty(Img_C)
    meta_text = plot_imgs(handles.CS_axes, Img_C, LoadData_vars.CS_filename, handles.CS_file_text, metadata.px2um);
    text = ['Centrosomes File         -  ', meta_text];
else
    cla(handles.CS_axes)
    set(handles.CS_file_text, 'string', '')
end


if ~isempty(Img_NM)
    meta_text = plot_imgs(handles.NM_axes, Img_NM, LoadData_vars.NM_filename, handles.NM_file_text, metadata.px2um);
    text = [text newline 'Nuclear Membrane File    -  ' meta_text];
else
    cla(handles.NM_axes)
    set(handles.NM_file_text, 'string', '')
end


if ~isempty(Img_CM)
    meta_text = plot_imgs(handles.CM_axes, Img_CM, LoadData_vars.CM_filename, handles.CM_file_text, metadata.px2um);
    text = [text newline 'Cellular Membrane File   -  ' meta_text];
else
    cla(handles.CM_axes)
    set(handles.CM_file_text, 'string', '')
end

set(handles.state_text_box, 'string', text)


function text = plot_imgs(img_axes, Img, filename, file_text_handles, px2um)
[~,~,stacks,nFrames] = size(Img);
imagesc(img_axes, squeeze(max(Img(:,:,:,1),[],3)))
set(img_axes,'FontSize',7)
text = ['Nr Frames: ' num2str(nFrames) '  -  Nr Stacks: ' num2str(stacks) '  -  Filename: ' filename  , newline newline];
set(file_text_handles, 'string', filename)

ticks_and_labels(img_axes, px2um)



% --- Outputs from this function are returned to the command line.
function varargout = GUI_LoadData_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in next_button.
function next_button_Callback(hObject, eventdata, handles)
% hObject    handle to next_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(GUI_LoadData)
GUI_choseFrames


% --- Executes on button press in back_button.
function back_button_Callback(hObject, eventdata, handles)
% hObject    handle to back_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(GUI_LoadData)
GUI_Main_Menu

% --- Executes on button press in load_CS_button.
function load_CS_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_CS_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Import Centrosomes Channel:

LoadData_state = getappdata(0, 'gui_LoadData_state');
LoadData_vars  = getappdata(0, 'gui_LoadData_vars' );
metadata = getappdata(0, 'gui_metadata');

searchPath = getappdata(0, 'searchPath');
if isempty(searchPath)
    searchPath = pwd;
    searchPath = [searchPath '\'];
end

[CS_filename, dirname] = uigetfile([searchPath '*.tif;*.tiff;*.mat;*.nd2'], ...
    'Choose a TIFF, MAT or ND2 file of CENTROSOMES CHANNEL');

try
    text_import_CS = ['Importing CENTROSOME channel image.' newline newline 'File: '...
        CS_filename newline newline 'Please wait...' newline];
    set(handles.state_text_box,'string',text_import_CS);
    h_all_buttons = handles.h_all_buttons ;
    set(h_all_buttons, 'Enable', 'off')
    lock_menu_buttons()
    pause(0.01)
    
    % Import File:
    [Imgs, nChannels, finalFilename, metadata] = Load_file([dirname, CS_filename], metadata);
    Img_C = Imgs{1};
    Img_NM = Imgs{2};
    Img_CM = Imgs{3};
    
    set(handles.CS_file_text, 'string', CS_filename)
    set(handles.state_text_box,'string', [text_import_CS newline 'Done']);
    
    LoadData_vars.CS_filename = CS_filename;
    
    LoadData_vars.with_CS = 1;
    LoadData_vars.with_NM = ~isempty(Img_NM);
    LoadData_vars.with_CM = ~isempty(Img_CM);
    
    
    if metadata.nStacks > 1
            LoadData_state = 1;
    else
        m = msgbox('You inserted a 2D file! This module requires 3D data');
        set( m,'WindowStyle','modal')
        LoadData_state = 0;
    end
    
    %% Clear old data:
    clear_LoadData_data;
    clear_track_data;
    clear_ChooseFrames_data;
    clear_results_data;
    
    %% Set new Data:
    setappdata(0, 'gui_Img_C', Img_C)
    setappdata(0, 'gui_Img_NM', Img_NM)
    setappdata(0, 'gui_Img_CM', Img_CM)
    setappdata(0, 'gui_metadata', metadata)
    setappdata(0, 'gui_Preprocess_vars', [])
    setappdata(0, 'gui_finalFilename', finalFilename);
    setappdata(0, 'gui_LoadData_vars', LoadData_vars)
    setappdata(0, 'gui_LoadData_state', LoadData_state)
    setappdata(0, 'searchPath', dirname)
    setappdata(0, 'gui_Img_threshs', []);
    
    if LoadData_state > 0
        metadataInput();
    end
    axes(handles.CS_axes)
    set(gca,'FontSize',7)
    
catch
end

if isempty(metadata)
    set(handles.state_text_box, 'string', 'No files in application data')
else
    show_imgs(LoadData_vars, handles)
end

% Set buttons states:
manageButtons(handles, LoadData_state)
update_menu_buttons([]);
guidata(hObject, handles)


% --- Executes on button press in load_NM_button.
function load_NM_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_NM_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Import Nucleus Membrane Channel:

searchPath = getappdata(0, 'searchPath');
LoadData_vars = getappdata(0, 'gui_LoadData_vars');
LoadData_state = getappdata(0, 'gui_LoadData_state');
metadata = getappdata(0, 'gui_metadata');

[NM_filename, dirname] = uigetfile([searchPath '*.tif;*.tiff;*.mat;*.nd2'],...
    'Choose a TIFF stack+time file (8bits) with NUCLEUS MEMBRANE CHANNEL');

try
    [~, ~, ext] = fileparts(NM_filename);
    NM_file = [dirname, NM_filename];
    
    text_import_NM = ['Importing NUCLEUS MEMBRANE channel image.' newline newline...
        'File: ' NM_file  newline newline 'Please wait...' newline];
    set(handles.state_text_box,'string',text_import_NM);
    h_all_buttons = handles.h_all_buttons ;
    set(h_all_buttons, 'Enable', 'off')
    lock_menu_buttons()
    pause(0.01)
    
    % Import File:
    [Imgs, nChannels, finalFilename, metadata] = Load_file([dirname, NM_filename], metadata);
    Img_NM = Imgs{1};
    
    set(handles.state_text_box,'string', [text_import_NM newline 'Done']);
    set(handles.NM_file_text, 'string', NM_filename)
    
    setappdata(0, 'gui_Img_NM', Img_NM)
    
    LoadData_vars.NM_filename = NM_filename;    
    LoadData_vars.with_NM = ~isempty(Img_NM);
    
    setappdata(0, 'gui_LoadData_vars', LoadData_vars)
    setappdata(0, 'gui_LoadData_state', LoadData_state);
    axes(handles.NM_axes)
    set(gca,'FontSize',7)
    
    check_image_size(SizeX, SizeY,  nStacks, nFrames, metadata)
catch
end

show_imgs(LoadData_vars, handles)

% Set buttons states:
manageButtons(handles, LoadData_state)
update_menu_buttons([])
guidata(hObject, handles)


% --- Executes on button press in load_CM_button.
function load_CM_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_CM_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Import Cell Membrane Channel

searchPath = getappdata(0, 'searchPath');

[CM_filename, dirname] = uigetfile([searchPath '*.tif;*.tiff;*.mat'],...
    'Choose a TIFF stack+time file (8bits) with CELLULAR MEMBRANE CHANNEL');
[~, ~, ext] = fileparts(CM_filename);
CM_file = [dirname, CM_filename];

text_import_CM = ['Importing CELL MEMBRANE channel image.' newline newline...
    'File: ' CM_file  newline newline 'Please wait...' newline];
set(handles.state_text_box,'string',text_import_CM);
h_all_buttons = handles.h_all_buttons ;
set(h_all_buttons, 'Enable', 'off')
lock_menu_buttons()

pause(0.01)
LoadData_vars = getappdata(0, 'gui_LoadData_vars');
LoadData_state = getappdata(0, 'gui_LoadData_state');
metadata = getappdata(0, 'gui_metadata');

try
    if strcmp(ext, '.tiff') ||  strcmp(ext, '.tif')
        [Img_CM, metadata.SizeX, metadata.SizeY,  metadata.nStacks, metadata.nFrames, ~,...
            ~, ~] = Import_Microscope_Tiff_Stack( CM_file );
    elseif strcmp(ext, '.mat')
        S = load(CM_file);
        C = struct2cell(S);
        Img_CM = C{1};
    end
    
    set(handles.state_text_box,'string', [text_import_CM newline 'Done']);
    set(handles.CM_file_text, 'string', CM_filename)
    
    setappdata(0, 'gui_Img_CM', Img_CM)
    
    LoadData_vars.CM_filename = CM_filename;
    LoadData_vars.with_CM = 1;
    setappdata(0, 'gui_LoadData_vars', LoadData_vars)
    
    axes(handles.CM_axes)
    set(gca,'FontSize', 7)
    check_image_size(SizeX, SizeY,  nStacks, nFrames, metadata)
catch
end

show_imgs(LoadData_vars, handles)

% Set buttons states:
manageButtons(handles, LoadData_state)
update_menu_buttons([])
guidata(hObject, handles)


% --- Executes on button press in save_crop_button.
function save_crop_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_crop_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(hObject, 'enable', 'off')

Img_C = getappdata(0, 'gui_Img_C');
LoadData_vars = getappdata(0, 'gui_LoadData_vars');
metadata = getappdata(0, 'gui_metadata');

% Select part of the image
h_rect = handles.h_rect;
pos_rect = h_rect.getPosition();
pos_rect = ceil(pos_rect);
[nlines, ncols] = size(Img_C(:,:, 1, 1));

li = max(pos_rect(2), 1);
lf = min(pos_rect(2) + pos_rect(4), nlines);
ci = max(pos_rect(1), 1);
cf = min(pos_rect(1) + pos_rect(3), ncols);

Img_C = Img_C(li:lf, ci:cf, :, :);

if LoadData_vars.with_NM    
    Img_NM = getappdata(0, 'gui_Img_NM');
    Img_NM = Img_NM(li:lf, ci:cf, :, :);
    setappdata(0, 'gui_Img_NM', Img_NM)
end

if LoadData_vars.with_CM
    Img_CM = getappdata(0, 'gui_Img_CM');
    Img_CM = Img_CM(li:lf, ci:cf, :, :);
    setappdata(0, 'gui_Img_CM', Img_CM)
end

delete(h_rect)
[metadata.SizeY, metadata.SizeX, ~, ~] = size(Img_C);

LoadData_state = 1;
setappdata(0, 'gui_Img_C', Img_C)
setappdata(0, 'gui_LoadData_vars', LoadData_vars)
setappdata(0, 'gui_metadata', metadata)
setappdata(0, 'gui_results_NM_vars', []);
setappdata(0, 'gui_results_CM_vars', []);
show_imgs(LoadData_vars, handles)
manageButtons(handles, LoadData_state)
guidata(hObject, handles)


% --- Executes on button press in cancel_trim_button.
function cancel_trim_button_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_trim_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h_rect = handles.h_rect;
delete(h_rect)
manageButtons(handles, 2) % state = 2 --> go back to previous state after cropping
guidata(hObject, handles)
set(handles.state_text_box, 'String', '')

function manageButtons(handles, state)
blue_color = getappdata(0, 'gui_color_1');
gray_color = getappdata(0, 'gui_color_2');
LoadData_vars = getappdata(0, 'gui_LoadData_vars');

if state == 0 % Load CS
    set(handles.load_CS_button,'Enable','on')
    set(handles.load_NM_button,'Enable','off')
    set(handles.load_CM_button,'Enable','off')
    set(handles.next_button,'Enable','off')
    set(handles.back_button,'Enable','on')
    set(handles.crop_button,'Enable','off')
    set(handles.save_crop_button,'Enable','off', 'BackgroundColor', gray_color)
    set(handles.cancel_trim_button,'Enable','off')
    set(handles.metadata_button,'Enable','off')
    set(handles.load_saved_data_button,'Enable','on')
    set(handles.swap_button_1,'Enable','off')
    set(handles.swap_button_2,'Enable','off')
    
elseif state == 1 % CS loaded. Load NM or CM
    set(handles.load_CS_button,'Enable','on')
    set(handles.load_NM_button,'Enable','on')
    set(handles.load_CM_button,'Enable','on')
    set(handles.next_button,'Enable','on')
    set(handles.back_button,'Enable','on')
    set(handles.crop_button,'Enable','on')
    set(handles.save_crop_button,'Enable','off', 'BackgroundColor', gray_color)
    set(handles.cancel_trim_button,'Enable','off')
    set(handles.metadata_button,'Enable','on')
    set(handles.metadata_button,'Enable','on')
    set(handles.load_saved_data_button,'Enable','on')    
    manage_swap_buttons(handles);
    
% elseif state == 2 % Load CM or proceed
%     set(handles.load_CS_button,'Enable','on')
%     set(handles.load_NM_button,'Enable','on')
%     set(handles.load_CM_button,'Enable','on')
%     set(handles.next_button,'Enable','on')
%     set(handles.back_button,'Enable','on')
%     set(handles.crop_button,'Enable','on')
%     set(handles.save_crop_button,'Enable','off', 'BackgroundColor', gray_color)
%     set(handles.cancel_trim_button,'Enable','off')
%     set(handles.metadata_button,'Enable','on')
%     set(handles.load_saved_data_button,'Enable','on')
%     set(handles.swap_button_1,'Enable','on')
%     set(handles.swap_button_2,'Enable','on')
    
elseif state == 2 % Croping
    set(handles.load_CS_button,'Enable','off')
    set(handles.load_NM_button,'Enable','off')
    set(handles.load_CM_button,'Enable','off')
    set(handles.next_button,'Enable','off')
    set(handles.back_button,'Enable','off')
    set(handles.crop_button,'Enable','off')
    set(handles.save_crop_button,'Enable','on', 'BackgroundColor', blue_color)
    set(handles.cancel_trim_button,'Enable','on')
    set(handles.metadata_button,'Enable','off')
    set(handles.load_saved_data_button,'Enable','off')
    set(handles.swap_button_1,'Enable','off')
    set(handles.swap_button_2,'Enable','off')
end


function manage_swap_buttons(handles)
LoadData_vars = getappdata(0, 'gui_LoadData_vars');

if LoadData_vars.with_NM
    set(handles.swap_button_1,'Enable','on')
    set(handles.swap_button_2,'Enable','on')
elseif LoadData_vars.with_CM
    set(handles.swap_button_1,'Enable','off')
    set(handles.swap_button_2,'Enable','on')
else
    set(handles.swap_button_1,'Enable','off')
    set(handles.swap_button_2,'Enable','off')
end

%% Set Menu Buttons
% update_menu_buttons([])


% --- Executes on button press in metadata_button.
function metadata_button_Callback(hObject, eventdata, handles)
% hObject    handle to metadata_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
metadata = metadataInput();
LoadData_vars = getappdata(0, 'gui_LoadData_vars');
show_imgs(LoadData_vars, handles)


function metadata = metadataInput()
% Load Parameters:
metadata = getappdata(0, 'gui_metadata');
frame_step = metadata.frame_step;
z_step = metadata.z_step;
px2um = metadata.px2um;
Img_C = getappdata(0, 'gui_Img_C');
Img_NM = getappdata(0, 'gui_Img_NM');
Img_CM = getappdata(0, 'gui_Img_CM');

size_Img = size(Img_C);
if length(size_Img) == 3
    [nFrames] = size_Img(3);
    nStacks = 1;
else
    [nStacks] = size_Img(3);
    [nFrames] = size_Img(4);
end

% Get user input regarding image sequence:
prompt   = {'centrosome radius in px',  'frame step [s]', 'z step [um]',...
    'px2um [\mum/px]', 'N� Stacks', 'N� Frames'};
name     = 'Check parameters';
numlines = [1, 30];

try
    centrosome_radius_px = metadata.centrosome_radius_px;
catch
    centrosome_radius_px = 4; % px
end

defaultanswer   = { num2str(centrosome_radius_px), num2str(metadata.frame_step),...
    num2str(metadata.z_step), num2str(metadata.px2um), num2str(nStacks), num2str(nFrames)};
options.Interpreter = 'tex';
valid = false;

while ~valid
answer = inputdlg( prompt, name, numlines, defaultanswer, options );

answers_double = str2double(answer);
invalid_idx = find(isnan(answers_double));
invalid_idx = [invalid_idx find(answers_double == 0)];

if invalid_idx
    msg = 'Invalid Inputs: ';
    for i = 1:length(invalid_idx)
        msg = [msg newline prompt{invalid_idx(i)}];
    end
    m = msgbox(msg);
    pos = get(m, 'position');
    set(m, 'position', [pos(1) - 200, pos(2:end)])
    
    options.WindowStyle = 'normal';
else
    valid = true;
end

end


try
    centrosome_radius_px = str2double( answer{1} ); %px
    frame_step = str2double( answer{2} );
    z_step = str2double( answer{3} );
    px2um = str2double( answer{4} );
    ratio_z_xy_px = z_step/px2um;
    new_nStacks = str2double( answer{5} );
    new_nFrames = str2double( answer{6} );
    if (new_nFrames * new_nStacks) ~= (nStacks * nFrames)
        msgbox(['N� Stacks x N� Frames must be equal to: ', num2str(nStacks * nFrames)])
    else
        Img_C = reshape(Img_C,[size_Img(1), size_Img(2), new_nStacks, new_nFrames]);
        
        try
            Img_NM = reshape(Img_NM,[size_Img(1), size_Img(2), new_nStacks, new_nFrames]);
        catch
        end
        
        try
            Img_CM = reshape(Img_CM,[size_Img(1), size_Img(2), new_nStacks, new_nFrames]);
        catch
        end
        metadata.nStacks = new_nStacks;
        metadata.nFrames = new_nFrames;
    end
catch
    centrosome_radius_px = str2double( '5.0' ); %px
    ratio_z_xy_px = z_step/px2um;
end

metadata.z_step = z_step;
metadata.px2um = px2um;
metadata.frame_step = frame_step;
metadata.centrosome_radius_px = centrosome_radius_px;
metadata.ratio_z_xy_px = ratio_z_xy_px;
setappdata(0, 'gui_metadata', metadata)
setappdata(0,'gui_Img_C', Img_C)
setappdata(0,'gui_Img_NM', Img_NM)
setappdata(0,'gui_Img_CM', Img_CM)


% --- Executes on button press in load_saved_data_button.
function load_saved_data_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_saved_data_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
path = getappdata(0, 'savePath');
if isempty(path)
    path = pwd;
end

[file, path] = uigetfile(path);

if file
    try
        
        filename = horzcat(char(path), char(file));
        
        set(handles.state_text_box, 'string', [' Loading ' file '...'])
        pause(0.001)
        
        s = load(filename);
        clear_LoadData_data;
        clear_track_data;
        clear_ChooseFrames_data;
        clear_results_data;
        
        try
            version = s.GUI_vars.Trackosome_version;
        catch
            version = 3;
        end
        
        if version == 4
            
            gui_Preprocess_vars = s.GUI_vars.Preprocess_vars;
            gui_Img_C = s.Img_CS;
            gui_Img_NM = s.Img_NM;
            gui_Img_CM = s.Img_CM;
            gui_metadata = s.metadata;
            gui_LoadData_vars = s.GUI_vars.LoadData_vars;
            gui_LoadData_state = s.GUI_vars.LoadData_vars.state;
            savePath = s.savePath;
            
            gui_track_CS_x_px = s.CS_vars.coords_px_stack.x_px;
            gui_track_CS_y_px = s.CS_vars.coords_px_stack.y_px;
            gui_track_CS_z_stack = s.CS_vars.coords_px_stack.z_stack;
            
            gui_track_ROI_pos = s.GUI_vars.Track_vars.ROI_pos;
            gui_track_tracking_state = s.GUI_vars.Track_vars.tracking_state;
            gui_track_results_available = s.GUI_vars.Track_vars.results_available;
            gui_track_activatedFrames = s.GUI_vars.Track_vars.activatedFrames;
            gui_track_default_settings = s.GUI_vars.Track_vars.default_settings;
            
            gui_results_CS_coords_um = s.CS_vars.coords_um;
            gui_results_CS_coords_um_centered = s.CS_vars.coords_um_centered;
            gui_results_NM_vars = s.NM_vars;
            gui_results_CM_vars = s.CM_vars;
            gui_results_CS_dist = s.CS_vars.CS_dist;
            gui_results_CS_angles = s.CS_vars.CS_angles;
            
        elseif version == 3
            gui_Preprocess_vars = s.gui_Preprocess_vars;
            gui_Img_C = s.gui_Img_C;
            gui_Img_NM = s.gui_Img_NM;
            gui_Img_CM = s.gui_Img_CM;
            gui_metadata = s.gui_metadata;
            gui_LoadData_vars = s.gui_LoadData_vars;
            gui_LoadData_state = s.gui_LoadData_state;
            savePath = s.savePath;
            
            gui_track_CS_x_px = s.gui_track_CS_x_px;
            gui_track_CS_y_px = s.gui_track_CS_y_px;
            gui_track_CS_z_stack = s.gui_track_CS_z_stack;
            gui_track_ROI_pos = s.gui_track_ROI_pos;
            gui_track_tracking_state = s.gui_track_tracking_state;
            gui_track_results_available = s.gui_track_results_available;
            gui_track_activatedFrames = s.gui_track_activatedFrames;
            gui_track_default_settings = s.gui_track_default_settings;
            
            gui_results_CS_coords_um = s.gui_results_CS_coords_um;
            gui_results_CS_coords_um_centered = s.gui_results_CS_coords_um_centered;
            gui_results_NM_vars = s.gui_results_NM_vars;
            gui_results_CM_vars = s.gui_results_CM_vars;
            gui_results_CS_dist = s.gui_results_CS_dist;
            gui_results_CS_angles = s.gui_results_CS_angles;
            
        end
        
        setappdata(0, 'gui_finalFilename', file(1:end-4))
        setappdata(0, 'gui_Preprocess_vars', gui_Preprocess_vars)
        setappdata(0, 'gui_Img_C', gui_Img_C)
        setappdata(0, 'gui_Img_NM', gui_Img_NM)
        setappdata(0, 'gui_Img_CM', gui_Img_CM)
        setappdata(0, 'gui_metadata', gui_metadata)
        setappdata(0, 'gui_LoadData_vars', gui_LoadData_vars)
        setappdata(0, 'gui_LoadData_state', gui_LoadData_state)
        setappdata(0, 'savePath', savePath)
        setappdata(0, 'gui_Img_threshs', []);
        
        setappdata(0, 'gui_track_CS_x_px', gui_track_CS_x_px)
        setappdata(0, 'gui_track_CS_y_px', gui_track_CS_y_px)
        setappdata(0, 'gui_track_CS_z_stack', gui_track_CS_z_stack)
        setappdata(0, 'gui_track_ROI_pos', gui_track_ROI_pos)
        setappdata(0, 'gui_track_startingFrame', 1)
        setappdata(0, 'gui_track_stopTracking', false)
        setappdata(0, 'gui_track_currentFrame', 1)
        setappdata(0, 'gui_track_warnings', []);
        setappdata(0, 'gui_track_tracking_state', gui_track_tracking_state)
        setappdata(0, 'gui_track_results_available', gui_track_results_available)
        setappdata(0, 'gui_track_activatedFrames', gui_track_activatedFrames)
        setappdata(0, 'gui_track_default_settings', gui_track_default_settings)
        
        setappdata(0, 'gui_results_CS_coords_um', gui_results_CS_coords_um);
        setappdata(0, 'gui_results_CS_coords_um_centered', gui_results_CS_coords_um_centered);
        setappdata(0, 'gui_results_NM_vars', gui_results_NM_vars);
        setappdata(0, 'gui_results_CM_vars', gui_results_CM_vars);
        setappdata(0, 'gui_results_CS_dist', gui_results_CS_dist);
        setappdata(0, 'gui_results_CS_angles', gui_results_CS_angles);
        
        guidata(hObject, handles)
        manageButtons(handles, gui_LoadData_state)
        
    catch
        set(handles.state_text_box, 'string', [' Error loading ' file '...'])
        msgbox([' Error loading ' file '...'])
    end
end

try
    show_imgs(gui_LoadData_vars, handles);
catch
end

%% Set Menu Buttons
update_menu_buttons([])


% --- Executes during object creation, after setting all properties.
function crop_button_CreateFcn(hObject, eventdata, handles)
% hObject    handle to crop_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


function crop_button_Callback(hObject, eventdata, handles)
h_all_buttons = handles.h_all_buttons;
set(h_all_buttons, 'Enable', 'off')
set(handles.state_text_box, 'String', [newline '   Select the Cell in Centrosomes Projection image'])

h_rect = imrect(handles.CS_axes);

manageButtons(handles, 2); % state 2 --> cropping

handles.h_rect  = h_rect ;
guidata(hObject, handles)


function check_image_size(SizeX, SizeY,  nStacks, nFrames, metadata)

warning = 0;
text = [];
if metadata.SizeX ~= SizeX
    warning = 1;
    text = [text ' size X; '];
end

if metadata.SizeY ~= SizeY
    warning = 1;
    text = [text ' size Y; '];
end

if metadata.nStacks ~= nStacks
    warning = 1;
    text = [text ' nr Stacks; '];
end

if metadata.nFrames ~= nFrames
    warning = 1;
    text = [text ' nr Frames; '];
end

if warning == 1
    m = msgbox(['Tiff stack parameters not compatible with Centrosome tiff stack: ' text]);
    WinOnTop(m);
end



% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in swap_button_1.
function swap_button_1_Callback(hObject, eventdata, handles)
% hObject    handle to swap_button_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% Swap Centrosomes and Nuclear Membrane files
Img_C = getappdata(0, 'gui_Img_C');
Img_NM = getappdata(0, 'gui_Img_NM');
setappdata(0, 'gui_Img_C', Img_NM);
setappdata(0, 'gui_Img_NM', Img_C);
LoadData_vars = getappdata(0, 'gui_LoadData_vars');
NM_vars = getappdata(0, 'gui_results_NM_vars');

if ~isempty(NM_vars)
    warndlg('You already have results analysed for this Nuclear Membrane. Changing channel now may lead to unpredictable behaviour!')    
end

CS_name = LoadData_vars.CS_filename;
NM_name = LoadData_vars.NM_filename;

LoadData_vars.CS_filename = NM_name;
LoadData_vars.NM_filename = CS_name;

with_CS_temp = LoadData_vars.with_CS;
LoadData_vars.with_CS = LoadData_vars.with_NM ;
LoadData_vars.with_NM = with_CS_temp;


show_imgs(LoadData_vars, handles)
setappdata(0, 'gui_LoadData_vars', LoadData_vars)
manage_swap_buttons(handles)


% --- Executes on button press in swap_button_2.
function swap_button_2_Callback(hObject, eventdata, handles)
% hObject    handle to swap_button_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% Swap Nuclear Membrane and Cellular Membrane files
Img_NM = getappdata(0, 'gui_Img_NM');
Img_CM = getappdata(0, 'gui_Img_CM');
setappdata(0, 'gui_Img_NM', Img_CM);
setappdata(0, 'gui_Img_CM', Img_NM);
LoadData_vars = getappdata(0, 'gui_LoadData_vars');

NM_vars = getappdata(0, 'gui_results_NM_vars');
CM_vars = getappdata(0, 'gui_results_CM_vars');
if ~isempty(NM_vars) ||  ~isempty(CM_vars)
    warndlg('You already have results analysed for this channels. Changing channels now may lead to unpredictable behaviour!')    
end


CM_name = LoadData_vars.CM_filename;
NM_name = LoadData_vars.NM_filename;

LoadData_vars.CM_filename = NM_name;
LoadData_vars.NM_filename = CM_name;

with_CM_temp = LoadData_vars.with_CM;
LoadData_vars.with_CM = LoadData_vars.with_NM ;
LoadData_vars.with_NM = with_CM_temp;

show_imgs(LoadData_vars, handles)
setappdata(0, 'gui_LoadData_vars', LoadData_vars)
manage_swap_buttons(handles)
