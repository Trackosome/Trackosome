function varargout = GUI_Fluct_Show_Results(varargin)
% GUI_FLUCT_SHOW_RESULTS MATLAB code for GUI_Fluct_Show_Results.fig
%      GUI_FLUCT_SHOW_RESULTS, by itself, creates a new GUI_FLUCT_SHOW_RESULTS or raises the existing
%      singleton*.
%
%      H = GUI_FLUCT_SHOW_RESULTS returns the handle to a new GUI_FLUCT_SHOW_RESULTS or the handle to
%      the existing singleton*.
%
%      GUI_FLUCT_SHOW_RESULTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_FLUCT_SHOW_RESULTS.M with the given input arguments.
%
%      GUI_FLUCT_SHOW_RESULTS('Property','Value',...) creates a new GUI_FLUCT_SHOW_RESULTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_Fluct_Show_Results_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_Fluct_Show_Results_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_Fluct_Show_Results

% Last Modified by GUIDE v2.5 07-Apr-2020 10:45:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_Fluct_Show_Results_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_Fluct_Show_Results_OutputFcn, ...
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


% --- Executes just before GUI_Fluct_Show_Results is made visible.
function GUI_Fluct_Show_Results_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_Fluct_Show_Results (see VARARGIN)

set(hObject, 'Name', 'Results');

% Choose default command line output for GUI_Fluct_Show_Results
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

show_results = getappdata(0, 'gui_fluct_Temp_Show_results');
results = show_results.results;
ref_memb_struct = results.ref_memb_struct;
metadata = show_results.metadata;
Iproj = show_results.Iproj;

imagesc(handles.ref_memb_axes, Iproj)
axis(handles.ref_memb_axes, 'equal');
plot_cell_map(ref_memb_struct.vectors_base, ref_memb_struct.normals, ref_memb_struct.dist_memb_points_um, handles.ref_memb_axes, []);

plot_filtered_fluctuations_results(results.fluctuations_px_filt*metadata.px2um, ref_memb_struct.dist_memb_points_um, results.ffts_um_struct.max_fft_filt,...
    results.ffts_um_struct.freqs, handles.fluct_map_axes, handles.fourier_axes)
ylabel(handles.fourier_axes, 'Magnitude [\mum]')
set(handles.fourier_axes, 'Fontsize', 8)


% UIWAIT makes GUI_Fluct_Show_Results wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_Fluct_Show_Results_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
