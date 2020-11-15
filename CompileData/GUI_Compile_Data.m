function varargout = GUI_Compile_Data(varargin)
% GUI_COMPILE_DATA MATLAB code for GUI_Compile_Data.fig
%      GUI_COMPILE_DATA, by itself, creates a new GUI_COMPILE_DATA or raises the existing
%      singleton*.
%
%      H = GUI_COMPILE_DATA returns the handle to a new GUI_COMPILE_DATA or the handle to
%      the existing singleton*.
%
%      GUI_COMPILE_DATA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_COMPILE_DATA.M with the given input arguments.
%
%      GUI_COMPILE_DATA('Property','Value',...) creates a new GUI_COMPILE_DATA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_Compile_Data_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_Compile_Data_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_Compile_Data

% Last Modified by GUIDE v2.5 12-Feb-2020 20:30:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GUI_Compile_Data_OpeningFcn, ...
    'gui_OutputFcn',  @GUI_Compile_Data_OutputFcn, ...
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


% --- Executes just before GUI_Compile_Data is made visible.
function GUI_Compile_Data_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_Compile_Data (see VARARGIN)

% Choose default command line output for GUI_Compile_Data
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

path = getappdata(0, 'savePath');
set(handles.save_path_edit, 'string', path)

% UIWAIT makes GUI_Compile_Data wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_Compile_Data_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




% --- Executes on button press in import_button.
function import_button_Callback(hObject, eventdata, handles)
% hObject    handle to import_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

path = getappdata(0, 'savePath');
if isempty(path)
    path = pwd;
end

defaultFileName = fullfile(path, '*.csv');
[allFilenames, folder] = uigetfile(defaultFileName, 'Select a file', 'MultiSelect', 'on');
setappdata(0, 'gui_compile_allFilenames', allFilenames)
setappdata(0, 'gui_compile_loadFolder', folder)

% --- Executes on button press in compile_button.
function compile_button_Callback(hObject, eventdata, handles)
% hObject    handle to compile_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

savePath = getappdata(0, 'savePath');
filename = getappdata(0, 'gui_compile_filename');
allFilenames = getappdata(0, 'gui_compile_allFilenames');
folder = getappdata(0, 'gui_compile_loadFolder');

if isa(allFilenames, 'cell')
    nFiles = numel(allFilenames);
    
    
    % LABELS:
    % 1,  'Time'
    % 2,  'CS_Raw_X1';
    % 3,  'CS_Raw_Y1';
    % 4,  'CS_Raw_Z1';
    % 5,  'CS_Raw_X2';
    % 6,  'CS_Raw_Y2';
    % 7,  'CS_Raw_Z2';
    % 8,  'CS_Centered_X1';
    % 9,  'CS_Centered_Y1';
    % 10,  'CS_Centered_Z1';
    % 11, 'CS_Centered_X2';
    % 12, 'CS_Centered_Y2';
    % 13, 'CS_Centered_Z2';
    % 14, 'CS_distances';
    % 15, 'CS_centroid_angles';
    % 16, 'NM_centroid_X';
    % 17, 'NM_centroid_Y';
    % 18, 'NM_centroid_Z';
    % 19, 'CS_vector_NM_axis_angles';
    % 20, 'NM_eccentricity';
    % 21, 'NM_irregularity';
    % 22, 'CM_centroid_X';
    % 23, 'CM_centroid_Y';
    % 24, 'CM_centroid_Z';
    % 25, 'CS_vector_CM_axis_angles';
    % 26, 'NM_CM_axis_angles';
    % 27, 'CM_eccentricity';
    % 28, 'CM_irregularity';
    
    compilationFilename = [savePath, filename, '.xlsx'];
    
    sheets = {'Centrosome_Distances', 'Centrosome_Angles' , 'Nucleus_Eccentricity',...
        'Nucleus_Irregularity', 'Cell_Eccentricity', 'Cell_Irregularity',  ...
        'Centrosome-Nucleus Angles', 'Centrosome-Cell_Angles', 'Cell-Nucleus_Angles'};
    
    cell_all_tables = cell(numel(sheets),1);
    cell_all_infos = cell(numel(sheets),1);
    
    max_nFrames = 0;
    
    for file_i = 1:nFiles
        
        data = csvread([folder allFilenames{file_i}]);
        organized_data = data(:, [14, 15, 20, 21, 27, 28, 19, 25, 26]);
        times = data(:,1);
        dt = times(2) - times(1);
        
        max_nFrames = max(max_nFrames, length(times));
        
        for sheet_i= 1:numel(sheets)
            
            cell_data_col =  {organized_data(:,sheet_i)};
            cell_all_tables{sheet_i} = [cell_all_tables{sheet_i} cell_data_col];
            cell_all_infos{sheet_i} = cat(2, cell_all_infos{sheet_i}, {allFilenames{file_i}(1:end-4); 'Time step'; dt; sheets{sheet_i}} );
            
        end
        
    end
    
    w = waitbar(0, 'Exporting to excel...');
    
    for sheet_i= 1:numel(sheets)       
        
        cell_table = cell_all_tables{sheet_i};
        cell_table = cellfun(@(x)[x(1:end); NaN(max_nFrames-length(x),1)],cell_table,'UniformOutput',false);
        mat_table = cell2mat(cell_table);
        
        T_info = cell2table([cell_all_infos{sheet_i, :}]);
        T_data = array2table((mat_table) );
        writetable(T_info, compilationFilename, 'Sheet',sheets{sheet_i}, 'WriteVariableNames', 0);
        writetable(T_data, compilationFilename, 'Sheet',sheets{sheet_i}, 'Range', 'A5', 'WriteVariableNames', 0);
        
        waitbar(sheet_i/numel(sheets) , w)        
    end
    
    try
        close(w)
    catch
    end
    
    msgbox('Done!')
    
else
    msgbox('Only 1 file selected');
end

function filename_edit_Callback(hObject, eventdata, handles)
% hObject    handle to filename_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of filename_edit as text
%        str2double(get(hObject,'String')) returns contents of filename_edit as a double
filename = get(hObject, 'string');

if ~isempty(filename)
    setappdata(0, 'gui_compile_filename', filename)
    set(handles.compile_button, 'enable', 'on')
else
    set(handles.compile_button, 'enable', 'off')
end


% --- Executes during object creation, after setting all properties.
function filename_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filename_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in folder_button.
function folder_button_Callback(hObject, eventdata, handles)
% hObject    handle to folder_button (see GCBO)
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
set(handles.save_path_edit, 'string', new_path)
pause(0.01)
setappdata(0, 'savePath', new_path)


function save_path_edit_Callback(hObject, eventdata, handles)
% hObject    handle to save_path_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function save_path_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to save_path_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
