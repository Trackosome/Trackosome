function varargout = GUI_FLUCT_Results(varargin)
% GUI_FLUCT_RESULTS MATLAB code for GUI_FLUCT_Results.fig
%      GUI_FLUCT_RESULTS, by itself, creates a new GUI_FLUCT_RESULTS or raises the existing
%      singleton*.
%       
%      H = GUI_FLUCT_RESULTS returns the handle to a new GUI_FLUCT_RESULTS or the handle to
%      the existing singleton*.
%       
%      GUI_FLUCT_RESULTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_FLUCT_RESULTS.M with the given input arguments.
%       
%      GUI_FLUCT_RESULTS('Property','Value',...) creates a new GUI_FLUCT_RESULTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_FLUCT_Results_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_FLUCT_Results_OpeningFcn via varargin.
%       
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%       
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_FLUCT_Results

% Last Modified by GUIDE v2.5 08-May-2020 13:27:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_FLUCT_Results_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_FLUCT_Results_OutputFcn, ...
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


% --- Executes just before GUI_FLUCT_Results is made visible.
function GUI_FLUCT_Results_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_FLUCT_Results (see VARARGIN)

set(hObject, 'Name', 'Fluctuations Results');

set(hObject,'CloseRequestFcn', @results_closereq)

metadata = getappdata(0, 'gui_fluct_metadata');
memb_coords = getappdata(0, 'gui_fluct_memb_coords');
settings = getappdata(0, 'gui_main_fluct_settings');
I = getappdata(0, 'gui_fluct_I');
results = getappdata(0, 'gui_fluct_results');
f = str2double(get(handles.frame_value_txt, 'string'));

%% Update state App state
state = getappdata(0, 'gui_main_fluct_states');
if round(state) == 1 % loaded in single mode 
    setappdata(0, 'gui_main_fluct_states', 2)
end

%% Calculate Results
if isempty(results)
    nPoints = settings.nPoints;
    filter_width = settings.ref_smoothness;
    space_time_filt = settings.space_time_filt;
        
    [results, I_med_proj, ~, warning_frames] = Calc_Ref_Memb_and_Fluct_Results(...
        I, memb_coords, nPoints, filter_width, space_time_filt(1), space_time_filt(2), metadata.px2um);

    check_warnings(warning_frames)
    
    setappdata(0, 'gui_fluct_results', results)
    setappdata(0, 'gui_fluct_Iproj', I_med_proj)
    setappdata(0, 'gui_fluct_warning_frames', warning_frames)
end


%% Plot Results:
plot_frame_fluctuations(results.fluctuations_px_filt(:,f), results.fluctuations_vectors_filt(:,:,f), I(:,:,f), ...
    results.memb_coords_filt(:,:,f), results.ref_memb_struct, handles.frame_fluct_axes);

plot_cell_map(results.ref_memb_struct.vectors_base, results.ref_memb_struct.normals, results.ref_memb_struct.dist_memb_points_um, handles.frame_fluct_axes, 1);

plot_filtered_fluctuations_results(results.fluctuations_px_filt*metadata.px2um, results.ref_memb_struct.dist_memb_points_um, results.ffts_um_struct.max_fft_filt,...
    results.ffts_um_struct.freqs, handles.all_fluct_axes, handles.fourier_axes)

%% 

smallstep = 1/(metadata.nFrames-1);                                              
largestep = smallstep*10;
set(handles.slider,'BackgroundColor',[.9 .9 .9], 'Value', 1, 'Min', 1, 'Max', metadata.nFrames,...
'SliderStep', [smallstep largestep] );
addlistener(handles.slider,'Value','PostSet',@slider_listener);

setappdata(0, 'gui_fluct_Results_current_frame', 1)
% Choose default command line output for GUI_FLUCT_Results
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_FLUCT_Results wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_FLUCT_Results_OutputFcn(hObject, eventdata, handles) 
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
% frame = round(get(hObject,'Value'));
% plot_frame_fluctuations(handles.frame_fluct_axes, frame)


function slider_listener(hObject, eventdata)

previous_frame = getappdata(0, 'gui_fluct_Results_current_frame');
results = getappdata(0, 'gui_fluct_results');
I = getappdata(0, 'gui_fluct_I');

fluctuations_px_filt = results.fluctuations_px_filt;
fluctuations_vectors_filt = results.fluctuations_vectors_filt;
memb_coords_all = results.memb_coords_filt;

handles = guidata(eventdata.AffectedObject);
f = round(get(eventdata.AffectedObject,'Value'));

if f  ~= previous_frame       
    plot_frame_fluctuations(fluctuations_px_filt(:,f), fluctuations_vectors_filt(:,:,f), I(:,:,f), ...
    memb_coords_all(:,:,f), results.ref_memb_struct, handles.frame_fluct_axes);
    plot_cell_map(results.ref_memb_struct.vectors_base, results.ref_memb_struct.normals, ...
        results.ref_memb_struct.dist_memb_points_um, handles.frame_fluct_axes, []);
    drawnow
    set(handles.frame_value_txt, 'string', f)
    setappdata(0, 'gui_fluct_Results_current_frame', f )
end


% --- Executes during object creation, after setting all properties.
function slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function frame_value_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frame_value_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject, 'string', 1)



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
metadata = getappdata(0, 'gui_fluct_metadata');
set(hObject, 'string', metadata.nFrames)


% --- Executes on button press in fourier_fig_button.
function fourier_fig_button_Callback(hObject, eventdata, handles)
% hObject    handle to fourier_fig_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fluctuations_filt = getappdata(0, 'gui_fluct_results_fluctuations_map_px_filt');
metadata = getappdata(0, 'gui_fluct_metadata');
figure('name', getappdata(0, 'gui_fluct_finalFilename'))
fourier_analysis_for_Gui(fluctuations_filt, metadata.px2um, gca);


function time_sigma_edit_Callback(hObject, eventdata, handles)
% hObject    handle to time_sigma_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time_sigma_edit as text
%        str2double(get(hObject,'String')) returns contents of time_sigma_edit as a double
set(handles.apply_filter_button, 'enable', 'on')


% --- Executes during object creation, after setting all properties.
function time_sigma_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time_sigma_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function space_sigma_edit_Callback(hObject, eventdata, handles)
% hObject    handle to space_sigma_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of space_sigma_edit as text
%        str2double(get(hObject,'String')) returns contents of space_sigma_edit as a double
set(handles.apply_filter_button, 'enable', 'on')


% --- Executes during object creation, after setting all properties.
function space_sigma_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to space_sigma_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in fluct_map_fig.
function fluct_map_fig_Callback(hObject, eventdata, handles)
% hObject    handle to fluct_map_fig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

results = getappdata(0, 'gui_fluct_results');
metadata = getappdata(0, 'gui_fluct_metadata');

flucts_um = results.fluctuations_px_filt * metadata.px2um;

figure
plot_all_fluctuations(flucts_um, results.dist_ref_memb_points_um, gca);
colormap('jet')





% --- Executes during object creation, after setting all properties.
function fourier_axes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fourier_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate fourier_axes



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to first_frame_remove_region (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of first_frame_remove_region as text
%        str2double(get(hObject,'String')) returns contents of first_frame_remove_region as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to first_frame_remove_region (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to last_frame_remove_region (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of last_frame_remove_region as text
%        str2double(get(hObject,'String')) returns contents of last_frame_remove_region as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to last_frame_remove_region (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ref_memb_smooth_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ref_memb_smooth_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ref_memb_smooth_edit as text
%        str2double(get(hObject,'String')) returns contents of ref_memb_smooth_edit as a double

metadata = getappdata(0, 'gui_fluct_metadata');
settings = getappdata(0, 'gui_main_fluct_settings');
nPoints = settings.nPoints;
memb_filter_width = round(str2double(get(hObject,'string')));

I = getappdata(0, 'gui_fluct_Iproj');
if isempty(I)
    I = getappdata(0, 'gui_fluct_I');
end

temp_ref_memb_vars = calc_store_temporary_Ref_Memb(I, nPoints, memb_filter_width, metadata.px2um, handles);
handles.temp_ref_memb_vars = temp_ref_memb_vars;
guidata(gcf, handles);

set(handles.update_fluct_button, 'enable', 'on')
colors = getappdata(0, 'gui_colors_fluct');
set(handles.update_fluct_button, 'BackgroundColor', colors.ready)



% --- Executes during object creation, after setting all properties.
function ref_memb_smooth_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ref_memb_smooth_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
settings = getappdata(0, 'gui_main_fluct_settings');
set(hObject,'string', settings.ref_smoothness);


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function med_filter_edit_Callback(hObject, eventdata, handles)
% hObject    handle to med_filter_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of med_filter_edit as text
%        str2double(get(hObject,'String')) returns contents of med_filter_edit as a double


% --- Executes during object creation, after setting all properties.
function med_filter_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to med_filter_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ref_memb_smooth_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in draw_mask_button.
function draw_mask_button_Callback(hObject, eventdata, handles)
% hObject    handle to draw_mask_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
I = getappdata(0, 'gui_fluct_I');
Iproj = squeeze(median(I,3));

metadata = getappdata(0, 'gui_fluct_metadata');
size_I = [metadata.SizeY metadata.SizeX];

radius = 10;

f1 = figure;
imagesc(Iproj)
colormap('jet')
axis equal
title('Draw the guide for membrane')

try
    mask = from_draw_to_membrane_mask(size_I, gca, radius);
    close(f1)
    
    Iproj_cut = Iproj .* mask;
    temp_ref_memb_vars = preview_reference_membrane(Iproj_cut, handles);
    
    answer = questdlg('Save new Reference Membrane?');
    
    if strcmp(answer, 'Yes')
        setappdata(0, 'gui_fluct_Iproj', Iproj_cut)
        handles.temp_ref_memb_vars = temp_ref_memb_vars;
        answer = questdlg('Update fluctuations with new Reference Membrane?');
        
        if strcmp(answer, 'Yes')
            update_fluct_button_Callback(handles.update_fluct_button, eventdata, handles)
        else
            % Activate Fluctuations button
            set(handles.update_fluct_button, 'enable', 'on')
            colors = getappdata(0, 'gui_colors_fluct');
            set(handles.update_fluct_button, 'BackgroundColor', colors.ready)
        end        
    end
    
    try
        close(f1)
    catch
    end
    
catch
end


% --- Executes on button press in preview_button.
function preview_button_Callback(hObject, eventdata, handles)
% hObject    handle to preview_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
I = getappdata(0, 'gui_fluct_Iproj');

if isempty(I)
    I = getappdata(0, 'gui_fluct_I');
end

preview_reference_membrane(I, handles);


function temp_ref_memb_vars = preview_reference_membrane(I, handles)

metadata = getappdata(0, 'gui_fluct_metadata');
settings = getappdata(0, 'gui_main_fluct_settings');
nPoints = settings.nPoints;
memb_filter_width = ceil(str2double(get(handles.ref_memb_smooth_edit, 'string')));

[temp_ref_memb_vars, Iproj] = calc_store_temporary_Ref_Memb(I, nPoints, memb_filter_width, metadata.px2um, handles);

figure
imagesc(Iproj), hold on
plot(temp_ref_memb_vars.vectors_base(:,1), temp_ref_memb_vars.vectors_base(:,2), 'k', 'linewidth', 1)
plot(temp_ref_memb_vars.vectors_base(:,1), temp_ref_memb_vars.vectors_base(:,2), 'k.', 'markersize', 5)

plot_cell_map(temp_ref_memb_vars.vectors_base, temp_ref_memb_vars.normals, temp_ref_memb_vars.dist_memb_points_um, gca, 1)
title('Reference Membrane over Median Projection of Video')
colormap('jet')
drawnow
axis equal


function [temp_ref_memb_vars, Iproj] = calc_store_temporary_Ref_Memb(I, nPoints, memb_filter_width, px2um, handles)

[~, vectors_base_px, normals, Iproj] = Ref_memb_Normal_vecs(I, nPoints, memb_filter_width);

dist_memb_points_um  = calc_dist_between_memb_points(vectors_base_px, px2um);

temp_ref_memb_vars.normals = normals;
temp_ref_memb_vars.vectors_base = vectors_base_px;
temp_ref_memb_vars.smooth_filter_width = memb_filter_width;
temp_ref_memb_vars.dist_memb_points_um = dist_memb_points_um;



% --- Executes on button press in update_fluct_button.
function update_fluct_button_Callback(hObject, eventdata, handles)
% hObject    handle to update_fluct_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
colors = getappdata(0, 'gui_colors_fluct');
set(hObject, 'enable', 'off')
set(hObject, 'BackgroundColor', colors.normal)

metadata = getappdata(0, 'gui_fluct_metadata');
memb_coords = getappdata(0, 'gui_fluct_memb_coords');
I = getappdata(0, 'gui_fluct_I');
f = str2double(get(handles.frame_value_txt, 'string'));
results = getappdata(0, 'gui_fluct_results');
settings = getappdata(0, 'gui_main_fluct_settings');

space_time_filt = settings.space_time_filt;
nPoints = settings.nPoints;

ref_memb_vars = handles.temp_ref_memb_vars;

% Fluctuations:
step = 1;
[fluctuations_px, fluctuations_vectors, ~, warning_frames] = from_Membs_to_Fluctuations(memb_coords, ref_memb_vars.normals, ...
    ref_memb_vars.vectors_base, nPoints, step);

check_warnings(warning_frames)


% Filter Fluctuations, Calculate Fourier Transform
[fluctuations_px_filt, fluctuations_vectors_filt, memb_coords_filt] = ...
    filter_fluctuations(fluctuations_px, ref_memb_vars.normals, ref_memb_vars.vectors_base, space_time_filt(1), space_time_filt(2));

[ffts_um_struct.full_ffts, ffts_um_struct.mean_fft_raw, ffts_um_struct.max_fft_raw, ffts_um_struct.freqs] = ...
    fluctuations_fourier(fluctuations_px * metadata.px2um, ref_memb_vars.dist_memb_points_um);

[ffts_um_struct.full_ffts_filt, ffts_um_struct.mean_fft_filt, ffts_um_struct.max_fft_filt, ffts_um_struct.freqs] = ...
    fluctuations_fourier(fluctuations_px_filt * metadata.px2um, ref_memb_vars.dist_memb_points_um);

results.memb_coords_filt = memb_coords_filt;
results.fluctuations_px = fluctuations_px;
results.fluctuations_px_filt = fluctuations_px_filt;
results.fluctuations_vectors = fluctuations_vectors;
results.fluctuations_vectors_filt = fluctuations_vectors_filt;
results.ffts_um_struct = ffts_um_struct;
results.ref_memb_struct = ref_memb_vars;
setappdata(0, 'gui_fluct_results', results)
settings.ref_smoothness = ref_memb_vars.smooth_filter_width;
setappdata(0, 'gui_main_fluct_settings', settings);
setappdata(0, 'gui_fluct_warning_frames', warning_frames)

%% Plot Results:
cla(handles.frame_fluct_axes)

plot_frame_fluctuations(results.fluctuations_px_filt(:,f), results.fluctuations_vectors_filt(:,:,f), I(:,:,f), ...
    results.memb_coords_filt(:,:,f), ref_memb_vars,  handles.frame_fluct_axes);

plot_cell_map(ref_memb_vars.vectors_base, ref_memb_vars.normals, ref_memb_vars.dist_memb_points_um, handles.frame_fluct_axes, []);
drawnow

plot_filtered_fluctuations_results(results.fluctuations_px_filt*metadata.px2um, ref_memb_vars.dist_memb_points_um, results.ffts_um_struct.max_fft_filt,...
    results.ffts_um_struct.freqs, handles.all_fluct_axes, handles.fourier_axes)




% --- Executes on button press in filter_fluct_button.
function filter_fluct_button_Callback(hObject, eventdata, handles)
% hObject    handle to filter_fluct_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GUI_FLUCT_Filter_Flucts


% --- Executes on button press in fourier_fig.
function fourier_fig_Callback(hObject, eventdata, handles)
% hObject    handle to fourier_fig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure
fourier_plot(handles, gca)



function fourier_plot(handles, plotAxes)

results = getappdata(0, 'gui_fluct_results');

plot_majorant = get(handles.majorant_radio, 'value');
if plot_majorant
    y = results.ffts_um_struct.max_fft_filt;  
    y_label = 'Majorant Magnitude [\mum]';
        
else
    y = results.ffts_um_struct.mean_fft_filt;
    y_label = 'Mean Magnitude [\mum]';
end


plot_spatial_freq = get(handles.spatial_freq_radio, 'value');
if plot_spatial_freq
    x = results.ffts_um_struct.freqs;    
    plot(plotAxes, x, y, 'linewidth', 1.5)
    xlabel(plotAxes, 'Spatial Frequency [1/\mum]')
else
    x = 1./results.ffts_um_struct.freqs;    
    loglog(plotAxes, x, y, 'linewidth', 1.5)
    xlabel(plotAxes, 'Wavelength [\mum]')
end

ylabel(plotAxes, y_label);




function check_warnings(warning_frames)
if sum(warning_frames > 0)
    msgbox(['Warning: Check membrane fluctuations in frames: ' num2str(warning_frames') '. You may need a smoother reference membrane.'])
end


% --- Executes on button press in back_button.
function back_button_Callback(hObject, eventdata, handles)
% hObject    handle to back_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GUI_FLUCT_Load_Data
% close(GUI_FLUCT_Results)


% --- Executes on button press in fluct_vectors_fig_button.
function fluct_vectors_fig_button_Callback(hObject, eventdata, handles)
% hObject    handle to fluct_vectors_fig_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure
fig_axes = gca;
f = getappdata(0, 'gui_fluct_Results_current_frame');
results = getappdata(0, 'gui_fluct_results');
I = getappdata(0, 'gui_fluct_I');

fluctuations_px_filt = results.fluctuations_px_filt;
fluctuations_vectors_filt = results.fluctuations_vectors_filt;
memb_coords_all = results.memb_coords_filt;

plot_frame_fluctuations(fluctuations_px_filt(:,f), fluctuations_vectors_filt(:,:,f), I(:,:,f), ...
    memb_coords_all(:,:,f), results.ref_memb_struct, fig_axes);
plot_cell_map(results.ref_memb_struct.vectors_base, results.ref_memb_struct.normals, results.ref_memb_struct.dist_memb_points_um, fig_axes, 1);


% --- Executes on button press in save_button.
function save_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%% Load Data to Save:

I = getappdata(0, 'gui_fluct_I');
metadata = getappdata(0, 'gui_fluct_metadata');
settings = getappdata(0, 'gui_main_fluct_settings');
results = getappdata(0, 'gui_fluct_results');
filename = getappdata(0, 'gui_fluct_finalFilename');

[~,filename,~] = fileparts(filename);

savePath = getappdata(0, 'fluct_gui_savePath');

if isempty(savePath)
    savePath = get(handles.save_path_box, 'string');
end

saveFilename = get(handles.filename_box, 'string');

save([savePath saveFilename], 'I', 'metadata', 'settings', 'results', 'filename' )

msgbox('Done!')


% --- Executes on button press in chose_path_button.
function chose_path_button_Callback(hObject, eventdata, handles)
% hObject    handle to chose_path_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
path = getappdata(0, 'fluct_gui_savePath');

if ~isempty(path)
    new_path = uigetdir(path);
else
    searchPath = getappdata(0, 'fluct_searchPath');
    new_path = uigetdir(searchPath);
end

if ~new_path
    new_path = pwd;
end

new_path = [new_path '\'];
set(handles.save_path_box, 'string', new_path)
pause(0.01)
setappdata(0, 'fluct_gui_savePath', new_path)



function save_path_box_Callback(hObject, eventdata, handles)
% hObject    handle to save_path_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of save_path_box as text
%        str2double(get(hObject,'String')) returns contents of save_path_box as a double


% --- Executes during object creation, after setting all properties.
function save_path_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to save_path_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
path = getappdata(0, 'fluct_searchPath');
set(hObject, 'string', path)


function filename_box_Callback(hObject, eventdata, handles)
% hObject    handle to filename_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filename_box as text
%        str2double(get(hObject,'String')) returns contents of filename_box as a double


% --- Executes during object creation, after setting all properties.
function filename_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filename_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
filename = getappdata(0, 'gui_fluct_finalFilename');
[~, fname, ~] = fileparts(filename);
set(hObject, 'string', fname)

% --- Executes on button press in menu_button.
function menu_button_Callback(hObject, eventdata, handles)
% hObject    handle to menu_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GUI_FLUCT_Main_menu
close(GUI_FLUCT_Results)

% --- Executes on button press in spatial_freq_radio.
function spatial_freq_radio_Callback(hObject, eventdata, handles)
% hObject    handle to spatial_freq_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of spatial_freq_radio
if get(handles.spatial_freq_radio, 'value') == 1
    set(handles.wavelenght_radio, 'value', 0)
end
fourier_plot(handles,  handles.fourier_axes)



% --- Executes on button press in wavelenght_radio.
function wavelenght_radio_Callback(hObject, eventdata, handles)
% hObject    handle to wavelenght_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of wavelenght_radio
if get(handles.wavelenght_radio, 'value') == 1
    set(handles.spatial_freq_radio, 'value', 0)
end
fourier_plot(handles,  handles.fourier_axes)


function results_closereq(src,callbackdata)

state = getappdata(0, 'gui_main_fluct_states');
      
if state > 2 % in batch Mode

    selection = questdlg('Update changes made to this file?',...
               'Yes','No');          
        switch selection
            case 'Yes'
                colors = getappdata(0, 'gui_colors_fluct');      
                try
                    update_batch = getappdata(0, 'gui_fluct_Update_batch_button');
                    set(update_batch, 'backgroundcolor', colors.warning, 'enable', 'on');
                    msgbox('Update changes in Batch Mode Figure!')
                catch
                end
                                
                delete(GUI_FLUCT_Results)
            case 'No'
                delete(GUI_FLUCT_Results)
                return
        end  

else
    delete(GUI_FLUCT_Results)   
end


% --- Executes on button press in mean_radio.
function mean_radio_Callback(hObject, eventdata, handles)
% hObject    handle to mean_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of mean_radio
if get(handles.mean_radio, 'value') == 1
    set(handles.majorant_radio, 'value', 0)
end

fourier_plot(handles,  handles.fourier_axes)


% --- Executes on button press in majorant_radio.
function majorant_radio_Callback(hObject, eventdata, handles)
% hObject    handle to majorant_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of majorant_radio
if get(handles.majorant_radio, 'value') == 1
    set(handles.mean_radio, 'value', 0)
end

fourier_plot(handles,  handles.fourier_axes)
