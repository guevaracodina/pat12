function varargout = GUI_TEMPORAL(varargin)
% GUI_TEMPORAL M-file for GUI_TEMPORAL.fig
%      GUI_TEMPORAL, by itself, creates a new GUI_TEMPORAL or raises the existing
%      singleton*.
%
%      H = GUI_TEMPORAL returns the handle to a new GUI_TEMPORAL or the handle to
%      the existing singleton*.
%
%      GUI_TEMPORAL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_TEMPORAL.M with the given input arguments.
%
%      GUI_TEMPORAL('Property','Value',...) creates a new GUI_TEMPORAL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_TEMPORAL_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_TEMPORAL_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_TEMPORAL

% Last Modified by GUIDE v2.5 16-Aug-2012 14:11:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_TEMPORAL_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_TEMPORAL_OutputFcn, ...
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


% --- Executes just before GUI_TEMPORAL is made visible.
function GUI_TEMPORAL_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_TEMPORAL (see VARARGIN)

% Choose default command line output for GUI_TEMPORAL
handles.output = hObject;

set(hObject,'toolbar','figure');

% Build a colormap that consists of 2 separate
% colormaps.
cmap1 = gray(128);
cmap2 = hot(128);
cmap = [cmap1;cmap2];
colormap(cmap)
handles.acq.cmap = cmap;

% set(hObject,'Position',get(0,'Screensize'));

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_TEMPORAL wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_TEMPORAL_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in load_iq.
function load_iq_Callback(hObject, eventdata, handles)
% hObject    handle to load_iq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% [open_FileName,open_PathName] = uigetfile('*.iq.bmode','Ouvrir un fichier de données');

if isfield(handles, 'acq')
    if isfield(handles.acq, 'open_PathName');
        [open_FileName,open_PathName] = uigetfile('*.iq.pamode','Ouvrir un fichier de données',handles.acq.open_PathName);
    elseif isfield(handles.acq, 'working_directory')
        [open_FileName,open_PathName] = uigetfile('*.iq.pamode','Ouvrir un fichier de données',handles.acq.working_directory);   
    else
        [open_FileName,open_PathName] = uigetfile('*.iq.pamode','Ouvrir un fichier de données');
    end
else
   [open_FileName,open_PathName] = uigetfile('*.iq.pamode','Ouvrir un fichier de données');
end


if (open_FileName)
    
    data_path = strcat([open_PathName open_FileName]);
    handles.acq.data_path = data_path;
    handles.acq.open_FileName = open_FileName;
    handles.acq.open_PathName = open_PathName;
    
    str_temp = strfind(data_path, '.pamode');
    
    if (str_temp)
        short_data_path = data_path(1:str_temp-1);
        shortest_data_path = data_path(1:str_temp-4);
        handles.acq.short_data_path = short_data_path;
        handles.acq.shortest_data_path = shortest_data_path;
        
        xml_data_path = [data_path(1:str_temp) 'xml'];

        param = VsiParseXmlModif(xml_data_path,'.pamode');
        handles.acq.param = param;
        
        % Type of data
        handles.acq.source_type = 'IQ';
        
        % Set offsets in interface
        handles.acq.YOffset = str2num(get(handles.edit_yoffset,'string'));
        handles.acq.VOffset = str2num(get(handles.edit_voffset,'string'));      
        set(handles.edit_yoffset,'enable', 'on');
        set(handles.edit_voffset,'enable', 'on');    
        
        % Calculate number of frames in file
        handles.acq.n_frames = VsiFindNFrames(short_data_path, '.bmode');
        
        % Get the Time Stamp Data for all frames
        handles.acq.TimeStampData = VsiBModeIQTimeFrame(short_data_path, '.bmode', handles.acq.n_frames);       
%         figure;plot( handles.acq.TimeStampData/1000);
             
        
        set(handles.display_status,'string', 'Loading IQ data...');
        handles.acq.frame_number = 1;
        set(handles.frame_number,'string',num2str(1));
        set(handles.frame_number,'enable','on');
        set(handles.total_frames,'string',num2str(handles.acq.n_frames));
        set(handles.previous_button,'enable','off');
        set(handles.next_button,'enable','on');
        set(handles.display_filename_iq, 'string', open_FileName);
        set(handles.display_filename_preprocessed, 'string', '');        
        set(handles.pushbutton_preprocess, 'enable','on');
        
        handles = lock_interface(handles);
        pause(0.5);

        % Display US (for frame 1)
        handles = VsiBModeReconstructRFModif(handles, short_data_path, 1);
        
        % Display PA (for frame 1)
        if (get(handles.checkbox_pa_display,'value'))
            VsiBeamformPaModif(handles, short_data_path, 1, 1);
        end
        
        handles = unlock_interface(handles);
        set(handles.display_status,'string', 'OK');
    end
end

guidata(hObject, handles);

function handles = lock_interface(handles)

handles.acq.enable_edit_yoffset = get(handles.edit_yoffset,'enable');
handles.acq.enable_edit_voffset = get(handles.edit_voffset,'enable'); 
handles.acq.enable_frame_number = get(handles.frame_number,'enable');
handles.acq.enable_previous_button = get(handles.previous_button,'enable'); 
handles.acq.enable_next_button = get(handles.next_button,'enable');       
handles.acq.enable_pushbutton_preprocess = get(handles.pushbutton_preprocess, 'enable');
handles.acq.enable_load_iq = get(handles.load_iq,'enable');
handles.acq.enable_load_preprocessed = get(handles.load_preprocessed,'enable');

set(handles.edit_yoffset,'enable', 'off');
set(handles.edit_voffset,'enable', 'off');  
set(handles.frame_number,'enable','off');
set(handles.previous_button,'enable','off'); 
set(handles.next_button,'enable','off');   
set(handles.pushbutton_preprocess, 'enable','off');
set(handles.load_iq,'enable','off');
set(handles.load_preprocessed,'enable','off');


function handles = unlock_interface(handles)

set(handles.edit_yoffset,'enable', handles.acq.enable_edit_yoffset);
set(handles.edit_voffset,'enable',  handles.acq.enable_edit_voffset);  
set(handles.frame_number,'enable', handles.acq.enable_frame_number);
set(handles.previous_button,'enable', handles.acq.enable_previous_button);   
set(handles.next_button,'enable', handles.acq.enable_next_button);       
set(handles.pushbutton_preprocess, 'enable', handles.acq.enable_pushbutton_preprocess);
set(handles.load_iq,'enable',handles.acq.enable_load_iq);
set(handles.load_preprocessed,'enable',handles.acq.enable_load_preprocessed);


function display_filename_iq_Callback(hObject, eventdata, handles)
% hObject    handle to display_filename_iq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of display_filename_iq as text
%        str2double(get(hObject,'String')) returns contents of display_filename_iq as a double


% --- Executes during object creation, after setting all properties.
function display_filename_iq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to display_filename_iq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in next_button.
function next_button_Callback(hObject, eventdata, handles)
% hObject    handle to next_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


frame_number = handles.acq.frame_number;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ROIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Stocke les positions des ROIs du frame actuel
for index = 1:4
    % Si le handle de la ROI existe
    if (~isempty(handles.acq.hrois_us{index}))
        temp_h = handles.acq.hrois_us{index};
        
        % Si la ROI existe
        if (isvalid(temp_h))
            
            % Copie la position
            pos = getPosition(temp_h);
 
            % Le stocke
            handles.acq.roi_positions{1,index} = pos;
        else
            handles.acq.roi_positions{1,index} = [];            
        end
        
        % Detruit le handle de toute facon
        handles.acq.hrois_us{index} = [];
        
    else
        handles.acq.roi_positions{1,index} = [];
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


frame_number = handles.acq.frame_number;
frame_number = frame_number + 1;

set(handles.frame_number, 'string', num2str(frame_number));
handles.acq.frame_number = frame_number;
  
if frame_number >= handles.acq.n_frames
   set(handles.next_button, 'enable','off'); 
   set(handles.next_copy_button, 'enable','off'); 
else
   set(handles.previous_button, 'enable','on');
end

handles = lock_interface(handles);
pause(0.5);


if (strcmp(handles.acq.source_type, 'IQ'))
    % Display US
    handles = VsiBModeReconstructRFModif(handles, handles.acq.short_data_path, frame_number);

    % Display PA
    if (get(handles.checkbox_pa_display,'value'))
        VsiBeamformPaModif(handles, handles.acq.short_data_path, frame_number, frame_number);
    end
else
    
    abs_data = handles.acq.Bmode_data(:,:,frame_number);
    BfData = handles.acq.PAmode_data(:,:,frame_number);
    
    % Display US
    DisplayUSdata(handles, abs_data, handles.acq.param);
    
    % Display PA
    handles = DisplayPAdata(handles, BfData, handles.acq.param);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ROIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Va chercher les positions des ROIs du frame
    for index = 1:4
        if (~isempty(handles.acq.roi_positions{1,index}))
            pos = handles.acq.roi_positions{1,index};
            
            % Cree un nouveau ROI
            h = impoly(handles.axes1, pos);
            h_bis = impoly(handles.axes2, pos);
            
            % Le stocke
            handles.acq.hrois_us{index} = h;
            handles.acq.hrois_pa{index} = h_bis;            
            
            switch (index)
                case 1
                    setColor(h,'yellow');
                    setColor(h_bis,'yellow');
                case 2
                    setColor(h,'red');
                    setColor(h_bis,'red');
                case 3
                    setColor(h,'blue');
                    setColor(h_bis,'blue');
                case 4
                    setColor(h,'green');
                    setColor(h_bis,'green');
            end
            
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


end
      
handles = unlock_interface(handles);
guidata(hObject, handles);



function frame_number_Callback(hObject, eventdata, handles)
% hObject    handle to frame_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frame_number as text
%        str2double(get(hObject,'String')) returns contents of frame_number as a double


frame_number = handles.acq.frame_number;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ROIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Stocke les positions des ROIs du frame actuel
for index = 1:4
    % Si le handle de la ROI existe
    if (~isempty(handles.acq.hrois_us{index}))
        temp_h = handles.acq.hrois_us{index};
        
        % Si la ROI existe
        if (isvalid(temp_h))
            
            % Copie la position
            pos = getPosition(temp_h);
 
            % Le stocke
            handles.acq.roi_positions{1,index} = pos;
        else
            handles.acq.roi_positions{1,index} = [];            
        end
        
        % Detruit le handle de toute facon
        handles.acq.hrois{index} = [];
        
    else
        handles.acq.roi_positions{1,index} = [];
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


frame_number = str2num(get(handles.frame_number, 'string'));
handles.acq.frame_number = frame_number;

if frame_number == handles.acq.n_frames
    set(handles.next_button,'enable','off');
    set(handles.next_copy_button,'enable','off');
    set(handles.previous_button,'enable','on');
end

if frame_number == 1
    set(handles.previous_button,'enable','off');
    set(handles.next_button,'enable','on');
end

handles = lock_interface(handles);
pause(0.5);

if (strcmp(handles.acq.source_type, 'IQ'))
    % Display US
    handles = VsiBModeReconstructRFModif(handles, handles.acq.short_data_path, frame_number);

    % Display PA
    if (get(handles.checkbox_pa_display,'value'))
        VsiBeamformPaModif(handles, handles.acq.short_data_path, frame_number, frame_number);
    end
else
    abs_data = handles.acq.Bmode_data(:,:,frame_number);
    BfData = handles.acq.PAmode_data(:,:,frame_number);
    
    % Display US
    DisplayUSdata(handles, abs_data, handles.acq.param);
    
    % Display PA
    handles = DisplayPAdata(handles, BfData, handles.acq.param);
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ROIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Va chercher les positions des ROIs du frame
    for index = 1:4
        if (~isempty(handles.acq.roi_positions{1,index}))
            pos = handles.acq.roi_positions{1,index};
            
            % Cree un nouveau ROI
            h = impoly(handles.axes1, pos);
            h_bis = impoly(handles.axes2, pos);
            
            % Le stocke
            handles.acq.hrois_us{index} = h;
            handles.acq.hrois_pa{index} = h_bis;
            
            switch (index)
                case 1
                    setColor(h,'yellow');
                    setColor(h_bis,'yellow');
                case 2
                    setColor(h,'red');
                    setColor(h_bis,'red');
                case 3
                    setColor(h,'blue');
                    setColor(h_bis,'blue');
                case 4
                    setColor(h,'green');
                    setColor(h_bis,'green');
            end
            
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
end

handles = unlock_interface(handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function frame_number_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frame_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function total_frames_Callback(hObject, eventdata, handles)
% hObject    handle to total_frames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of total_frames as text
%        str2double(get(hObject,'String')) returns contents of total_frames as a double


% --- Executes during object creation, after setting all properties.
function total_frames_CreateFcn(hObject, eventdata, handles)
% hObject    handle to total_frames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in previous_button.
function previous_button_Callback(hObject, eventdata, handles)
% hObject    handle to previous_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

frame_number = handles.acq.frame_number;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ROIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Stocke les positions des ROIs du frame actuel
for index = 1:4
    % Si le handle de la ROI existe
    if (~isempty(handles.acq.hrois_us{index}))
        temp_h = handles.acq.hrois_us{index};
        
        % Si la ROI existe
        if (isvalid(temp_h))
            
            % Copie la position
            pos = getPosition(temp_h);
 
            % Le stocke
            handles.acq.roi_positions{1,index} = pos;
        else
            handles.acq.roi_positions{1,index} = [];            
        end
        
        % Detruit le handle de toute facon
        handles.acq.hrois_us{index} = [];
        
    else
        handles.acq.roi_positions{1,index} = [];
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


frame_number = handles.acq.frame_number;
frame_number = frame_number - 1;

set(handles.frame_number, 'string', num2str(frame_number));
handles.acq.frame_number = frame_number;

if frame_number <= 1
   set(handles.previous_button, 'enable','off');
else
   set(handles.next_button, 'enable','on');
end

handles = lock_interface(handles);
pause(0.5);

if (strcmp(handles.acq.source_type, 'IQ'))
    % Display US
    handles = VsiBModeReconstructRFModif(handles, handles.acq.short_data_path, frame_number);

    % Display PA
    if (get(handles.checkbox_pa_display,'value'))
        VsiBeamformPaModif(handles, handles.acq.short_data_path, frame_number, frame_number);
    end
else
    abs_data = handles.acq.Bmode_data(:,:,frame_number);
    BfData = handles.acq.PAmode_data(:,:,frame_number);
    
    % Display US
    DisplayUSdata(handles, abs_data, handles.acq.param);
    
    % Display PA
    handles = DisplayPAdata(handles, BfData, handles.acq.param);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ROIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Va chercher les positions des ROIs du frame
    for index = 1:4
        if (~isempty(handles.acq.roi_positions{1,index}))
            pos = handles.acq.roi_positions{1,index};
            
            % Cree un nouveau ROI
            h = impoly(handles.axes1, pos);
            h_bis = impoly(handles.axes2, pos);
            
            % Le stocke
            handles.acq.hrois_us{index} = h;
            handles.acq.hrois_pa{index} = h_bis;
            
            
            switch (index)
                case 1
                    setColor(h,'yellow');
                    setColor(h_bis,'yellow');
                case 2
                    setColor(h,'red');
                    setColor(h_bis,'red');
                case 3
                    setColor(h,'blue');
                    setColor(h_bis,'blue');
                case 4
                    setColor(h,'green');
                    setColor(h_bis,'green');
            end
            
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

handles = unlock_interface(handles);
guidata(hObject, handles);


% --- Executes on button press in checkbox_pa_display.
function checkbox_pa_display_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_pa_display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_pa_display



function edit_voffset_Callback(hObject, eventdata, handles)
% hObject    handle to edit_voffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_voffset as text
%        str2double(get(hObject,'String')) returns contents of edit_voffset as a double

VOffset = str2num(get(handles.edit_voffset,'string'));
handles.acq.VOffset = VOffset;

% Display US
frame_number = handles.acq.frame_number;
handles = VsiBModeReconstructRFModif(handles, handles.acq.short_data_path, frame_number);

% Display PA
if (get(handles.checkbox_pa_display,'value'))
    VsiBeamformPaModif(handles, handles.acq.short_data_path, frame_number, frame_number);
end

guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function edit_voffset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_voffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_yoffset_Callback(hObject, eventdata, handles)
% hObject    handle to edit_yoffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_yoffset as text
%        str2double(get(hObject,'String')) returns contents of edit_yoffset as a double
YOffset = str2num(get(handles.edit_yoffset,'string'));
handles.acq.YOffset = YOffset;

% Display US
frame_number = handles.acq.frame_number;
handles = VsiBModeReconstructRFModif(handles, handles.acq.short_data_path, frame_number);

% Display PA
if (get(handles.checkbox_pa_display,'value'))
    VsiBeamformPaModif(handles, short_data_path, frame_number, frame_number);
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_yoffset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_yoffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in load_preprocessed.
function load_preprocessed_Callback(hObject, eventdata, handles)
% hObject    handle to load_preprocessed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles, 'acq')
    if isfield(handles.acq, 'open_PathName');
        [open_FileName,open_PathName] = uigetfile('*.mat','Ouvrir un fichier de données',handles.acq.open_PathName);
    elseif isfield(handles.acq, 'working_directory')
        [open_FileName,open_PathName] = uigetfile('*.mat','Ouvrir un fichier de données',handles.acq.working_directory);   
    else
        [open_FileName,open_PathName] = uigetfile('*.mat','Ouvrir un fichier de données');
    end
else
   [open_FileName,open_PathName] = uigetfile('*.mat','Ouvrir un fichier de données');
end


if (open_FileName)
    
    data_path = strcat([open_PathName open_FileName]);
    handles.acq.data_path = data_path;
    handles.acq.open_FileName = open_FileName;
    handles.acq.open_PathName = open_PathName;
    
    % Load interface parameters
    handles.acq.YOffset = str2num(get(handles.edit_yoffset,'string'));
    handles.acq.VOffset = str2num(get(handles.edit_voffset,'string'));

    % Create ROI
    handles.acq.hrois_us = cell(4,1);
    handles.acq.hrois_pa = cell(4,1);
    handles.acq.roi_positions = cell(1,4);
        
    % Type of data
    handles.acq.source_type = 'MAT';
        
    % Load data
    clear Bmode_data;
    clear PAmode_data;
    clear abs_data;
    clear BfData;
    load(data_path);
    handles.acq.Bmode_data = Bmode_data;
    handles.acq.PAmode_data = PAmode_data;
    handles.acq.param = param;
    handles.acq.n_frames = processing_param.n_frames;
    
    abs_data = Bmode_data(:,:,1);
    BfData = PAmode_data(:,:,1);
            
    handles.acq.frame_number = 1;
    set(handles.frame_number,'string',num2str(1));
    set(handles.frame_number,'enable','on');
    set(handles.total_frames,'string',num2str(handles.acq.n_frames));
    set(handles.previous_button,'enable','off');
    set(handles.next_button,'enable','on');
    set(handles.display_filename_preprocessed, 'string', open_FileName);
    set(handles.display_filename_iq, 'string', '');
    set(handles.pushbutton_preprocess, 'enable','off');
%     set(handles.pushbutton_define_roi, 'enable','on');
    
    set(handles.open_segmentation,'enable','on');
    set(handles.save_segmentation,'enable','on');
    set(handles.ROI1,'enable','on');
    set(handles.ROI2,'enable','on');
    set(handles.ROI3,'enable','on');
    set(handles.ROI4,'enable','on');
    
    handles = lock_interface(handles);
    pause(0.5);
    
    handles.acq.starting_flag = true;
        
    % Display US
    DisplayUSdata(handles, abs_data, param);
    
    % Display PA
    handles = DisplayPAdata(handles, BfData, param);
      
    % Set offsets in interface
    set(handles.edit_yoffset,'enable', 'on');
    set(handles.edit_voffset,'enable', 'on');
        
    handles = unlock_interface(handles);
    

end

guidata(hObject, handles);

function display_filename_preprocessed_Callback(hObject, eventdata, handles)
% hObject    handle to display_filename_preprocessed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of display_filename_preprocessed as text
%        str2double(get(hObject,'String')) returns contents of display_filename_preprocessed as a double


% --- Executes during object creation, after setting all properties.
function display_filename_preprocessed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to display_filename_preprocessed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_preprocess.
function pushbutton_preprocess_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_preprocess (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.display_status,'string', 'Preprocessing data...');
handles = lock_interface(handles);
pause(0.5);

[handles] = PreprocessData(handles, handles.acq.short_data_path, handles.acq.n_frames);

set(handles.display_status,'string', 'Data preprocessed OK');
handles = unlock_interface(handles);


function display_status_Callback(hObject, eventdata, handles)
% hObject    handle to display_status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of display_status as text
%        str2double(get(hObject,'String')) returns contents of display_status as a double


% --- Executes during object creation, after setting all properties.
function display_status_CreateFcn(hObject, eventdata, handles)
% hObject    handle to display_status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_extract_temporal.
function pushbutton_extract_temporal_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_extract_temporal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dim3_PA_data = size(handles.acq.PAmode_data,3);
n_temporal_points = floor(dim3_PA_data/2);
data_temporel = zeros(n_temporal_points, 2, 4);

% Stocke les positions des ROIs du frame actuel
for index = 1:4
    % Si le handle de la ROI existe
    if (~isempty(handles.acq.hrois_us{index}))
        temp_h = handles.acq.hrois_us{index};
        
        % Si la ROI existe
        if (isvalid(temp_h))
            
            % Copie la position
            pos = getPosition(temp_h);
 
            % Le stocke
            handles.acq.roi_positions{1,index} = pos;
            
                    
            dim1_PA_data = size(handles.acq.PAmode_data,1);
            dim2_PA_data = size(handles.acq.PAmode_data,2);
            xdata = get(handles.acq.h_axes2,'XData');
            pixelx = axes2pix(dim2_PA_data, xdata, pos(:,1));
            ydata = get(handles.acq.h_axes2,'YData');
            pixely = axes2pix(dim1_PA_data, ydata, pos(:,2));
            
            bw = poly2mask(pixelx, pixely, dim1_PA_data, dim2_PA_data);
            [I] = find(bw);
            
            BfData = handles.acq.PAmode_data(:,:,handles.acq.frame_number);
            % BfData(I) = 0;
            % handles = DisplayPAdata(handles, BfData, handles.acq.param);
            
            data_temporel(:,:,index) = extract_curves(handles, 2, I);
            
            data_filename = strcat([handles.acq.open_PathName 'temporal\' get(handles.data_filename,'string')]);
            y1 = data_temporel(:,1,index);
            figure;plot(y1,'r:');
            y_filtered1 = smooth(y1, 5, 'moving');
            hold on
            plot(y_filtered1,'r-','LineWidth',2);
            curve_title = strcat([handles.acq.open_FileName]);
            title(curve_title);
            xlabel('sec');
            
            y2 = data_temporel(:,2,index);
            hold on
            plot(y2,'k:');
            y_filtered2 = smooth(y2, 5, 'moving');
            hold on
            plot(y_filtered2,'k-','LineWidth',2);
%             curve_title = strcat([handles.acq.open_FileName '__950nm']);
            title(curve_title);            
            xlabel('sec');
            
            save(data_filename,'y1','y_filtered1','y2','y_filtered2');
        else
            handles.acq.roi_positions{1,index} = [];            
        end

        % Detruit le handle de toute facon
%         handles.acq.hrois_us{index} = [];
        
    else
%         handles.acq.roi_positions{1,index} = [];
    end
end


% % Si le handle de la ROI existe
% if (~isempty(handles.acq.hrois_us{index}))
%     temp_h = handles.acq.hrois_us{index};
%     
%     % Si la ROI existe
%     if (isvalid(temp_h))
%         
%         % Copie la position
%         pos = getPosition(temp_h);
%         
%         % Le stocke
%         handles.acq.roi_positions{frame_number,index} = pos;
%     else
%         handles.acq.roi_positions{frame_number,index} = [];
%     end
%     
%     % Detruit le handle de toute facon
%     handles.acq.hrois_us{index} = [];
%     
% else
%     handles.acq.roi_positions{frame_number,index} = [];
% end
% 
% dim1_PA_data = size(handles.acq.PAmode_data,1);
% dim2_PA_data = size(handles.acq.PAmode_data,2);
% xdata = get(handles.acq.h_axes2,'XData');
% pixelx = axes2pix(dim2_PA_data, xdata, pos(:,1));
% ydata = get(handles.acq.h_axes2,'YData');
% pixely = axes2pix(dim1_PA_data, ydata, pos(:,2));
% 
% bw = poly2mask(pixelx, pixely, dim1_PA_data, dim2_PA_data);
% [I] = find(bw);
%             
% BfData = handles.acq.PAmode_data(:,:,handles.acq.frame_number);
% % BfData(I) = 0;
% % handles = DisplayPAdata(handles, BfData, handles.acq.param);
% 
% data = extract_curves(handles, 2, I);

guidata(hObject, handles);


% --- Executes on button press in wavelength1.
function wavelength1_Callback(hObject, eventdata, handles)
% hObject    handle to wavelength1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of wavelength1


% --- Executes on button press in wavelength2.
function wavelength2_Callback(hObject, eventdata, handles)
% hObject    handle to wavelength2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of wavelength2


% --- Executes on button press in wavelength3.
function wavelength3_Callback(hObject, eventdata, handles)
% hObject    handle to wavelength3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of wavelength3


% --- Executes on button press in wavelength4.
function wavelength4_Callback(hObject, eventdata, handles)
% hObject    handle to wavelength4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of wavelength4


% --- Executes on button press in wavelength5.
function wavelength5_Callback(hObject, eventdata, handles)
% hObject    handle to wavelength5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of wavelength5



function edit_acq_type_Callback(hObject, eventdata, handles)
% hObject    handle to edit_acq_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_acq_type as text
%        str2double(get(hObject,'String')) returns contents of edit_acq_type as a double


% --- Executes during object creation, after setting all properties.
function edit_acq_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_acq_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

load_iq_Callback(hObject, eventdata, handles);


% --- Executes on button press in open_segmentation.
function open_segmentation_Callback(hObject, eventdata, handles)
% hObject    handle to open_segmentation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles, 'acq')
    if isfield(handles.acq, 'open_PathName');
        data_path = strcat([handles.acq.open_PathName handles.acq.open_FileName]);
        index_mat = findstr(data_path, '.mat');
        data_path_to_open = strcat([data_path(1:(index_mat-1)) '.segment.mat']);
        [open_FileName,open_PathName] = uigetfile('*.mat','Ouvrir un fichier de segmentation', data_path_to_open);
    elseif isfield(handles.acq, 'working_directory')
        [open_FileName,open_PathName] = uigetfile('*.mat','Ouvrir un fichier de segmentation',handles.acq.working_directory);   
    else
        [open_FileName,open_PathName] = uigetfile('*.mat','Ouvrir un fichier de segmentation');
    end
else
   [open_FileName,open_PathName] = uigetfile('*.mat','Ouvrir un fichier de segmentation');
end

if (open_FileName)
    
    data_path = strcat([open_PathName open_FileName]);
       
    load(data_path, 'roi_positions');

    handles.acq.roi_positions = roi_positions;

    % Update les ROIs affichées
    frame_number = str2num(get(handles.frame_number,'string'));

    if (frame_number >= 1 && frame_number <= handles.acq.n_frames)
        %     handles = VsiBModeReconstructRFExtended(handles, handles.acq.short_data_path, frame_number);
        
        handles.acq.frame_number = frame_number;
        
        abs_data = handles.acq.Bmode_data(:,:,frame_number);
        BfData = handles.acq.PAmode_data(:,:,frame_number);
        
        % Display US
        DisplayUSdata(handles, abs_data, handles.acq.param);
        
        % Display PA
        handles = DisplayPAdata(handles, BfData, handles.acq.param);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ROIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Va chercher les positions des ROIs du frame
        for index = 1:4
            if (~isempty(handles.acq.roi_positions{1,index}))
                pos = handles.acq.roi_positions{1,index};
                
                % Cree un nouveau ROI
                h = impoly(handles.axes1, pos);
                h_bis = impoly(handles.axes2, pos);
                
                % Le stocke
                handles.acq.hrois_us{index} = h;
                handles.acq.hrois_pa{index} = h_bis;
                
                switch (index)
                    case 1
                        setColor(h,'yellow');
                        setColor(h_bis,'yellow');
                    case 2
                        setColor(h,'red');
                        setColor(h_bis,'red');
                    case 3
                        setColor(h,'blue');
                        setColor(h_bis,'blue');
                    case 4
                        setColor(h,'green');
                        setColor(h_bis,'green');
                end
                
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        
        if frame_number == handles.acq.n_frames
            set(handles.next_button,'enable','off');
            %         set(handles.next_copy_button,'enable','off');
            set(handles.previous_button,'enable','on');
        end
        
        if frame_number == 1
            set(handles.previous_button,'enable','off');
            set(handles.next_button,'enable','on');
            %         set(handles.next_copy_button,'enable','on');
        end
    end
    
%     set(handles.pushbutton_extract_temporal,'enable','on');

end
guidata(hObject, handles);


% --- Executes on button press in save_segmentation.
function save_segmentation_Callback(hObject, eventdata, handles)
% hObject    handle to save_segmentation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Stocker les ROIs de la frame actuelle
% frame_number = handles.acq.frame_number;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ROIs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Stocke les positions des ROIs du frame actuel
for index = 1:4
    % Si le handle de la ROI existe
    if (~isempty(handles.acq.hrois_us{index}))
        temp_h = handles.acq.hrois_us{index};
        
        % Si la ROI existe
        if (isvalid(temp_h))
            
            % Copie la position
            pos = getPosition(temp_h);

            % Le stocke
            handles.acq.roi_positions{1,index} = pos;
        else
            handles.acq.roi_positions{1,index} = [];            
        end
        
        % Detruit le handle de toute facon
        handles.acq.hrois_us{index} = [];
        
    else
        handles.acq.roi_positions{1,index} = [];
    end
end

%%%%%%%%%%%%%%%%%%%%%%% Polyline for Air %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
% % Si le handle de la ROI existe
% if (~isempty(handles.acq.hairline{1}))
%     temp_h = handles.acq.hairline{1};
%     
%     % Si la ROI existe
%     if (isvalid(temp_h))
%         
%         % Copie la position
%         pos = getPosition(temp_h);
%         
%         % Le stocke
%         handles.acq.airline_positions{frame_number} = pos;
%     else
%         handles.acq.airline_positions{frame_number} = [];
%     end
%     
%     % Detruit le handle de toute facon
%     handles.acq.hairline{1} = [];
%     
% else
%     handles.acq.airline_positions{frame_number} = [];
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ROIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Va chercher les positions des ROIs du frame
    for index = 1:4
        if (~isempty(handles.acq.roi_positions{1,index}))
            pos = handles.acq.roi_positions{1,index};
            
            % Cree un nouveau ROI
            h = impoly(handles.axes1, pos);
            h_bis = impoly(handles.axes2, pos);
            
            % Le stocke
            handles.acq.hrois_us{index} = h;
            
            
            switch (index)
                case 1
                    setColor(h,'yellow');
                    setColor(h_bis,'yellow');
                case 2
                    setColor(h,'red');
                    setColor(h_bis,'red');
                case 3
                    setColor(h,'blue');
                    setColor(h_bis,'blue');
                case 4
                    setColor(h,'green');
                    setColor(h_bis,'green');
            end
            
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
data_path = handles.acq.data_path;
index_mat = findstr(data_path, '.mat');
data_path_to_save = strcat([data_path(1:(index_mat-1)) '.segment.mat']);
[filename, pathname] = uiputfile(data_path_to_save, 'Save Segmentation as');

complete_filename = [pathname filename];

if ~isempty(complete_filename)
    roi_positions = handles.acq.roi_positions;
    save(complete_filename,'roi_positions');
%     set(handles.pushbutton_extract_temporal,'enable','on');
end
guidata(hObject, handles);


% --- Executes on button press in ROI1.
function ROI1_Callback(hObject, eventdata, handles)
% hObject    handle to ROI1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ROI1

frame_number = str2num(get(handles.frame_number,'string'));
h = impoly;

if (~isempty(handles.acq.hrois_pa{1}))
    temp_h = handles.acq.hrois_pa{1};
    
    if (isvalid(temp_h))
       delete(temp_h);
    end
end

handles.acq.hrois_us{1} = h;
handles.acq.hrois_pa{1} = h;
setColor(h,'yellow');
guidata(hObject, handles);


% --- Executes on button press in ROI2.
function ROI2_Callback(hObject, eventdata, handles)
% hObject    handle to ROI2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ROI2

frame_number = str2num(get(handles.frame_number,'string'));
h = impoly;

if (~isempty(handles.acq.hrois_us{2}))
    temp_h = handles.acq.hrois_us{2};
    
    if (isvalid(temp_h))
       delete(temp_h);
    end
end

handles.acq.hrois_us{2} = h;
handles.acq.hrois_pa{2} = h;
setColor(h,'red');
guidata(hObject, handles);


% --- Executes on button press in ROI3.
function ROI3_Callback(hObject, eventdata, handles)
% hObject    handle to ROI3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ROI3
frame_number = str2num(get(handles.frame_number,'string'));
h = impoly;

if (~isempty(handles.acq.hrois_us{3}))
    temp_h = handles.acq.hrois_us{3};
    
    if (isvalid(temp_h))
       delete(temp_h);
    end
end

handles.acq.hrois_us{3} = h;
handles.acq.hrois_pa{3} = h;
setColor(h,'blue');
guidata(hObject, handles);


% --- Executes on button press in ROI4.
function ROI4_Callback(hObject, eventdata, handles)
% hObject    handle to ROI4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ROI4
frame_number = str2num(get(handles.frame_number,'string'));
h = impoly;

if (~isempty(handles.acq.hrois_us{4}))
    temp_h = handles.acq.hrois_us{4};
    
    if (isvalid(temp_h))
       delete(temp_h);
    end
end

handles.acq.hrois_us{4} = h;
handles.acq.hrois_pa{4} = h;
setColor(h,'green');
guidata(hObject, handles);


% --- Executes on button press in roi_pa_master.
function roi_pa_master_Callback(hObject, eventdata, handles)
% hObject    handle to roi_pa_master (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

frame_number = handles.acq.frame_number;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ROIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Stocke les positions des ROIs du frame actuel
for index = 1:4
    % Si le handle de la ROI existe
    if (~isempty(handles.acq.hrois_pa{index}))
        temp_h = handles.acq.hrois_pa{index};
        
        % Si la ROI existe
        if (isvalid(temp_h))
            
            % Copie la position
            pos = getPosition(temp_h);
 
            % Le stocke
            handles.acq.roi_positions{1,index} = pos;
        else
            handles.acq.roi_positions{1,index} = [];            
        end
        
        % Detruit le handle de toute facon
        handles.acq.hrois_us{index} = [];
        handles.acq.hrois_pa{index} = [];
        
    else
        handles.acq.roi_positions{1,index} = [];
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


abs_data = handles.acq.Bmode_data(:,:,frame_number);
BfData = handles.acq.PAmode_data(:,:,frame_number);


% Display US
DisplayUSdata(handles, abs_data, handles.acq.param);

% Display PA
handles = DisplayPAdata(handles, BfData, handles.acq.param);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ROIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Va chercher les positions des ROIs du frame
for index = 1:4
    if (~isempty(handles.acq.roi_positions{1,index}))
        pos = handles.acq.roi_positions{1,index};
        
        % Cree un nouveau ROI
        h = impoly(handles.axes1, pos);
        h_bis = impoly(handles.axes2, pos);
        
        % Le stocke
        handles.acq.hrois_us{index} = h;
        handles.acq.hrois_pa{index} = h_bis;
        
        switch (index)
            case 1
                setColor(h,'yellow');
                setColor(h_bis,'yellow');
            case 2
                setColor(h,'red');
                setColor(h_bis,'red');
            case 3
                setColor(h,'blue');
                setColor(h_bis,'blue');
            case 4
                setColor(h,'green');
                setColor(h_bis,'green');
        end
        
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

guidata(hObject, handles);


% --- Executes on button press in roi_us_master.
function roi_us_master_Callback(hObject, eventdata, handles)
% hObject    handle to roi_us_master (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

frame_number = handles.acq.frame_number;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ROIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Stocke les positions des ROIs du frame actuel
for index = 1:4
    % Si le handle de la ROI existe
    if (~isempty(handles.acq.hrois_us{index}))
        temp_h = handles.acq.hrois_us{index};
        
        % Si la ROI existe
        if (isvalid(temp_h))
            
            % Copie la position
            pos = getPosition(temp_h);
 
            % Le stocke
            handles.acq.roi_positions{1,index} = pos;
        else
            handles.acq.roi_positions{1,index} = [];            
        end
        
        % Detruit le handle de toute facon
        handles.acq.hrois_us{index} = [];
        handles.acq.hrois_pa{index} = [];
        
    else
        handles.acq.roi_positions{1,index} = [];
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


abs_data = handles.acq.Bmode_data(:,:,frame_number);
BfData = handles.acq.PAmode_data(:,:,frame_number);

% Display US
DisplayUSdata(handles, abs_data, handles.acq.param);

% Display PA
handles = DisplayPAdata(handles, BfData, handles.acq.param);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ROIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Va chercher les positions des ROIs du frame
for index = 1:4
    if (~isempty(handles.acq.roi_positions{1,index}))
        pos = handles.acq.roi_positions{1,index};
        
        % Cree un nouveau ROI
        h = impoly(handles.axes1, pos);
        h_bis = impoly(handles.axes2, pos);
        
        % Le stocke
        handles.acq.hrois_us{index} = h;
        handles.acq.hrois_pa{index} = h_bis;
        
        switch (index)
            case 1
                setColor(h,'yellow');
                setColor(h_bis,'yellow');
            case 2
                setColor(h,'red');
                setColor(h_bis,'red');
            case 3
                setColor(h,'blue');
                setColor(h_bis,'blue');
            case 4
                setColor(h,'green');
                setColor(h_bis,'green');
        end
        
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

guidata(hObject, handles);



function data_filename_Callback(hObject, eventdata, handles)
% hObject    handle to data_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of data_filename as text
%        str2double(get(hObject,'String')) returns contents of data_filename as a double

set(handles.pushbutton_extract_temporal,'enable','on');

% --- Executes during object creation, after setting all properties.
function data_filename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to data_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_axes.
function pushbutton_axes_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.axes2);
