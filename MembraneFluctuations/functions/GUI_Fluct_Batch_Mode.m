function GUI_Fluct_Batch_Mode(filenames)

nFiles = numel(filenames);

%% Colors:
gui_colors = getappdata(0, 'gui_colors_fluct');
blue = gui_colors.ready;
red = gui_colors.stop;
grey = gui_colors.normal;
yellow = gui_colors.warning;

% Row nr (nFiles + 1) is the default settings
full_settings.nFrames = zeros(nFiles);
full_settings.frame_step = -1 * ones(nFiles + 1, 1);
full_settings.px2um = -1 * ones(nFiles + 1, 1);
full_settings.nPoints = 500 * ones(nFiles + 1, 1);
full_settings.img_filt_size = 3 * ones(nFiles + 1, 1);
full_settings.seg_smoothness = 10 * ones(nFiles + 1, 1);
full_settings.ref_smoothness = 10 * ones(nFiles + 1, 1);
full_settings.space_time_filt = [1 1] .* ones(nFiles + 1, 2);


% Initialize Variables:
exported = 0;
full_results = cell(nFiles, 1);
full_metadata = cell(nFiles, 1);
full_memb_coords = cell(nFiles, 1);
full_Iproj = cell(nFiles, 1);
full_warning_frames = cell(nFiles, 1);
full_I = cell(nFiles, 1);

global_freqs = [0:0.001:5]';
all_interp_median_fft = zeros(length(global_freqs), nFiles);
all_interp_max_fft = zeros(length(global_freqs), nFiles);

file_states = zeros(nFiles,1); % 0 - empty file; 0.5 - finished membrane segmentation; 1 - ready; 2 - warning; 3 - error

stop_signal = 0;
running_file_i = [];


%% Initialize Figure
f = figure('Name', 'Batch Mode', 'CloseRequestFcn',@my_closereq);
p = get(f, 'Position');
xi = p(1)-150;
yi = p(2);

max_name = 0;
for i = 1:nFiles
    [searchPath, fname, ~] = fileparts(filenames{i});
    max_name = max(max_name, length(fname));
end
setappdata(0, 'fluct_searchPath', searchPath);

h_text_width = min(max_name * 7, 800);
fig_width = h_text_width + 800;
space_between_rows = 5;
items_hight = 25;
items_space = 15;
up_space = 50;
bottom_space = 30;
left_space = 20;
fig_hight = (space_between_rows+items_hight ) * nFiles + up_space + bottom_space;
set(f, 'Position', [xi, yi, fig_width, fig_hight], 'color', [1 1 1])

y_initial_row = (space_between_rows+items_hight ) * nFiles + bottom_space;
items = cell(nFiles, 1);


% Start button
head_button_width = 90;
head_y_pos = y_initial_row + 2*space_between_rows;
start_button = uicontrol('Style', 'pushbutton', 'Units','pixels', ...
    'Position', [left_space head_y_pos  head_button_width items_hight],...
    'String', 'Start',  'horizontalalignment', 'center',...
    'enable', 'on', 'tag','start_button', 'Callback', @Start_Analysis  );

% Stop button
stop_button_beg = left_space + head_button_width + items_space;
stop_button = uicontrol('Style', 'pushbutton', 'Units','pixels', ...
    'Position', [stop_button_beg head_y_pos  head_button_width items_hight],...
    'String', 'Stop',  'horizontalalignment', 'center',...
    'enable', 'off', 'tag','stop_button', 'Callback', @Stop_Analysis_Callback  );

% Default Settings button
default_settings_beg = stop_button_beg + head_button_width + items_space;
default_settings_button = uicontrol('Style', 'pushbutton', 'Units','pixels', ...
    'Position', [default_settings_beg head_y_pos  head_button_width items_hight],...
    'String', 'Default Settings',  'horizontalalignment', 'center',...
    'enable', 'on', 'tag','default_settings_button', 'Callback', @Settings_Callback  );

% Export Button:
export_button_beg = h_text_width + 735;
export_button = uicontrol('Style', 'pushbutton', 'Units','pixels', ...
    'Position', [export_button_beg head_y_pos  50 items_hight],...
    'String', 'Export',  'horizontalalignment', 'center',...
    'enable', 'off', 'tag','default_settings_button', 'Callback', @Export_Callback  );


for row = 1:nFiles
    y_pos = y_initial_row - row *(space_between_rows + items_hight);
    items{row} = initialize_row(y_pos);
end


%% Initialize row of graphical elements:
    function items = initialize_row(y_pos)
        
        h_beg = left_space;
        
        [~,name,~] = fileparts(filenames{row});
        
        items.filename = uicontrol('Style', 'text', ...
            'Units','pixels',  'String',name, ...
            'Position', [h_beg y_pos-5 h_text_width items_hight],...
            'backgroundcolor', [1 1 1],  'horizontalalignment', 'left' );
        
        % Settings
        meta_button_width = 65;
        meta_button_beg = h_beg + h_text_width;
        tag = ['settings_button' num2str(row) ];
        items.settings_button = uicontrol('Style', 'pushbutton', ...
            'Units','pixels', ...
            'Position', [meta_button_beg y_pos  meta_button_width items_hight],...
            'String', 'Settings',  'horizontalalignment', 'center',...
            'enable', 'on', 'tag',tag, 'Callback', @Settings_Callback  );
        
        
        % State LEDs:
        led_width = 65;
        led_beg = meta_button_beg + meta_button_width + items_space;
        tag = ['state_button' num2str(row) ];
        items.led = uicontrol('Style', 'pushbutton', ...
            'Units','pixels', 'enable', 'off', ...
            'Position', [led_beg y_pos led_width items_hight],...
            'backgroundcolor', [0.3 0.3 0.3], 'horizontalalignment', 'center', ...
            'tag',tag,'Callback', @State_Led_Callback );
        
        % Show Results Button
        show_button_width = 75;
        show_button_beg = led_beg + led_width + items_space;
        tag = ['show_results_button' num2str(row) ];
        items.show_results_button = uicontrol('Style', 'pushbutton', ...
            'Units','pixels', ...
            'Position', [show_button_beg y_pos  show_button_width items_hight],...
            'String', 'Show Results',  'horizontalalignment', 'center',...
            'enable', 'off','tag',tag, 'Callback', @Show_Results_Callback  );
        
        
        % Segment Memb, Memb Fluct buttons for GUIs:
        gui_buttons_width = 175;
        segment_button_beg = show_button_beg + show_button_width + items_space;
        flucts_button_beg = segment_button_beg + gui_buttons_width + items_space;
        
        tag = ['segm_button_' num2str(row) ];
        items.segment_button = uicontrol('Style', 'pushbutton', ...
            'Units','pixels', ...
            'Position', [segment_button_beg y_pos gui_buttons_width items_hight],...
            'String', 'Edit Memb Segmentation',  'horizontalalignment', 'center', ...
            'enable', 'off', 'tag',tag, 'Callback', @Segment_Membranes_Callback );
        
        tag = ['results_button_' num2str(row) ];
        items.results_button = uicontrol('Style', 'pushbutton', ...
            'Units','pixels', ...
            'Position', [flucts_button_beg y_pos gui_buttons_width items_hight],...
            'String', 'Edit Memb Fluctuations',  'horizontalalignment', 'center',...
            'enable', 'off', 'tag',tag, 'Callback', @Results_Callback  );
        
        % Update button
        update_button_width = 75;
        update_button_beg = flucts_button_beg + gui_buttons_width + items_space;
        tag = ['update_button_' num2str(row) ];
        items.update_button = uicontrol('Style', 'pushbutton', ...
            'Units','pixels', ...
            'Position', [update_button_beg y_pos update_button_width items_hight],...
            'String', 'Update Data',  'horizontalalignment', 'center',...
            'enable', 'off', 'tag',tag, 'Callback', @Update_Callback  );
        
        % Export Checkbox
        export_check_width = 15;
        export_check_beg = update_button_beg + update_button_width + 28;
        tag = ['export_check_' num2str(row) ];
        items.export_check = uicontrol('Style', 'checkbox', ...
            'Units','pixels', ...
            'Position', [export_check_beg y_pos export_check_width items_hight],...
            'String', '',  'horizontalalignment', 'center',...
            'enable', 'off', 'tag',tag, 'enable', 'off', 'value', 0, 'backgroundcolor', [1 1 1]);
    end


%%  Cycle to Load and Analyse Files:
    function Start_Analysis( hObject, eventdata, handles )
        
        set(hObject, 'enable', 'off')
        set(stop_button, 'enable', 'on')
        set(export_button, 'enable', 'off');
        
        disable_Edit_buttons
        
        files_nr = 1:nFiles;
        empty_files = ~floor(file_states);
        files_to_open = nonzeros(files_nr .* empty_files');
        
        for n = 1:length(files_to_open)
            
            if stop_signal
                stop_signal = 0;
                enable_Edit_buttons
                break
            end
            
            running_file_i = files_to_open(n);
            file_items = items{running_file_i};
            set(file_items.led, 'string', 'Loading...', 'backgroundcolor', [1 1 1]);
            pause(0.001)
            % Load Data
            [I, metadata] = Load_Files(filenames{running_file_i});
            
            if ~isempty(I)
                
                check_metadata(metadata);
                full_settings.nFrames(running_file_i) = size(I, 3);
                
                % Segment Membranes:
                nPoints = full_settings.nPoints(running_file_i);
                memb_smooth_filter = full_settings.seg_smoothness(running_file_i);
                med_filter_side = full_settings.img_filt_size(running_file_i);
                step = 2;
                masks = cell(full_metadata{running_file_i}.nFrames, 1);
                [full_memb_coords{running_file_i}, I, ~, segment_error_signal, stopped] = ...
                    Segment_Membs(I, nPoints, med_filter_side, memb_smooth_filter, step, masks);
                
                if stopped
                    break
                else
                    
                    file_states(running_file_i) = 0.5; % membranes segmented
                    
                    % Calculate Flucutations:
                    space_filt = full_settings.space_time_filt(running_file_i, 1);
                    time_filt =  full_settings.space_time_filt(running_file_i, 2);
                    ref_filter_width = full_settings.ref_smoothness(running_file_i);
                    px2um = full_metadata{running_file_i}.px2um;
                    [full_results{running_file_i}, full_Iproj{running_file_i} , fluct_error_signal, full_warning_frames{running_file_i}] = ...
                        Calc_Ref_Memb_and_Fluct_Results(I, full_memb_coords{running_file_i}, nPoints, ref_filter_width, space_filt, time_filt, px2um);
                    
                    set(file_items.show_results_button, 'enable', 'on', 'backgroundcolor', grey);
                    
                    % Files states: 0 - empty file; 1 membranes segmented; 2- ready; 3 - warning; 4 - error
                    if segment_error_signal || fluct_error_signal
                        set(file_items.led, 'string', 'Error', 'backgroundcolor', red, 'enable', 'on');
                        if segment_error_signal
                            set(file_items.segment_button, 'backgroundcolor', red);
                        else
                            set(file_items.results_button, 'backgroundcolor', red);
                        end
                        file_states(running_file_i) = 3; % error
                        
                    elseif sum(full_warning_frames{running_file_i}) > 0
                        set(file_items.led, 'string', 'Warning', 'backgroundcolor', yellow, 'enable', 'on');
                        file_states(running_file_i) = 2; % warning
                    else
                        set(file_items.led, 'string', 'Ready!', 'backgroundcolor', blue, 'enable', 'on');
                        file_states(running_file_i) = 1; % ready
                    end
                    
                    set(items{n}.export_check, 'value', 1);
                    
                end
            else
                set(file_items.led, 'string', 'Empty', 'backgroundcolor', grey, 'enable', 'off');
                file_states(running_file_i) = 0; % empty
            end
        end
        
        enable_Edit_buttons
        
        if sum(files_to_open) == 0
            set(hObject, 'enable', 'off')
        else
            set(hObject, 'enable', 'on')
        end
    end

    function State_Led_Callback( hObject, eventdata, handles )
        tag = get(hObject, 'tag');
        file = str2double(tag(end));
        
        if sum(full_warning_frames{file} > 0)
            msgbox(['Warning: Check membrane fluctuations in frames: ' num2str(full_warning_frames{file}') '. You may need a smoother reference membrane.'])
        end
    end


    function check_metadata(metadata)
        
        settings_warning = 0;
        
        if full_settings.px2um(running_file_i) == -1 % default from file metadata
            
            if isnan(metadata.px2um) % metadata is empty
                px2um = 0.1;
                metadata.px2um = px2um;
                settings_warning = 1;
            end
            
        else % from settings
            metadata.px2um = full_settings.px2um(running_file_i);
        end
        
        if full_settings.frame_step(running_file_i) == -1 % default from file metadata
            if isnan(metadata.frame_step) % default from metadata of file. but metadata is empty
                frame_step = 1; % sec
                metadata.frame_step = frame_step;
                settings_warning = settings_warning + 2;
            end
        else % from settings
            metadata.frame_step = full_settings.frame_step(running_file_i);
        end
        
        if settings_warning > 0
            set(items{running_file_i}.settings_button, 'backgroundcolor', yellow);
            if settings_warning == 1
                msg = msgbox(['Warning!' newline 'File ' num2str(running_file_i) ...
                    ' with emtpy pixel to micrometer conversion.' newline ' - px2um = 0.1 [um/px]']);
            elseif settings_warning == 2
                msg = msgbox(['Warning!' newline 'File ' num2str(running_file_i) ...
                    ' with emtpy Frame Step.' newline ' - frame step = 1 [s]']);
            else
                msg =  msgbox(['Warning!' newline 'File ' num2str(running_file_i) ...
                    ' with emtpy metadata. ' newline ' - frame step = 1 [s]' newline ' - px2um = 0.1 [um/px]; ' ]);
            end
        end
        
        full_metadata{running_file_i} = metadata;
        full_settings.frame_step(running_file_i) = metadata.frame_step;
        full_settings.px2um(running_file_i) = metadata.px2um;
    end

    function Stop_Analysis_Callback( hObject, eventdata, handles )
        
        if file_states(running_file_i) == 0
            answer = questdlg('If you stop now you will need to restart Membrane Segmentation for the current file.',...
                'Stop cycle', 'Stop now', 'Stop after file is analysed', 'Cancel', 'Cancel');
            
            if strcmp(answer, 'Stop now')
                setappdata(0, 'stop_cycle', 1)
                enable_Edit_buttons
                set(items{running_file_i}.led, 'backgroundcolor', [0.3 0.3 0.3], 'String', '')
                
            elseif strcmp(answer, 'Stop after file is analysed')
                stop_signal = 1;
                set(stop_button, 'String', 'Stopping soon', 'backgroundcolor', yellow);
            else
                set(stop_button, 'String', 'Stop', 'backgroundcolor', grey);
                stop_signal = 0;
            end
            
        elseif file_states(running_file_i) == 0.5
            msgbox('Program will stop once the membrane flucutations are calculated for current file.')
            stop_signal = 1;
            set(stop_button, 'String', 'Stopping soon', 'backgroundcolor', yellow);
        else
            msgbox('Problem with state of running_file')
        end              
    end


    function enable_Edit_buttons        
        set(start_button, 'enable', 'on')
        set(stop_button, 'enable', 'off','String', 'stop', 'backgroundcolor', grey);
        set(export_button, 'enable', 'on');
        
        for n = 1:nFiles
            if file_states(n) ~= 0
                set(items{n}.segment_button, 'enable', 'on');
                set(items{n}.results_button, 'enable', 'on');
                set(items{n}.export_check, 'enable', 'on');
            end
        end
    end


    function disable_Edit_buttons        
        for n = 1:nFiles
            set(items{n}.segment_button, 'enable', 'off');
            set(items{n}.results_button, 'enable', 'off');
            set(items{n}.export_check, 'enable', 'off');
        end
    end


    function  Segment_Membranes_Callback( hObject, eventdata, handles )
        
        tag = get(hObject, 'tag');
        row_nr = str2double(tag(end));
        
        update_button = items{row_nr}.update_button;
        
        setappdata(0, 'gui_fluct_Update_batch_button', update_button)
        
        % Load Image
        [I_, ~] = Load_Files(filenames{row_nr});
        
        % Load GUI
        set_app_data_for_GUI(I_, row_nr)
        GUI_FLUCT_Load_Data
    end


    function  Results_Callback( hObject, eventdata, handles )
        
        tag = get(hObject, 'tag');
        row_nr = str2double(tag(end));
        
        update_button = items{row_nr}.update_button;
        
        setappdata(0, 'gui_fluct_Update_batch_button', update_button)
        
        % Load Image
        [I_, ~] = Load_Files(filenames{row_nr});
        
        % Load GUI
        set_app_data_for_GUI(I_, row_nr)
        GUI_FLUCT_Results
    end

    function set_app_data_for_GUI(I, file_nr)
        setappdata(0, 'gui_fluct_I', I);
        setappdata(0, 'gui_fluct_masks', cell(full_metadata{file_nr}.nFrames, 1));
        setappdata(0, 'gui_fluct_metadata', full_metadata{file_nr});
        setappdata(0, 'gui_fluct_memb_coords', full_memb_coords{file_nr});
        setappdata(0, 'gui_fluct_results', full_results{file_nr});
        setappdata(0, 'gui_fluct_finalFilename', filenames{file_nr});
        setappdata(0, 'gui_fluct_Iproj', full_Iproj{file_nr});
        
        settings.nPoints = full_settings.nPoints(file_nr);
        settings.img_filt_size = full_settings.img_filt_size(file_nr);
        settings.seg_smoothness = full_settings.seg_smoothness(file_nr);
        settings.ref_smoothness = full_settings.ref_smoothness(file_nr);
        settings.space_time_filt = full_settings.space_time_filt(file_nr, :);
        setappdata(0, 'gui_main_fluct_settings', settings);
    end

    function Settings_Callback(hObject, eventdata, handles )
        
        tag = get(hObject, 'tag');
        
        if strcmp(tag, 'default_settings_button')
            ind = nFiles + 1; % Default settings
            name     = 'Default';
        else
            ind = str2double(tag(end));
            name = ['File ' num2str(ind)];
        end
        
        frame_step = full_settings.frame_step(ind);
        px2um = full_settings.px2um(ind);
        
        if frame_step == -1
            frame_step = 'From file metadata';
        else
            frame_step = num2str(frame_step);
        end
        
        if px2um  == -1
            px2um  = 'From file metadata';
        else
            frame_step = num2str(frame_step);
        end
        
        nPoints = full_settings.nPoints(ind);
        img_filt_size = full_settings.img_filt_size(ind);
        seg_smoothness = full_settings.seg_smoothness(ind);
        ref_smoothness = full_settings.ref_smoothness(ind);
        space_time_filt = full_settings.space_time_filt(ind, :);
        
        % Get user input for settings:
        prompt   = {'frame step [s]', 'px2um [\mum/px]',  'Membranes Smoothness', 'Nº Points in Membranes', 'Kernel side for Images filtering [px]',...
            'Smoothness of Reference Membrane' , 'Fluctuations Filter in Space (Nº Points)', 'Fluctuations Filter in Time (Nº Frames)'};
        numlines = [1, 35];
        
        defaultanswer   = { num2str(frame_step), num2str(px2um), num2str(seg_smoothness), ...
            num2str(nPoints), num2str(img_filt_size), num2str(ref_smoothness), num2str(space_time_filt(1)), num2str(space_time_filt(2))};
        options.Interpreter = 'tex';
        answer = inputdlg( prompt, name, numlines, defaultanswer, options );
        
        if ~isempty(answer)
            
            try
                frame_step = str2double( answer{1} );
                if isnan(frame_step)
                    frame_step = -1;
                end
                px2um = str2double( answer{2} );
                if isnan(px2um)
                    px2um = -1;
                end
                
                seg_smoothness = str2double( answer{3} );
                nPoints = str2double( answer{4} );
                img_filt_size = str2double( answer{5} );
                ref_smoothness = str2double( answer{6} );
                space_time_filt = [str2double(answer{7}) str2double(answer{8})];
                
            catch
            end
            
            if ind > nFiles % Default settings - change settings for all files:
                full_settings.frame_step = frame_step * ones(nFiles + 1, 1);
                full_settings.px2um = px2um * ones(nFiles + 1, 1);
                full_settings.nPoints = nPoints * ones(nFiles + 1, 1);
                full_settings.img_filt_size = img_filt_size * ones(nFiles + 1, 1);
                full_settings.ref_smoothness = ref_smoothness * ones(nFiles + 1, 1);
                full_settings.seg_smoothness = seg_smoothness * ones(nFiles + 1, 1);
                full_settings.space_time_filt = space_time_filt .* ones(nFiles + 1, 2);
                
            else % Individual settings - change settings of selected file:
                full_settings.frame_step(ind) = frame_step;
                full_settings.px2um(ind) = px2um;
                full_settings.nPoints(ind) = nPoints;
                full_settings.img_filt_size(ind) = img_filt_size;
                full_settings.ref_smoothness(ind) = ref_smoothness;
                full_settings.seg_smoothness(ind) = seg_smoothness;
                full_settings.space_time_filt(ind, :) = space_time_filt;
            end
        end
    end


    function Show_Results_Callback(hObject, eventdata, handles )
        
        tag = get(hObject, 'tag');
        ind = str2double(tag(end));
        show_results.Iproj = full_Iproj{ind};
        show_results.results = full_results{ind};
        show_results.metadata = full_metadata{ind};
        setappdata(0, 'gui_fluct_Temp_Show_results', show_results);
        GUI_Fluct_Show_Results;
    end


    function Update_Callback(hObject, eventdata, handles )
        
        metadata = getappdata(0, 'gui_fluct_metadata');
        settings_temp = getappdata(0, 'gui_main_fluct_settings');
        results = getappdata(0, 'gui_fluct_results');
        Iproj = getappdata(0, 'gui_fluct_Iproj');
        warning_frames = getappdata(0, 'gui_fluct_warning_frames');
        
        tag = get(hObject, 'tag');
        ind = str2double(tag(end));
        
        full_settings.frame_step(ind) = metadata.frame_step;
        full_settings.px2um(ind) = metadata.px2um;
        full_settings.nPoints(ind) = settings_temp.nPoints;
        full_settings.img_filt_size(ind) = settings_temp.img_filt_size;
        full_settings.ref_smoothness(ind) = settings_temp.ref_smoothness;
        full_settings.seg_smoothness(ind) = settings_temp.seg_smoothness;
        full_settings.space_time_filt(ind, :) = settings_temp.space_time_filt;
        full_warning_frames{ind} = warning_frames;
        full_results{ind} = results;
        full_Iproj{ind} = Iproj;
        
        if sum(warning_frames) == 0
            set( items{ind}.led, 'string', 'Ready!', 'backgroundcolor', blue, 'enable', 'on');
            file_states(ind) = 1; % ready
        else
            set(items{ind}.led, 'string', 'Warning', 'backgroundcolor', yellow, 'enable', 'on');
            file_states(ind) = 2; % warning
        end
                
        set(hObject, 'backgroundcolor', grey, 'enable', 'off')
        msgbox('Data was updated!')
    end


    function Export_Callback(hObject, eventdata, handles )
        
        path = getappdata(0, 'fluct_gui_savePath');
        if ~isempty(path)
            savePath = uigetdir(path, 'Select folder to save data');
        else
            savePath = uigetdir(searchPath, 'Select folder to save data');
        end
        
        if savePath == 0
            msgbox('Exporting canceled.');
            
        else
            m = msgbox('Exporting files...');
            
            noFiles = 1;
            
            for n = 1:nFiles
                
                to_Save = get(items{n}.export_check, 'value');
                
                if to_Save
                    % Save folder
                    [~,filename ,~] = fileparts(filenames{n});
                    
                    metadata.nFrames = full_settings.nFrames(n);
                    metadata.frame_step = full_settings.frame_step(n);
                    metadata.px2um = full_settings.px2um(n);
                    
                    settings.nPoints = full_settings.nPoints(n);
                    settings.img_filt_size = full_settings.img_filt_size(n);
                    settings.seg_smoothness = full_settings.seg_smoothness(n);
                    settings.ref_smoothness = full_settings.ref_smoothness(n);
                    settings.space_time_filt = full_settings.space_time_filt(n, :);
                    
                    results = full_results{n};
                    Iproj = full_Iproj{n};
                    
                    save([savePath '\' filename], 'Iproj', 'metadata', 'settings', 'results', 'filename' )
                    exported = 1;
                    noFiles = 0;
                end
                
            end
            
            try
                close(m)
            catch
            end
            
            if noFiles
                msgbox('No files selected!')
            else
                msgbox(['Exported! ' newline newline 'WARNING: for memory purposes, the image stacks are not stored in Batch Mode. You cannot load these files with "Load Saved Data"'])
            end
            
        end
        
        
    end

    function my_closereq(src,callbackdata)
        % Close request function
        % to display a question dialog box
        
        if exported == 1
            selection = questdlg('If you close you will lose the data that was not exported. Close now?',...
                'Yes','No');
            
        else
            selection = questdlg('Data was NOT exported yet! If you close you will lose ALL the data. Close now?',...
                'Yes','No');
        end
        
        switch selection
            case 'Yes'
                delete(gcf)
            case 'No'
                return
        end
        
        
    end

end