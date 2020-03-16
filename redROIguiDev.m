function varargout = redROIguiDev(varargin)
% REDROIGUIDEV MATLAB code for redROIguiDev.fig
%      REDROIGUIDEV, by itself, creates a new REDROIGUIDEV or raises the existing
%      singleton*.
%
%      H = REDROIGUIDEV returns the handle to a new REDROIGUIDEV or the handle to
%      the existing singleton*.
%
%      REDROIGUIDEV('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REDROIGUIDEV.M with the given input arguments.
%
%      REDROIGUIDEV('Property','Value',...) creates a new REDROIGUIDEV or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before redROIguiDev_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to redROIguiDev_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help redROIguiDev

% Last Modified by GUIDE v2.5 03-Feb-2016 17:59:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @redROIguiDev_OpeningFcn, ...
                   'gui_OutputFcn',  @redROIguiDev_OutputFcn, ...
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


% --- Executes just before redROIguiDev is made visible.
function redROIguiDev_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to redROIguiDev (see VARARGIN)

% Choose default command line output for redROIguiDev
handles.output = hObject;

if iscell(varargin{1})
    ROI = varargin{1};
    nPlanes = numel(ROI);
    for ipl = 1:nPlanes
        planeString{ipl} = num2str(ipl);
    end
else
    Img = varargin{1};
[nX, nY, nPlanes] = size(Img);

for ipl = 1:nPlanes
ROI{ipl}.Img = Img(:,:, ipl);
ROI{ipl}.filtImg = Img(:,:, ipl);
ROI{ipl}.sigma = 0;
ROI{ipl}.Map = zeros(nX, nY);
ROI{ipl}.Cells = cell(0);
ROI{ipl}.nroi = 0;
planeString{ipl} = num2str(ipl);
end
end

set(handles.figure1, 'UserData', ROI);
set(handles.listbox3, 'String', planeString);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes redROIguiDev wait for user response (see UIRESUME)
% uiwait(handles.figure1);

currPl = 1;
set(handles.listbox3, 'Value', currPl);

imgMin = min(ROI{currPl}.Img(:));
imgMax = max(ROI{currPl}.Img(:));

if imgMin == imgMax
    imgMin = imgMin -1;
    imgMax = imgMax+1;
end

set(handles.slider3, 'Min', imgMin);
set(handles.slider3, 'Max', imgMax);
set(handles.slider3, 'Value', imgMin);

set(handles.slider4, 'Min', imgMin);
set(handles.slider4, 'Max', imgMax);
set(handles.slider4, 'Value', imgMax);

set(handles.slider5, 'Min', imgMin);
set(handles.slider5, 'Max', imgMax);
set(handles.slider5, 'Value', imgMax);

set(handles.slider6, 'Min', 0);
set(handles.slider6, 'Max', 5);
set(handles.slider6, 'Value', 0);

ImgBW = roiFinder(handles, ROI{currPl}.filtImg);
% % axes(handles.axes1);
% imagesc(img, 'Parent', handles.axes1); axis image;
drawImg(handles, ROI{currPl}.filtImg, ImgBW)

fprintf('Display plane of choice, use sliders to threshold and/or smooth to detect ROIs, use buttons to select/deselect ROIs')
set(handles.figure1,'WindowButtonDownFcn',{@clickPosition,handles})



% --- Outputs from this function are returned to the command line.
function varargout = redROIguiDev_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

dispMin = get(handles.slider3, 'Value');
dispMax = get(handles.slider4, 'Value');

if dispMin > dispMax
    dispMin = dispMax-0.1;
end
axes(handles.axes1);
caxis([dispMin, dispMax]);


% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider4_Callback(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

dispMin = get(handles.slider3, 'Value');
dispMax = get(handles.slider4, 'Value');
if dispMax <dispMin
    dispMax = dispMin + 0.1;
end
axes(handles.axes1);
caxis([dispMin, dispMax]);

% --- Executes during object creation, after setting all properties.
function slider4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

select = get(handles.togglebutton1, 'Value');
deselect = get(handles.togglebutton2, 'Value');

if select
    if deselect
        set(handles.togglebutton2, 'Value', 0)
        fprintf('ROI de-selection OFF \n');
    end
    
    fprintf('ROI selection ON: click within black neuron outline to select ROI\n');
else
    fprintf('ROI selection OFF \n');
    
end



% --- Executes on button press in togglebutton2.
function togglebutton2_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

select = get(handles.togglebutton1, 'Value');
deselect = get(handles.togglebutton2, 'Value');

if deselect
    if select
        set(handles.togglebutton1, 'Value', 0)
        fprintf('ROI selection OFF \n');
    end
    fprintf('ROI de-selection ON: click within red neuron outline to deselect ROI\n');
else
    fprintf('ROI de-selection OFF \n');
end

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ROI = get(handles.figure1,'UserData');

fprintf('Saving file to current dir\n');
save('redROI','ROI'); %save the Cell ROIs in the mat cellFile

fprintf('ROI exported to base workspace\n');
assignin('base', 'redROI', ROI); %export the variable ROI to the base workspace

% --- Executes on slider movement.
function slider5_Callback(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
ROI = get(handles.figure1,'UserData');
plStr = get(handles.listbox3, 'String');
currPl = get(handles.listbox3, 'Value');
currPl = str2double(plStr(currPl));

ImgBW = roiFinder(handles, ROI{currPl}.filtImg);
drawImg(handles, ROI{currPl}.filtImg, ImgBW);

% --- Executes during object creation, after setting all properties.
function slider5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on selection change in listbox3.
function listbox3_Callback(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ROI = get(handles.figure1,'UserData');
plStr = get(handles.listbox3, 'String');
currPl = get(handles.listbox3, 'Value');
currPl = str2double(plStr(currPl));

imgMin = min(ROI{currPl}.Img(:));
imgMax = max(ROI{currPl}.Img(:));

if imgMin == imgMax
    imgMin = imgMin -1;
    imgMax = imgMax+1;
end

set(handles.slider3, 'Min', imgMin);
set(handles.slider3, 'Max', imgMax);
set(handles.slider3, 'Value', imgMin);

set(handles.slider4, 'Min', imgMin);
set(handles.slider4, 'Max', imgMax);
set(handles.slider4, 'Value', imgMax);

set(handles.slider5, 'Min', imgMin);
set(handles.slider5, 'Max', imgMax);
set(handles.slider5, 'Value', imgMax);

set(handles.slider6, 'Value', ROI{currPl}.sigma);

ImgBW = roiFinder(handles, ROI{currPl}.filtImg);
drawImg(handles, ROI{currPl}.filtImg, ImgBW)
% set(handles.figure1,'WindowButtonDownFcn',{@clickPosition,handles})

% Hints: contents = cellstr(get(hObject,'String')) returns listbox3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox3


% --- Executes during object creation, after setting all properties.
function listbox3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider6_Callback(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

ROI = get(handles.figure1,'UserData');
plStr = get(handles.listbox3, 'String');
currPl = get(handles.listbox3, 'Value');
currPl = str2double(plStr(currPl));
sigma = get(handles.slider6, 'Value');

if sigma >0
    ROI{currPl}.filtImg = imgaussfilt(ROI{currPl}.Img, sigma);
else
    ROI{currPl}.filtImg = ROI{currPl}.Img;
end

ROI{currPl}.sigma = sigma;
ImgBW = roiFinder(handles, ROI{currPl}.filtImg);
drawImg(handles, ROI{currPl}.filtImg, ImgBW)
set(handles.figure1,'UserData',ROI);




% --- Executes during object creation, after setting all properties.
function slider6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function drawImg(handles, Img, ImgBW)
    
ROI = get(handles.figure1,'UserData');

plStr = get(handles.listbox3, 'String');
currPl = get(handles.listbox3, 'Value');
currPl = str2double(plStr(currPl));

imagesc(Img, 'Parent', handles.axes1);
axis image
colormap(jet); hold on
if sum(ImgBW(:)>0) ~= 0
contour(ImgBW, [1,1]*0.5, 'color','k','linewidth',2, 'Parent',handles.axes1);
end
for iroi=1:ROI{currPl}.nroi
    contour(ROI{currPl}.Cells{iroi}, [1,1]*0.5, 'color','r','linewidth',2, 'Parent',handles.axes1)
end

dispMin = get(handles.slider3, 'Value');
dispMax = get(handles.slider4, 'Value');
caxis([dispMin, dispMax]);
hold off


function [ImgBW, ImgLabel] = roiFinder(handles, Img)
thrs = get(handles.slider5, 'Value');
ImgBW = Img > thrs;
ImgLabel = bwlabel(ImgBW);



function handles = clickPosition(~,~,handles)

ROI = get(handles.figure1,'UserData');
plStr = get(handles.listbox3, 'String');
currPl = get(handles.listbox3, 'Value');
currPl = str2double(plStr(currPl));

[ImgBW, ImgLabel] = roiFinder(handles, ROI{currPl}.filtImg);    

select = get(handles.togglebutton1, 'Value');
deselect = get(handles.togglebutton2, 'Value');

pos = get(gca, 'CurrentPoint');
x=round(pos(1));
y=round(pos(3));
try
PxL = ImgLabel(y,x);

if select
    if PxL >0
        ROI{currPl}.nroi = ROI{currPl}.nroi +1;
        [pix_y,pix_x]=find(ImgLabel==PxL);
        for j=1:length(pix_x)
            ROI{currPl}.Map(pix_y(j),pix_x(j)) = ROI{currPl}.nroi;
        end
        ROI{currPl}.Cells=[ROI{currPl}.Cells,ImgLabel==PxL];
        
    end
elseif deselect
    roiID = ROI{currPl}.Map(y,x);
    if roiID >0
            ROI{currPl}.Map(ROI{currPl}.Map ==roiID) =0;
            if roiID == ROI{currPl}.nroi
                ROI{currPl}.Cells = ROI{currPl}.Cells(1: end-1);
            else
                for iroi = roiID:ROI{currPl}.nroi-1;
                    ROI{currPl}.Cells{iroi} = ROI{currPl}.Cells{iroi+1};
                end
                ROI{currPl}.Cells = ROI{currPl}.Cells(1: end-1);
            end
            
            ROI{currPl}.nroi = ROI{currPl}.nroi-1;

            for iroi = 1: ROI{currPl}.nroi
                ROI{currPl}.Map(ROI{currPl}.Cells{iroi}) = iroi;
            end
%             ROI{currPl}.Map(ROI{currPl}.Map>roiID) = ROI{currPl}.Map(ROI{currPl}.Map>roiID)-1;
            
%             ROI{currPl}.nroi = ROI{currPl}.nroi-1;

    end
end
catch
    warning('You have to click within the image!! Try again')
end
set(handles.figure1,'WindowButtonDownFcn',{@clickPosition,handles})
set(handles.figure1,'UserData',ROI);
drawImg(handles, ROI{currPl}.filtImg, ImgBW)



% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
