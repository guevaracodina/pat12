function varargout = GUI_SEGMENT(varargin)
% GUI_SEGMENT M-file for GUI_SEGMENT.fig
%      GUI_SEGMENT, by itself, creates a new GUI_SEGMENT or raises the existing
%      singleton*.
%
%      H = GUI_SEGMENT returns the handle to a new GUI_SEGMENT or the handle to
%      the existing singleton*.
%
%      GUI_SEGMENT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_SEGMENT.M with the given input arguments.
%
%      GUI_SEGMENT('Property','Value',...) creates a new GUI_SEGMENT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_SEGMENT_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_SEGMENT_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_SEGMENT

% Last Modified by GUIDE v2.5 08-Mar-2012 12:33:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_SEGMENT_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_SEGMENT_OutputFcn, ...
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


% --- Executes just before GUI_SEGMENT is made visible.
function GUI_SEGMENT_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_SEGMENT (see VARARGIN)

% Choose default command line output for GUI_SEGMENT
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_SEGMENT wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_SEGMENT_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in load_image.
function load_image_Callback(hObject, eventdata, handles)
% hObject    handle to load_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[open_FileName,open_PathName] = uigetfile('*.iq.bmode','Ouvrir un fichier de données');


if (open_FileName)
    
    data_path = strcat([open_PathName open_FileName]);
    handles.acq.data_path = data_path;
    handles.acq.open_FileName = open_FileName;
    handles.acq.open_PathName = open_PathName;
    
    str_temp = strfind(data_path, '.bmode');
    
    if (str_temp)
        
        short_data_path = data_path(1:str_temp-1);
        shortest_data_path = data_path(1:str_temp-4);
        handles.acq.short_data_path = short_data_path;
        handles.acq.shortest_data_path = shortest_data_path;
        
        xml_data_path = [data_path(1:str_temp) 'xml'];

        param = VsiParseXmlExtended(xml_data_path,'.3dmode');
        handles.acq.param = param;
        handles.acq.n_frames = floor(param.ScanDistance/param.StepSize);
           
        handles.acq.hrois = cell(4,1);
        handles.acq.roi_positions = cell(handles.acq.n_frames,4);
        
        
        handles = VsiBModeReconstructRFExtended(handles, short_data_path, 1);
        
        handles.acq.frame_number = 1;
        set(handles.frame_number,'string',num2str(1));
        set(handles.frame_number,'enable','on');
        set(handles.total_frames,'string',num2str(handles.acq.n_frames));
        set(handles.next_button,'enable','on');
        set(handles.next_copy_button,'enable','on');
        set(handles.display_filename, 'string', open_FileName);
        set(handles.segment_button,'enable','on');
        set(handles.open_segmentation,'enable','on');
        set(handles.save_segmentation,'enable','on');
        set(handles.ROI1,'enable','on');
        set(handles.ROI2,'enable','on');
        set(handles.ROI3,'enable','on');
        set(handles.ROI4,'enable','on');
        set(handles.duplicate_all,'enable','on');
    end
end

guidata(hObject, handles);


function display_filename_Callback(hObject, eventdata, handles)
% hObject    handle to display_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of display_filename as text
%        str2double(get(hObject,'String')) returns contents of display_filename as a double


% --- Executes during object creation, after setting all properties.
function display_filename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to display_filename (see GCBO)
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


% Stocke les positions des ROIs du frame actuel
for index = 1:4
    % Si le handle de la ROI existe
    if (~isempty(handles.acq.hrois{index}))
        temp_h = handles.acq.hrois{index};
        
        % Si la ROI existe
        if (isvalid(temp_h))
            
            % Copie la position
            pos = getPosition(temp_h);

            % Le stocke
            handles.acq.roi_positions{frame_number,index} = pos;
        else
            handles.acq.roi_positions{frame_number,index} = [];            
        end
        
        % Detruit le handle de toute facon
        handles.acq.hrois{index} = [];
        
    else
        handles.acq.roi_positions{frame_number,index} = [];
    end
end


frame_number = frame_number + 1;

set(handles.frame_number, 'string', num2str(frame_number));
handles.acq.frame_number = frame_number;

handles = VsiBModeReconstructRFExtended(handles, handles.acq.short_data_path, frame_number);

% Va chercher les positions des ROIs du frame
for index = 1:4
    if (~isempty(handles.acq.roi_positions{frame_number,index}))
        pos = handles.acq.roi_positions{frame_number,index};
        
        % Cree un nouveau ROI
        h = impoly(handles.axes1, pos);
            
        % Le stocke
        handles.acq.hrois{index} = h;
        
            
        switch (index)
            case 1
                setColor(h,'yellow');
            case 2
                setColor(h,'red');
            case 3
                setColor(h,'blue');
            case 4
                setColor(h,'green');
        end

    end
end

if frame_number >= handles.acq.n_frames
   set(handles.next_button, 'enable','off'); 
   set(handles.next_copy_button, 'enable','off'); 
else
   set(handles.previous_button, 'enable','on');
end
guidata(hObject, handles);



function frame_number_Callback(hObject, eventdata, handles)
% hObject    handle to frame_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frame_number as text
%        str2double(get(hObject,'String')) returns contents of frame_number as a double

frame_number = handles.acq.frame_number;

% Stocke les positions des ROIs du frame actuel
for index = 1:4
    % Si le handle de la ROI existe
    if (~isempty(handles.acq.hrois{index}))
        temp_h = handles.acq.hrois{index};
        
        % Si la ROI existe
        if (isvalid(temp_h))
            
            % Copie la position
            pos = getPosition(temp_h);

            % Le stocke
            handles.acq.roi_positions{frame_number,index} = pos;
        else
            handles.acq.roi_positions{frame_number,index} = [];            
        end
        
        % Detruit le handle de toute facon
        handles.acq.hrois{index} = [];
        
    else
        handles.acq.roi_positions{frame_number,index} = [];
    end
end

% Update le nouveau numéro de frame
frame_number = str2num(get(handles.frame_number,'string'));

if (frame_number >= 1 && frame_number <= handles.acq.n_frames)
    handles = VsiBModeReconstructRFExtended(handles, handles.acq.short_data_path, frame_number);

    handles.acq.frame_number = frame_number;
    
    % Va chercher les positions des ROIs du frame
    for index = 1:4
        if (~isempty(handles.acq.roi_positions{frame_number,index}))
            pos = handles.acq.roi_positions{frame_number,index};
            
            % Cree un nouveau ROI
            h = impoly(handles.axes1, pos);
            
            % Le stocke
            handles.acq.hrois{index} = h;
            
            
            switch (index)
                case 1
                    setColor(h,'yellow');
                case 2
                    setColor(h,'red');
                case 3
                    setColor(h,'blue');
                case 4
                    setColor(h,'green');
            end
            
        end
    end
    
    if frame_number == handles.acq.n_frames
        set(handles.next_button,'enable','off');
        set(handles.next_copy_button,'enable','off');
        set(handles.previous_button,'enable','on');
    end
    
    if frame_number == 1
        set(handles.previous_button,'enable','off');
        set(handles.next_button,'enable','on');
        set(handles.next_copy_button,'enable','on');
    end
end
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


% Stocke les positions des ROIs du frame actuel
for index = 1:4
    % Si le handle de la ROI existe
    if (~isempty(handles.acq.hrois{index}))
        temp_h = handles.acq.hrois{index};
        
        % Si la ROI existe
        if (isvalid(temp_h))
            
            % Copie la position
            pos = getPosition(temp_h);

            % Le stocke
            handles.acq.roi_positions{frame_number,index} = pos;
        else
            handles.acq.roi_positions{frame_number,index} = [];            
        end
        
        % Detruit le handle de toute facon
        handles.acq.hrois{index} = [];
        
    else
        handles.acq.roi_positions{frame_number,index} = [];
    end
end


frame_number = frame_number - 1;

set(handles.frame_number, 'string', num2str(frame_number));
handles.acq.frame_number = frame_number;

handles = VsiBModeReconstructRFExtended(handles, handles.acq.short_data_path, frame_number);

% Va chercher les positions des ROIs du frame avant
for index = 1:4
    if (~isempty(handles.acq.roi_positions{frame_number,index}))
        pos = handles.acq.roi_positions{frame_number,index};
        
        % Cree un nouveau ROI
        h = impoly(handles.axes1, pos);
            
        % Le stocke
        handles.acq.hrois{index} = h;
        
            
        switch (index)
            case 1
                setColor(h,'yellow');
            case 2
                setColor(h,'red');            
            case 3
                setColor(h,'blue');
            case 4
                setColor(h,'green');
        end

    end
end


if frame_number <= 1
   set(handles.previous_button, 'enable','off');
else
   set(handles.next_button, 'enable','on');
   set(handles.next_copy_button, 'enable','on');
end
guidata(hObject, handles);


% --- Executes on button press in next_copy_button.
function next_copy_button_Callback(hObject, eventdata, handles)
% hObject    handle to next_copy_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

frame_number = handles.acq.frame_number;

% Stocke les positions des ROIs du frame actuel
for index = 1:4
    % Si le handle de la ROI existe
    if (~isempty(handles.acq.hrois{index}))
        temp_h = handles.acq.hrois{index};
        
        % Si la ROI existe
        if (isvalid(temp_h))
            
            % Copie la position
            pos = getPosition(temp_h);

            % Le stocke
            handles.acq.roi_positions{frame_number,index} = pos;
        else
            handles.acq.roi_positions{frame_number,index} = [];            
        end
        
        % Detruit le handle de toute facon
        handles.acq.hrois{index} = [];
        
    else
        handles.acq.roi_positions{frame_number,index} = [];
    end
end


frame_number = frame_number + 1;

set(handles.frame_number, 'string', num2str(frame_number));
handles.acq.frame_number = frame_number;

handles = VsiBModeReconstructRFExtended(handles, handles.acq.short_data_path, frame_number);
guidata(hObject, handles);

% Va chercher les positions des ROIs du frame avant
for index = 1:4
    if (~isempty(handles.acq.roi_positions{frame_number-1,index}))
        pos = handles.acq.roi_positions{frame_number-1,index};
        
        % Cree un nouveau ROI
        h = impoly(handles.axes1, pos);
            
        % Le stocke
        handles.acq.hrois{index} = h;
        
            
        switch (index)
            case 1
                setColor(h,'yellow');
            case 2
                setColor(h,'red');           
            case 3
                setColor(h,'blue');
            case 4
                setColor(h,'green');
        end

    end
end


if frame_number >= handles.acq.n_frames
   set(handles.next_button, 'enable','off'); 
   set(handles.next_copy_button, 'enable','off'); 
else
   set(handles.previous_button, 'enable','on');
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

if (~isempty(handles.acq.hrois{1}))
    temp_h = handles.acq.hrois{1};
    
    if (isvalid(temp_h))
       delete(temp_h);
    end
end

handles.acq.hrois{1} = h;
setColor(h,'yellow');
% BW = createMask(h,handles.acq.himage);
guidata(hObject, handles);

% --- Executes on button press in ROI2.
function ROI2_Callback(hObject, eventdata, handles)
% hObject    handle to ROI2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ROI2
frame_number = str2num(get(handles.frame_number,'string'));
h = impoly;

if (~isempty(handles.acq.hrois{2}))
    temp_h = handles.acq.hrois{2};
    
    if (isvalid(temp_h))
       delete(temp_h);
    end
end

handles.acq.hrois{2} = h;
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

if (~isempty(handles.acq.hrois{3}))
    temp_h = handles.acq.hrois{3};
    
    if (isvalid(temp_h))
       delete(temp_h);
    end
end

handles.acq.hrois{3} = h;
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

if (~isempty(handles.acq.hrois{4}))
    temp_h = handles.acq.hrois{4};
    
    if (isvalid(temp_h))
       delete(temp_h);
    end
end

handles.acq.hrois{4} = h;
setColor(h,'green');
guidata(hObject, handles);


% --- Executes on button press in segment_button.
function segment_button_Callback(hObject, eventdata, handles)
% hObject    handle to segment_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Stocker les ROIs de la frame actuelle
frame_number = handles.acq.frame_number;

% Stocke les positions des ROIs du frame actuel
for index = 1:4
    % Si le handle de la ROI existe
    if (~isempty(handles.acq.hrois{index}))
        temp_h = handles.acq.hrois{index};
        
        % Si la ROI existe
        if (isvalid(temp_h))
            
            % Copie la position
            pos = getPosition(temp_h);

            % Le stocke
            handles.acq.roi_positions{frame_number,index} = pos;
        else
            handles.acq.roi_positions{frame_number,index} = [];            
        end
        
        % Detruit le handle de toute facon
        handles.acq.hrois{index} = [];
        
    else
        handles.acq.roi_positions{frame_number,index} = [];
    end
end


% Génère le nouveau volume
resolution = str2num( get(handles.resolution,'string'));
sizeVoxX = floor( str2num(get(handles.dimX, 'string')) / resolution );
sizeVoxY = floor( str2num(get(handles.dimY, 'string')) / resolution );
sizeVoxZ = floor( str2num(get(handles.dimZ, 'string')) / resolution );

segmented_volume = zeros(sizeVoxX, sizeVoxY, sizeVoxZ);

image_dimY = handles.acq.image_dims(1);
image_dimX = handles.acq.image_dims(2);


% Parcourir chaque frame; pour chaque type de ROI : obtenir BW segmenté (0, 1, 2, 3)
for i_frame = 1:handles.acq.n_frames
    
    % Réinitialisation pour chaque frame
    bw_cumulative = zeros(sizeVoxZ, sizeVoxX);
    
    for i_roi = 1:4
        if (~isempty(handles.acq.roi_positions{i_frame, i_roi}))
            pos = handles.acq.roi_positions{i_frame,i_roi};
            
            x_pos = pos(:,1);
            y_pos = pos(:,2);
            
            BmodeDepth = handles.acq.param.BmodeDepth;
            BmodeDepthOffset = handles.acq.param.BmodeDepthOffset;
            BmodeWidth = handles.acq.param.BmodeWidth;
            
            % Changement de coordonnées en y
            slope_y = (BmodeDepth - BmodeDepthOffset) / (image_dimY - 1);
            x0 = BmodeDepth - slope_y*image_dimY;

            x0_vector = ones(size(y_pos))*x0;
            y_new_coords = (slope_y*y_pos + x0_vector)/resolution;
            
            
            % Changement de coordonnées en y
            midX_new_coords = ceil((sizeVoxX-1)/2);
            midX_old_coords = ceil((image_dimX-1)/2);
                        
            slope_x = BmodeWidth / (2*resolution*(midX_old_coords-1));
            x0 = midX_new_coords - slope_x*midX_old_coords;
            x0_vector = ones(size(x_pos))*x0;
            
            x_new_coords = slope_x*x_pos + x0_vector;
            
            bw = poly2mask(x_new_coords, y_new_coords, sizeVoxZ, sizeVoxX);
%             figure; imshow(bw);
            bw_indexes = find(bw);
            
            switch (i_roi)
                case 1
                    bw(bw_indexes) = 1;
                    bw_cumulative = bw;

                case 2
                    bw(bw_indexes) = 2;
                    bw_cumulative = bw + bw_cumulative;
                    
                    bw_cumulative(find(bw & bw_cumulative)) = 2;  
                case 3
                    bw(bw_indexes) = 3;
                    bw_cumulative = bw + bw_cumulative;
                    
                    bw_cumulative(find(bw & bw_cumulative)) = 3;                     
                case 4
                    bw(bw_indexes) = 4;
                    bw_cumulative = bw + bw_cumulative;
                    
                    bw_cumulative(find(bw & bw_cumulative)) = 4;  
            end  
            
        end
    end
    
    segmented_volume(:,i_frame,:) = bw_cumulative';
    
    if i_frame == 1
         figure; imagesc(squeeze(segmented_volume(:,i_frame,:)));
         axis equal
    end

end

volume_filename = [handles.acq.shortest_data_path '_segmented.mat'];
save(volume_filename,'segmented_volume');

% Va chercher les positions des ROIs du frame
for index = 1:4
    if (~isempty(handles.acq.roi_positions{frame_number,index}))
        pos = handles.acq.roi_positions{frame_number,index};
        
        % Cree un nouveau ROI
        h = impoly(handles.axes1, pos);
        
        % Le stocke
        handles.acq.hrois{index} = h;
        
        
        switch (index)
            case 1
                setColor(h,'yellow');
            case 2
                setColor(h,'red');
            case 3
                setColor(h,'blue');
            case 4
                setColor(h,'green');
        end
        
    end
end

guidata(hObject, handles);


function dimX_Callback(hObject, eventdata, handles)
% hObject    handle to dimX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dimX as text
%        str2double(get(hObject,'String')) returns contents of dimX as a double


% --- Executes during object creation, after setting all properties.
function dimX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dimX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dimY_Callback(hObject, eventdata, handles)
% hObject    handle to dimY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dimY as text
%        str2double(get(hObject,'String')) returns contents of dimY as a double


% --- Executes during object creation, after setting all properties.
function dimY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dimY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dimZ_Callback(hObject, eventdata, handles)
% hObject    handle to dimZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dimZ as text
%        str2double(get(hObject,'String')) returns contents of dimZ as a double


% --- Executes during object creation, after setting all properties.
function dimZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dimZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function resolution_Callback(hObject, eventdata, handles)
% hObject    handle to resolution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of resolution as text
%        str2double(get(hObject,'String')) returns contents of resolution as a double


% --- Executes during object creation, after setting all properties.
function resolution_CreateFcn(hObject, eventdata, handles)
% hObject    handle to resolution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in open_segmentation.
function open_segmentation_Callback(hObject, eventdata, handles)
% hObject    handle to open_segmentation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
open_filename = uigetfile('*.mat','Ouvrir un fichier de segmentation');

load(open_filename, 'roi_positions');

handles.acq.roi_positions = roi_positions;

% Update les ROIs affichées
frame_number = str2num(get(handles.frame_number,'string'));

if (frame_number >= 1 && frame_number <= handles.acq.n_frames)
    handles = VsiBModeReconstructRFExtended(handles, handles.acq.short_data_path, frame_number);

    handles.acq.frame_number = frame_number;
    
    % Va chercher les positions des ROIs du frame
    for index = 1:4
        if (~isempty(handles.acq.roi_positions{frame_number,index}))
            pos = handles.acq.roi_positions{frame_number,index};
            
            % Cree un nouveau ROI
            h = impoly(handles.axes1, pos);
            
            % Le stocke
            handles.acq.hrois{index} = h;
            
            
            switch (index)
                case 1
                    setColor(h,'yellow');
                case 2
                    setColor(h,'red');
                case 3
                    setColor(h,'blue');
                case 4
                    setColor(h,'green');
            end
            
        end
    end
    
    if frame_number == handles.acq.n_frames
        set(handles.next_button,'enable','off');
        set(handles.next_copy_button,'enable','off');
        set(handles.previous_button,'enable','on');
    end
    
    if frame_number == 1
        set(handles.previous_button,'enable','off');
        set(handles.next_button,'enable','on');
        set(handles.next_copy_button,'enable','on');
    end
end

guidata(hObject, handles);

% --- Executes on button press in save_segmentation.
function save_segmentation_Callback(hObject, eventdata, handles)
% hObject    handle to save_segmentation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Stocker les ROIs de la frame actuelle
frame_number = handles.acq.frame_number;

% Stocke les positions des ROIs du frame actuel
for index = 1:4
    % Si le handle de la ROI existe
    if (~isempty(handles.acq.hrois{index}))
        temp_h = handles.acq.hrois{index};
        
        % Si la ROI existe
        if (isvalid(temp_h))
            
            % Copie la position
            pos = getPosition(temp_h);

            % Le stocke
            handles.acq.roi_positions{frame_number,index} = pos;
        else
            handles.acq.roi_positions{frame_number,index} = [];            
        end
        
        % Detruit le handle de toute facon
        handles.acq.hrois{index} = [];
        
    else
        handles.acq.roi_positions{frame_number,index} = [];
    end
end


[filename, pathname] = uiputfile('segment.mat', 'Save Segmentation as');

complete_filename = [pathname filename]

roi_positions = handles.acq.roi_positions;

save(complete_filename,'roi_positions');
guidata(hObject, handles);


% --- Executes on button press in duplicate_all.
function duplicate_all_Callback(hObject, eventdata, handles)
% hObject    handle to duplicate_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Stocker les ROIs de la frame actuelle
frame_number = handles.acq.frame_number;

% Stocke les positions des ROIs du frame actuel
for index = 1:4
    % Si le handle de la ROI existe
    if (~isempty(handles.acq.hrois{index}))
        temp_h = handles.acq.hrois{index};
        
        % Si la ROI existe
        if (isvalid(temp_h))
            
            % Copie la position
            pos = getPosition(temp_h);

            % Le stocke
            handles.acq.roi_positions{frame_number,index} = pos;
        else
            handles.acq.roi_positions{frame_number,index} = [];            
        end
        
        % Detruit le handle de toute facon
        handles.acq.hrois{index} = [];
        
    else
        handles.acq.roi_positions{frame_number,index} = [];
    end
end


for i_frame = 1:handles.acq.n_frames
    
    for i_roi = 1:4
        handles.acq.roi_positions{i_frame, i_roi} = handles.acq.roi_positions{frame_number, i_roi};
    end
    
end

% Va chercher les positions des ROIs du frame
for index = 1:4
    if (~isempty(handles.acq.roi_positions{frame_number,index}))
        pos = handles.acq.roi_positions{frame_number,index};
        
        % Cree un nouveau ROI
        h = impoly(handles.axes1, pos);
        
        % Le stocke
        handles.acq.hrois{index} = h;
        
        
        switch (index)
            case 1
                setColor(h,'yellow');
            case 2
                setColor(h,'red');
            case 3
                setColor(h,'blue');
            case 4
                setColor(h,'green');
        end
        
    end
end

guidata(hObject, handles);