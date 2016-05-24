function varargout = color_scale_tool(varargin)
%COLOR_SCALE_TOOL GUI for creating a color scale.
%   COLOR_SCALE_TOOL launches a GUI for creating a colormap using the
%   COLOR_SCALE function.  COLOR_SCALE computes a colormap that works well 
%   on color displays and also works well when printed on a grayscale 
%   printer.  The COLOR_SCALE_TOOL allows you to manipulate the input
%   parameters for COLOR_SCALE using sliders.  These input parameters are:
%
%     n      Number of colors in the colormap.
%     theta  Angle (in degrees) in the a*-b* plane of the first color. 
%     r      Radius of the semicircular path in the a*-b* plane.
%
%   You can also choose the direction of the semicircular path using radio
%   buttons.
%
%   The GUI shows you both the color scale and a grayscale approximation.
%   Once you are satisfied with the color scale, you can click on the
%   "Export to workspace" button to save the color scale as a variable in
%   your workspace.
%
%   See also COLOR_SCALE.

%   Steve Eddins

% Edit the above text to modify the response to help color_scale_tool

% Last Modified by GUIDE v2.5 08-May-2006 16:19:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @color_scale_tool_OpeningFcn, ...
                   'gui_OutputFcn',  @color_scale_tool_OutputFcn, ...
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


% --- Executes just before color_scale_tool is made visible.
function color_scale_tool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to color_scale_tool (see VARARGIN)

% Choose default command line output for color_scale_tool
handles.output = hObject;

handles.color_image = image('Parent', handles.color_axes, ...
    'CData', [], ...
    'Tag', 'color_image');

handles.gray_image = image('Parent', handles.gray_axes, ...
    'CData', [], ...
    'Tag', 'gray_image');

set(handles.radio_clockwise, ...
    'Callback', @(varargin) updateColorScaleImages(hObject));
set(handles.radio_counterclockwise, ...
    'Callback', @(varargin) updateColorScaleImages(hObject));

% Update handles structure
guidata(hObject, handles);

s = load('helpicon');
set(handles.help_button, 'CData', s.iconRGB);

updateColorScaleImages(hObject);

% UIWAIT makes color_scale_tool wait for user response (see UIRESUME)
% uiwait(handles.help);


% --- Outputs from this function are returned to the command line.
function varargout = color_scale_tool_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function r_slider_Callback(hObject, eventdata, handles)
% hObject    handle to r_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

updateSliderLabel(hObject, 'r_label');
updateColorScaleImages(hObject);


% --- Executes during object creation, after setting all properties.
function r_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to r_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

updateSliderLabel(hObject, 'r_label');


% --- Executes on slider movement.
function theta_slider_Callback(hObject, eventdata, handles)
% hObject    handle to theta_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

updateSliderLabel(hObject, 'theta_label');
updateColorScaleImages(hObject);


% --- Executes during object creation, after setting all properties.
function theta_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to theta_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

updateSliderLabel(hObject, 'theta_label');


% --- Executes on slider movement.
function n_slider_Callback(hObject, eventdata, handles)
% hObject    handle to n_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of
%        slider

updateSliderLabel(hObject, 'n_label');
updateColorScaleImages(hObject);


% --- Executes during object creation, after setting all properties.
function n_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to n_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

updateSliderLabel(hObject, 'n_label');

% --- Update slider label to match its value
function updateSliderLabel(hObject, labelTag)
% hObject    handle to slider object
% labelTag   Tag value of slider label

handles = guihandles(hObject);
newString = sprintf('%d', round(get(hObject, 'Value')));
set(handles.(labelTag), 'String', newString);

% --- Update color scale images.
function updateColorScaleImages(hObject)

handles = guihandles(hObject);
n = round(get(handles.n_slider, 'Value'));
theta = get(handles.theta_slider, 'Value');
r = get(handles.r_slider, 'Value');
if get(handles.radio_clockwise, 'Value') ~= 0
    direction = 'cw';
else
    direction = 'ccw';
end

map = color_scale(n, theta, r, direction);
color_cdata = reshape(map, 1, n, 3);
set(handles.color_image, 'CData', color_cdata);

gray_map = rgb2gray(map);
gray_cdata = reshape(gray_map, 1, n ,3);
set(handles.gray_image, 'CData', gray_cdata);

set(handles.color_axes, 'XLim', [0.5 n+0.5]);
set(handles.gray_axes,  'XLim', [0.5 n+0.5]);

% --- Executes on button press in export.
function export_Callback(hObject, eventdata, handles)
% hObject    handle to export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

map = get(handles.color_image, 'CData');
map = squeeze(map);

export2wsdlg({'Color scale'}, {'map'}, {map});





% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in help_button.
function help_button_Callback(hObject, eventdata, handles)
% hObject    handle to help_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

doc('color_scale_tool')

