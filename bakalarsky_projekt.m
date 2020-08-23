function varargout = bakalarsky_projekt(varargin)
% BAKALARSKY_PROJEKT MATLAB code for bakalarsky_projekt.fig
%      BAKALARSKY_PROJEKT, by itself, creates a new BAKALARSKY_PROJEKT or raises the existing
%      singleton*.
%
%      H = BAKALARSKY_PROJEKT returns the handle to a new BAKALARSKY_PROJEKT or the handle to
%      the existing singleton*.s
%
%      BAKALARSKY_PROJEKT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BAKALARSKY_PROJEKT.M with the given input arguments.
%
%      BAKALARSKY_PROJEKT('Property','Value',...) creates a new BAKALARSKY_PROJEKT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bakalarsky_projekt_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bakalarsky_projekt_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bakalarsky_projekt

% Last Modified by GUIDE v2.5 24-May-2018 20:43:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bakalarsky_projekt_OpeningFcn, ...
                   'gui_OutputFcn',  @bakalarsky_projekt_OutputFcn, ...
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


% --- Executes just before bakalarsky_projekt is made visible.
function bakalarsky_projekt_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bakalarsky_projekt (see VARARGIN)

% Choose default command line output for bakalarsky_projekt


handles.output = hObject;
movegui(gcf,'center')
numOfChannels = -1;
while numOfChannels == -1
   numOfChannels = inpdlg(); 
end    
if numOfChannels == 0
    userData.numOfChannels = numOfChannels;
    set(handles.appGui,'userdata',userData);
else    
    emptyPlot(numOfChannels);
    if(numOfChannels == 1)
        set(handles.sliderY,'enable','off');
    elseif(numOfChannels == 2)
        set(handles.sliderY,'enable','off');
        ylim([numOfChannels*2-4 numOfChannels*2])
    else        
        ylim([numOfChannels*2-4 numOfChannels*2])
        set(handles.sliderY,'min',(-2)*numOfChannels+4,'max',0,...
        'Value',0);
    end
    for i = 1:8
        if i <= numOfChannels
            set(handles.(strcat('channelN',num2str(i))),'Value',1);
        else
            set(handles.(strcat('channelN',num2str(i))), 'enable', 'off');
        end
    end   
    set(handles.sliderX,'enable','off');
    userData.settings = get(handles.chooseSettings,'String');
    userData.defaultSettings = {'1' '44100' '2'};
    userData.defaultAudio = 0;
    userData.adr = audioDeviceReader();
    userData.adw = audioDeviceWriter('SupportVariableSizeInput', true);
    userData.audioPlayerRecorder = audioPlayerRecorder();
    userData.numOfChannels = numOfChannels;
    userData.recordedSound = zeros(1024,numOfChannels);
    userData.selectedSettings = userData.settings;
    userData.adrSettings = {'1' '44100' '2'};
    userData.adwSettings = {'1' '44100' '2'};
    userData.aprSettings = {'1' '44100' '2'};
    set(handles.appGui,'userdata',userData);
    set(handles.bitDepth,'Value',2);
    set(handles.zoomSlider,'min',1,'Value',1,'enable','off');   
    set(handles.appGui,'CloseRequestFcn',@closeGUI);
end
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = bakalarsky_projekt_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
userData = get(handles.appGui,'userdata');
if userData.numOfChannels == 0
    set(gcf,'visible','off');
    appGui_CloseRequestFcn(hObject, eventdata, handles);
end   
% --- Executes on button press in open_file.
%otevreni daneho audio souboru pomoci dialogoveho okna
%k nahrani jsem zatim pouzil audioread, protoze audioFileReader cte audio
%postupne a k nahrani napr. minutoveho audia do prostredi by trvalo celou
%minutu, coz je neefektivni
%pripadne ale predelam zpet do audioFileReaderu
function open_file_Callback(hObject, eventdata, handles)
% hObject    handle to open_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path] = uigetfile({'*.mp3'; '*.wav'},'File Selector');
if isequal(file,0)
   return
else
    openFile(fullfile(path,file));
    userData = get(handles.appGui,'userdata');
    setInfo(userData.length,userData.audioFs,userData.numOfChannels);
    set(handles.playTime,'String',sprintf('%d / %g s',0, round(userData.length*100)/100));
    set(handles.selectionDisplay,'String','');
    set(findall(handles.axes),'HitTest','on','ButtonDownFcn',@axes_ButtonDownFcn);
    if isfield(userData, 'selectedPart')
        userData = rmfield(userData,{'selectedPart','leftBorderLine','rightBorderLine'});
    end
    set(handles.appGui,'userdata',userData);
    userData
end

% --- Executes on button press in addToList.
%pridani vybraneho audia pomoci dialogoveho okna a typu audia do seznamu
%pouze zatim jako pridani nazvu
function addToList_Callback(hObject, eventdata, handles)
% hObject    handle to addToList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path] = uigetfile({'*.mp3'; '*.wav'},'File Selector');
if isequal(file,0)
   return
else
    userData = get(handles.appGui,'userdata');
    if isfield(userData,'listOfAudios')
        itemExist = false;
        for i = 1:size(userData.listOfAudios,1)
            if(strcmp(userData.listOfAudios{i},fullfile(path,file)))
                uiwait(msgbox('This audio file is already in list!'));
                itemExist = true;
                addToList_Callback(hObject, eventdata, handles);
                break;
            end    
        end
        if ~itemExist
            userData.listOfAudios = [userData.listOfAudios; cellstr(fullfile(path,file))];
            userData.displayedAudios = [userData.displayedAudios; cellstr(file)];
            set(handles.listOfAudioFiles,'String',userData.displayedAudios);
        end
    else
        userData.listOfAudios = cellstr(fullfile(path,file));
        userData.displayedAudios = cellstr(file);
        set(handles.listOfAudioFiles,'String',userData.displayedAudios);
    end
    set(handles.appGui,'userdata',userData);
end


% --- Executes on button press in deleteFromList.
function deleteFromList_Callback(hObject, eventdata, handles)
% hObject    handle to deleteFromList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userData = get(handles.appGui,'userdata');
if isfield(userData,'listOfAudios')
    value = get(handles.listOfAudioFiles,'Value');
    if (value == userData.defaultAudio)
        userData.defaultAudio = 0;
    elseif(value < userData.defaultAudio)
        userData.defaultAudio = userData.defaultAudio - 1;
    end
    if size(userData.listOfAudios,1) == 1
        set(handles.listOfAudioFiles,'Value',1,'String',[]);
        userData = rmfield(userData,{'listOfAudios','displayedAudios'})
    else
        userData.listOfAudios(value) = [];
        userData.displayedAudios(value) = [];
        set(handles.listOfAudioFiles,'Value',1,'String',userData.displayedAudios); 
    end
    set(handles.appGui,'userdata',userData);
else
    msgbox('List is empty!');
end

% --- Executes on selection change in listOfAudioFiles.
%listOfAudioFiles je seznam nahraneho audia do fronty
function listOfAudioFiles_Callback(hObject, eventdata, handles)
% hObject    handle to listOfAudioFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listOfAudioFiles contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listOfAudioFiles
userData = get(handles.appGui,'userdata');
if isfield(userData,'listOfAudios') && strcmp(get(gcf,'SelectionType'),'open')  
    listOfAudios = userData.listOfAudios;
    getCurrentValue = get(handles.listOfAudioFiles,'Value');
    selection = checkSaving();
    if selection == 1
        saveSound(userData.audioFs,userData.audio);
        if isfield(userData,'savedAudioData')
            if isequal(userData.audio,userData.savedAudioData)
                openFile(listOfAudios{getCurrentValue});
                userData = get(handles.appGui,'userdata');
                userData.defaultAudio = getCurrentValue;
                set(handles.selectionDisplay,'String','');
                setInfo(userData.length,userData.audioFs,userData.numOfChannels);
                set(handles.listOfAudioFiles,'Value',getCurrentValue);
                set(handles.zoomSlider,'enable','on');
                userData
            end
        end
    elseif selection == -1 || selection == 0 || selection == 2
        openFile(listOfAudios{getCurrentValue});
        userData = get(handles.appGui,'userdata');
        userData.defaultAudio = getCurrentValue;
        set(handles.selectionDisplay,'String','');
        setInfo(userData.length,userData.audioFs,userData.numOfChannels);
        set(handles.listOfAudioFiles,'Value', getCurrentValue);
        userData
    end
    set(handles.appGui,'userdata',userData);
    set(findall(handles.axes),'HitTest','on','ButtonDownFcn',@axes_ButtonDownFcn);
end

% --- Executes during object creation, after setting all properties.
function listOfAudioFiles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listOfAudioFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
    
end


% --- Executes on button press in stop_button.
function stop_button_Callback(hObject, eventdata, handles)
% hObject    handle to stop_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userData = get(handles.appGui,'userdata');
if isfield(userData,'audio')
    playingLine = userData.playingLine;
    set(handles.play,'Value',0);
    set(playingLine,'XData',[0 0]);
    set(handles.playTime,'String',sprintf('%d / %g s',0, round(userData.length*100)/100));
    userData.playingLine = playingLine;
    set(handles.appGui,'userdata',userData);
end
% --- Executes on button press in previousTrack.
%previousTrack bude slouzit k nacteni predchoziho audia ze seznamu
function previousTrack_Callback(hObject, eventdata, handles)
% hObject    handle to previousTrack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userData = get(handles.appGui,'userdata');
if isfield(userData,'listOfAudios')
    if(userData.defaultAudio == 0 || userData.defaultAudio == 1)
        msgbox('No other previous record in list!');
    else
        selection = checkSaving();
        if selection == 1
            saveSound(userData.audioFs,userData.audio);
            if isfield(userData,'savedAudioData')
                if isequal(userData.audio,userData.savedAudioData)
                    defaultAudio = userData.defaultAudio - 1;
                    openFile(userData.listOfAudios{defaultAudio});
                    userData = get(handles.appGui,'userdata');
                    set(handles.selectionDisplay,'String','');
                    setInfo(userData.length,userData.audioFs,userData.numOfChannels);
                    set(handles.zoomSlider,'enable','on'); 
                    set(handles.playTime,'String',sprintf('%d / %g s',0, round(userData.length*100)/100));
                    set(findall(handles.axes),'HitTest','on','ButtonDownFcn',@axes_ButtonDownFcn);
                    set(handles.listOfAudioFiles,'Value',defaultAudio);
                    userData.defaultAudio = defaultAduio;
                    set(handles.appGui,'userdata',userData);
                end
            end
        elseif selection == -1 || selection == 0 || selection == 2
            defaultAudio = userData.defaultAudio - 1;
            openFile(userData.listOfAudios{defaultAudio});
            userData = get(handles.appGui,'userdata');
            set(handles.selectionDisplay,'String','');
            setInfo(userData.length,userData.audioFs,userData.numOfChannels);
            set(handles.zoomSlider,'enable','on'); 
            set(handles.playTime,'String',sprintf('%d / %g s',0, round(userData.length*100)/100));
            set(findall(handles.axes),'HitTest','on','ButtonDownFcn',@axes_ButtonDownFcn);
            set(handles.listOfAudioFiles,'Value',defaultAudio);
            userData.defaultAudio = defaultAudio;
            set(handles.appGui,'userdata',userData);
        end
        set(handles.appGui,'userdata',userData);
    end    
else
    msgbox('List is empty!');
end
%nextTrack bude slouzit pro nacteni dalsiho audia ze seznamu
% --- Executes on button press in nextTrack.
function nextTrack_Callback(hObject, eventdata, handles)
% hObject    handle to nextTrack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userData = get(handles.appGui,'userdata');
if isfield(userData,'listOfAudios')
    if size(userData.listOfAudios,1) == userData.defaultAudio
        msgbox('No other record in list!');
    else 
        selection = checkSaving();
        if selection == 1
            saveSound(userData.audioFs,userData.audio);
            if isfield(userData,'savedAudioData')
                if isequal(userData.audio,userData.savedAudioData)
                    defaultAudio = userData.defaultAudio + 1;
                    openFile(userData.listOfAudios{defaultAudio});
                    userData = get(handles.appGui,'userdata');
                    set(handles.selectionDisplay,'String','');
                    setInfo(size(userData.audio,1)/userData.audioFs,...
                        userData.audioFs,size(userData.audio,2));
                    set(handles.zoomSlider,'enable','on'); 
                    set(handles.playTime,'String',sprintf('%d / %g s',0, round(userData.length*100)/100));
                    set(handles.listOfAudioFiles,'Value',userData.defaultAudio);
                    userData.defaultAudio = defaultAudio
                    set(handles.appGui,'userdata',userData);
                end
            end
        elseif selection == -1 || selection == 0 || selection == 2
            defaultAudio = userData.defaultAudio + 1;
            openFile(userData.listOfAudios{defaultAudio});
            userData = get(handles.appGui,'userdata');
            set(handles.selectionDisplay,'String','');
            setInfo(userData.length,userData.audioFs,size(userData.audio,2));
            set(handles.zoomSlider,'enable','on'); 
            set(handles.playTime,'String',sprintf('%d / %g s',0, round(userData.length*100)/100));
            set(handles.listOfAudioFiles,'Value',defaultAudio);
            userData.defaultAudio = defaultAudio
            set(handles.appGui,'userdata',userData);
        end

    end
    set(handles.appGui,'userdata',userData);
    set(findall(handles.axes),'HitTest','on','ButtonDownFcn',@axes_ButtonDownFcn);
else
    msgbox('List is empty!');    
end

% --- Executes on slider movement.
function sliderX_Callback(hObject, eventdata, handles)
% hObject    handle to sliderX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
userData = get(handles.appGui,'userdata');
shift = get(handles.sliderX,'Value')
length = userData.length
zooming = userData.zooming
xlim([0+shift (length/zooming)+shift])


% --- Executes during object creation, after setting all properties.
function sliderX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sliderY_Callback(hObject, eventdata, handles)
% hObject    handle to sliderY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
userData = get(handles.appGui,'userdata');
shift = get(handles.sliderY,'Value');
y = userData.numOfChannels*2;
ylim([y-4+shift y+shift])

% --- Executes during object creation, after setting all properties.
function sliderY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

%radiobuttony pro kanaly
function channelN1_Callback(hObject, eventdata, handles)
function channelN2_Callback(hObject, eventdata, handles)
function channelN3_Callback(hObject, eventdata, handles)
function channelN4_Callback(hObject, eventdata, handles)
function channelN5_Callback(hObject, eventdata, handles)
function channelN6_Callback(hObject, eventdata, handles)
function channelN7_Callback(hObject, eventdata, handles)
function channelN8_Callback(hObject, eventdata, handles)



%pridani tracku, zatim jen jako pridani radiobuttonu
function addChannel_Callback(hObject, eventdata, handles)
userData = get(handles.appGui,'userdata');
if ~isfield(userData,'audio')
    if(userData.numOfChannels == 8)
        uiwait(msgbox('Cannot add another channel! All channels are already taken.',...
            'Error','error','modal'));
    else
        userData.numOfChannels = userData.numOfChannels + 1;   
        set(handles.(strcat('channelN',num2str(userData.numOfChannels))),...
            'enable', 'on','Value',1);
        userData.recordedSound = zeros(1024,userData.numOfChannels);
        emptyPlot(userData.numOfChannels);
        ylim([userData.numOfChannels*2-4 userData.numOfChannels*2])
        set(handles.sliderY, 'min', (-2)*userData.numOfChannels+4,'max',0,'Value',0);
        if(userData.numOfChannels == 2)
            set(handles.sliderY,'enable','off');
        elseif(userData.numOfChannels > 2)
            set(handles.sliderY,'enable','on');
        end
        set(handles.appGui,'userdata',userData);
        msgbox('Channel was successfully added!');    
    end
else
    msgbox('Cannot add channell! Audio record is already loaded!');
end
%odebrani tracku, zatim jen jako odebrani radiobuttonu
function deleteChannel_Callback(hObject, eventdata, handles)
userData = get(handles.appGui,'userdata');
if ~isfield(userData,'audio')
    if(userData.numOfChannels == 1)
        msgbox('Cannot delete!');    
    else
        set(handles.(strcat('channelN',num2str(userData.numOfChannels))),...
            'enable', 'off','Value',0);
        userData.numOfChannels = userData.numOfChannels - 1;
        if(userData.numOfChannels < 3)
            set(handles.sliderY,'enable','off');
            userData.recordedSound = zeros(1024,userData.numOfChannels);
            emptyPlot(userData.numOfChannels);
            ylim([userData.numOfChannels*2-4 userData.numOfChannels*2])
        else
            userData.recordedSound = zeros(1024,userData.numOfChannels);
            emptyPlot(userData.numOfChannels);
            ylim([userData.numOfChannels*2-4 userData.numOfChannels*2])
            set(handles.sliderY, 'min', (-2)*userData.numOfChannels+4,'max',0,...
                'Value',0);
        end
        set(handles.appGui,'userdata',userData);
        msgbox('Channel was successfully deleted!');
    end
else
    msgbox('Cannot delete channel! Audio record is already loaded!');
end
% Nahravani audia. Nahravam jak do promenne (kvuli plotu), tak i do souboru
% kvuli prehravani pomoci audioDeviceWriter. Plot jsem musel smazat kvuli
% spatne implementaci, kdy se mi nahrane audio zdeformovalo. Do pristiho
% tydne dodelam
function rec_Callback(hObject, eventdata, handles)
userData = get(handles.appGui,'userdata');
try
    if get(hObject,'Value')
        deviceReader =  userData.adr;
        deviceReader.NumChannels = userData.numOfChannels;  
        setup(deviceReader);
        userData.adr = deviceReader;
        recordedSound = userData.recordedSound;
        set(handles.rec,'String','Stop','TooltipString','Stop recording...');
        %turnButtons('off','rec');
        count = 0;
        while get(hObject,'Value')
            acquiredAudio = deviceReader.record;
            recordedSound = [recordedSound; acquiredAudio];
            count = count + 1;
            if(count > 5)
                count = 0;
                plotSound(recordedSound,deviceReader.SampleRate);
                ylim([0 4])
                drawnow
            end
        end
        release(userData.adr);
        userData.audioFs = deviceReader.SampleRate;
        userData.audio = recordedSound;
        userData.recordedSound = zeros(1024,userData.numOfChannels);
        userData.length = size(recordedSound,1)/deviceReader.SampleRate;
        plotSound(recordedSound,deviceReader.SampleRate);
        ylim([0 4])
        AxisLim = axis;
        playingLine = line([AxisLim(1) AxisLim(1)],[AxisLim(3) AxisLim(4)],'color','b',...
            'Marker','*','MarkerEdgeColor','b','LineStyle','-','linewidth',2); 
        userData.playingLine = playingLine; 
       % turnButtons('on','rec');
        set(handles.rec,'String','Rec','TooltipString','Start recording...');
        if size(recordedSound,1)/deviceReader.SampleRate > 100
            set(handles.zoomSlider,'max',100,'enable','on');
        else
            set(handles.zoomSlider, 'max', 10,'enable','on');
        end
        userData.zooming = 1;
        setInfo(size(recordedSound,1)/deviceReader.SampleRate,deviceReader.SampleRate,deviceReader.NumChannels);
        set(handles.appGui,'userdata',userData);
        set(findall(handles.axes),'HitTest','on','ButtonDownFcn',@axes_ButtonDownFcn);
    end
catch e
    set(handles.rec,'Value',0);
    uiwait(errordlg({e.message,sprintf('This device cannot operate with %d channels!',...
        userData.numOfChannels)},'Error'));
end

function sampleRate_Callback(hObject, eventdata, handles)
% hObject    handle to sampleRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sampleRate as text
%        str2double(get(hObject,'String')) returns contents of sampleRate as a double
str = get(handles.sampleRate,'String');
if isnan(str2double(str)) || str2double(str) ~= floor(str2double(str)) || contains(str,',')
    set(handles.sampleRate,'String','44100');
    uiwait(msgbox('Wrong value! Input can be only integer!', 'Error','error','modal'));
elseif (str2double(str) < 1)
    set(handles.sampleRate,'String','44100');
    uiwait(msgbox('Wrong value!', 'Chyba','error','modal'));
else
    userData = get(handles.appGui,'usedata');
    if(strcmp(userData.selectedSettings,'Recording'))
        adr = userData.adr;
        adrSettings = userData.adrSettings;
        adr.SampleRate = str2double(str);
        adrSettings{2} = str;
        userData.adr = adr;
        userData.adrSettings = adrSettings;
    elseif(strcmp(userData.selectedSettings,'Playing'))
        adw = userData.adw;
        adwSettings = userData.adwSettings;
        adw.SampleRate = str2double(str);
        adwSettings{2} = str;
        userData.adw = adw;
        userData.adwSettings = adwSettings;
    else
        apr = userData.audioPlayerRecorder;
        aprSettings = userData.aprSettings;
        apr.SampleRate = str2double(str);
        aprSettings{2} = str;
        userData.audioPlayerRecorder = apr;
        userData.aprSettings = aprSettings;
    end
    set(handles.appGui,'userdata',userData);
end

% --- Executes during object creation, after setting all properties.
function sampleRate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sampleRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in driver.
function driver_Callback(hObject, eventdata, handles)
% hObject    handle to driver (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns driver contents as cell array
%        contents{get(hObject,'Value')} returns selected item from driver
driverValue = get(handles.driver,'Value');
userData = get(handles.appGui,'userdata');
if(strcmp(userData.selectedSettings,'Recording'))
    adrSettings = userData.adrSettings;
    adrSettings{1} = num2str(driverValue);
    userData.adrSettings = adrSettings;
    if driverValue == 2
        adr = userData.adr;
        adr.Driver = 'ASIO';
        asiosettings(adr.Device);
        userData.adr = adr;
    end    
elseif(strcmp(userData.selectedSettings,'Playing'))
    adwSettings = userData.adwSettings;
    adwSettings{1} = num2str(driverValue);
    userData.adwSettings = adwSettings;
    if driverValue == 2
        adw = userData.adw;
        adw.Driver = 'ASIO';
        asiosettings(adw.Device);
        userData.adw = adw;
    end  
elseif(strcmp(userData.selectedSettings,'Playing/Recording'))
    aprSettings = userData.aprSettings;
    aprSettings{1} = num2str(driverValue);
    userData.aprSettings = aprSettings;
    if driverValue == 2
        apr = userData.audioPlayerRecorder;
        asiosettings(apr.Device);
        userData.audioPlayerRecorder = apr;
    end  
end

% --- Executes during object creation, after setting all properties.
function driver_CreateFcn(hObject, eventdata, handles)
% hObject    handle to driver (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in bitDepth.
function bitDepth_Callback(hObject, eventdata, handles)
% hObject    handle to bitDepth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns bitDepth contents as cell array
%        contents{get(hObject,'Value')} returns selected item from bitDepth
userData = get(handles.appGui,'userdata');
bitDepth = get(handles.bitDepth,'String');
bitDepthValue = get(handles.bitDepth,'Value')
if(strcmp(userData.selectedSettings,'Recording'))
    if(strcmp(bitDepth{bitDepthValue},'32-bit'))
        userData.adr.BitDepth = strcat(bitDepth{bitDepthValue},' float')
    else
        userData.adr.BitDepth = strcat(bitDepth{bitDepthValue},' integer');
    end   
    userData.adrSettings{3} = num2str(bitDepthValue)
elseif(strcmp(userData.selectedSettings,'Playing'))
    if(strcmp(bitDepth{bitDepthValue},'32-bit'))
        userData.adw.BitDepth = strcat(bitDepth{bitDepthValue},' float');
    else
        userData.adw.BitDepth = strcat(bitDepth{bitDepthValue},' integer');
    end    
    userData.adwSettings{3} = num2str(bitDepthValue);
else
    if(strcmp(bitDepth{bitDepthValue},'32-bit'))
        userData.apr.BitDepth = strcat(bitDepth{bitDepthValue},' float');
    else
        userData.apr.BitDepth = strcat(bitDepth{bitDepthValue},' integer');
    end    
    userData.aprSettings{3} = num2str(bitDepthValue);
end
set(handles.appGui,'userdata',userData);

% --- Executes during object creation, after setting all properties.
function bitDepth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bitDepth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userData = get(handles.appGui,'userdata')
if isfield(userData,'audio')
    if isfield(userData,'savingDirectory')
        str = strsplit(userData.savingDirectory,'\')
        fileSuffix = strsplit(str{length(str)},'.')
        if strcmp(fileSuffix{length(fileSuffix)},'mp3')
            saveSoundAs(userData.audioFs,userData.audio);
        else
            saveSound(userData.audioFs,userData.audio);
        end
    else
        saveSoundAs(userData.audioFs,userData.audio);
    end
set(handles.appGui,'userdata',userData);
end

% --- Executes on button press in saveAs.
function saveAs_Callback(hObject, eventdata, handles)
% hObject    handle to saveAs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userData = get(handles.appGui,'userdata')
% if isfield(userData,'audio')
%     saveSoundAs(userData.audioFs,userData.audio);
% end
% --- Executes on selection change in chooseSettings.
function chooseSettings_Callback(hObject, eventdata, handles)
% hObject    handle to chooseSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns chooseSettings contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chooseSettings
userData = get(handles.appGui,'userdata');
settings = get(handles.chooseSettings,'String');
settingsValue = get(handles.chooseSettings,'Value');
userData.selectedSettings = settings{settingsValue};
if strcmp(settings{settingsValue},'Recording')
    setSettings = userData.adrSettings;
    set(handles.driver,'Value',str2double(setSettings{1}));
    set(handles.sampleRate,'String',setSettings{2});
    set(handles.bitDepth,'Value',str2double(setSettings{3}));
elseif strcmp(settings{settingsValue},'Playing')
    setSettings = userData.adwSettings;
    set(handles.driver,'Value',str2double(setSettings{1}));
    set(handles.sampleRate,'String',setSettings{2});
    set(handles.bitDepth,'Value',str2double(setSettings{3}));
elseif strcmp(settings{settingsValue},'Playing/Recording')
    setSettings = userData.aprSettings;
    set(handles.driver,'Value',str2double(setSettings{1}));
    set(handles.sampleRate,'String',setSettings{2});
    set(handles.bitDepth,'Value',str2double(setSettings{3}));
end    
set(handles.appGui,'userdata',userData);

% --- Executes during object creation, after setting all properties.
function chooseSettings_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chooseSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on listOfAudioFiles and none of its controls.
function listOfAudioFiles_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to listOfAudioFiles (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
userData = get(handles.appGui,'userdata');
key = get(gcf,'CurrentKey');
if(strcmp(key,'delete'))
    deleteFromList_Callback(hObject, eventdata, handles);
elseif(strcmp(key,'return'))
    getList = userData.listOfAudios;
    getCurrentValue = get(handles.listOfAudioFiles,'Value');
    openFile(getList{getCurrentValue});
    set(handles.selectionDisplay,'String','');
    setInfo(size(userData.audio,1)/userData.audioFs,...
        userData.audioFs,size(userData.audio,2));
    set(findall(handles.axes),'HitTest','on','ButtonDownFcn',@axes_ButtonDownFcn);
    set(handles.zoomSlider,'enable','on'); 
    set(handles.appGui,'userdata',userData);
end    
 


% --- Executes on button press in new_record.
function new_record_Callback(hObject, eventdata, handles)
% hObject    handle to new_record (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userData = get(handles.appGui,'userdata')
selection = checkSaving();
if selection == 1
    saveSound(userData.audioFs,userData.audio);
    if isfield(userData,'savedAudioData')
        if isequal(userData.audio,userData.savedAudioData)
            cla reset;
            emptyPlot(userData.numOfChannels);
            set(handles.selectionDisplay,'String','');
            set(handles.infoText,'String','');
            set(handles.playTime,'String','');
            set(handles.zoomSlider,'enable','off');
            set(handles.sliderX,'enable','off'); 
            toKeep = {'listOfAudios','displayedAudios','adReader','adWriter',...
                'audioPlayerRecorder','defaultAudio','Fs','numOfChannels',...
                'selectedSettings','recordedSound'};
            f = fieldnames(userData);
            toRemove = f(~ismember(f,toKeep));
            userData = rmfield(userData,[toRemove])
            set(handles.appGui,'userdata',userData);
        end   
    end
elseif selection == 2 || selection == -1
    cla reset;
    emptyPlot(userData.numOfChannels);
    set(handles.selectionDisplay,'String','');
    set(handles.infoText,'String','');
    set(handles.playTime,'String','');
    set(handles.zoomSlider,'enable','off');
    set(handles.sliderX,'enable','off');
    toKeep = {'listOfAudios','displayedAudios','adr','adw',...
        'audioPlayerRecorder','defaultAudio','Fs','numOfChannels',...
        'selectedSettings','recordedSound','settings','defaultSettings',...
        'adwSettings','adrSettings','aprSettings'};
    f = fieldnames(userData);
    toRemove = f(~ismember(f,toKeep));
    userData = rmfield(userData,[toRemove])
    set(handles.appGui,'userdata',userData);
end


% --- Executes on button press in play.
function play_Callback(hObject, eventdata, handles)
% hObject    handle to play (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of play
% 
userData = get(handles.appGui,'userdata');
if isfield(userData,'audio')
    if get(hObject,'Value')
        playingLine = userData.playingLine;
        audio = userData.audio;
        audioFs = userData.audioFs;
        LinePos = ceil(get(playingLine,'XData'));
        audioLength = userData.length;
        channels = [];
        for i = 1:size(audio,2)
            if get(handles.(strcat('channelN',num2str(i))), 'Value') == 0
                audio(:,i) = 0;
            end  
            channels = [channels i];
        end
        if(LinePos(1) == 0)
            beginning = 1;
            timer = 1;
        else
            timer = LinePos(1)+1;
            beginning = LinePos(1)*audioFs;
        end    
        set(handles.play,'String','Pause', 'TooltipString', 'Pause audio file');
        deviceWriter = userData.adw;
        length = size(audio,1);
        step = deviceWriter.BufferSize;
        time = axis;
        for i = beginning:step:length
            LinePos = ceil(get(playingLine,'XData'));
            set(handles.playTime,'String',sprintf('%d / %g s',LinePos(1), round(audioLength*100)/100));
            deviceWriter([audio(i:min((i+step)-1, length),channels)]);
            if(LinePos(1) < time(2) && (i/audioFs) > timer)
                timer = timer + 1;
                set(playingLine,'XData',[LinePos(1)+1 LinePos(2)+1]);
            end
            stop_state = get(hObject, 'Value');
            if ~stop_state
                break; 
            end
            pause(0.09);
        end
        if stop_state
            set(playingLine,'XData',[0 0]);
            set(handles.playTime,'String',sprintf('%d / %g s',0, round(audioLength*100)/100));
        end
        release(deviceWriter);
        set(handles.play,'Value', 0, 'String','Play', 'TooltipString', 'Play audio file or record');
        userData.playingLine = playingLine;  
    end
    set(handles.appGui,'userdata',userData);
else
    msgbox('No record!');
    set(hObject,'Value',false);
end

function closeGUI(hObject, eventdata, handles)
handles = guidata(gcf); 
if get(handles.rec,'Value')
    uiwait(msgbox('Stop recording!'));
elseif get(handles.play,'Value')    
    uiwait(msgbox('Stop playing!'));
else
    selection = checkSaving();
    if selection == 1
        userData = get(handles.appGui,'userdata');
        saveSound(userData.audioFs,userData.audio);
        if isfield(userData,'savedAudioData')
            if isequal(userData.audio,userData.savedAudioData)
                delete(gcf);
            end   
        end
    elseif selection == 2 || selection == -1
        delete(gcf);
    elseif selection == 0
        delete(gcf);
    end
end

% --- Executes when user attempts to close appGui.
function appGui_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to appGui (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(hObject);


% --- Executes on button press in deleteList.
function deleteList_Callback(hObject, eventdata, handles)
% hObject    handle to deleteList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userData = get(handles.appGui,'userdata');
if ~isfield(userData,'listOfAudios')
    msgbox('List is already empty!');
else
    userData = rmfield(userData,{'listOfAudios','displayedAudios'});
    userData.defaultAudio = 0;
    set(handles.appGui,'userdata',userData);
    set(handles.listOfAudioFiles,'Value',1,'String',[]);
end 

% --- Executes on mouse press over axes background.
function axes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gcf);
userData = get(handles.appGui,'userdata');
if isfield(userData,'audio')
    type =  get(gcf, 'selectiontype');
    clickPosition = get(gca, 'currentpoint');
    AxisLim = axis;
    length = userData.length;
    if clickPosition(1) >= 0 && clickPosition(1) < length
        if strcmp(type,'normal')
            if ~get(handles.play,'Value')
                playingLine = userData.playingLine;
                uistack(playingLine, 'top')
                if clickPosition(1) > floor(length)
                    set(playingLine,'XData',[floor(clickPosition(1)) floor(clickPosition(1))]);
                    set(handles.playTime,'String',sprintf('%d / %g s',floor(clickPosition(1)), round(length*100)/100));
                else    
                    set(playingLine,'XData',[clickPosition(1) clickPosition(1)]);
                    set(handles.playTime,'String',sprintf('%d / %g s',round(clickPosition(1)), round(length*100)/100));
                end
                userData.playingLine = playingLine;
                drawnow
            end
        elseif strcmp(type,'alt')
            if ~isfield(userData,'leftBorderLine')
                leftBorderLine = line([clickPosition(1) clickPosition(2)],[AxisLim(3) AxisLim(4)],'color','g',...
                    'LineStyle','-','linewidth',2); 
                uistack(leftBorderLine,'down');
                userData.leftBorderLine = leftBorderLine;
            else
                if ~isfield(userData,'rightBorderLine')
                    rightBorderLine = line([clickPosition(1) clickPosition(2)],[AxisLim(3) AxisLim(4)],'color','g',...
                        'LineStyle','-','linewidth',2); 
                    uistack(rightBorderLine,'down');
                    leftBorderLine = userData.leftBorderLine;
                    lbPosition = get(leftBorderLine,'XData');
                    if clickPosition(1) < lbPosition(1)
                        exchange = leftBorderLine;
                        leftBorderLine = rightBorderLine;
                        rightBorderLine = exchange;
                        userData.leftBorderLine = leftBorderLine;
                    end    
                    lbPosition = get(leftBorderLine,'XData');
                    rbPosition = get(rightBorderLine,'XData');
                    userData.rightBorderLine = rightBorderLine;
                    selectedPart = patch([lbPosition(1) lbPosition(2) rbPosition(1) rbPosition(2)],...
                        [AxisLim(3) AxisLim(4) AxisLim(4) AxisLim(3)],'k',...
                        'facecolor','g','edgecolor','none','facealpha',.2) ;
                    set(handles.selectionDisplay,'String',...
                        sprintf('%f - %f',lbPosition(1),rbPosition(1)));
                    set(selectedPart,'ButtonDownFcn',@axes_ButtonDownFcn); 
                    userData.selectedPart = selectedPart;
                else
                    selectedPart = userData.selectedPart;
                    leftBorderLine = userData.leftBorderLine;
                    rightBorderLine = userData.rightBorderLine;
                    lbPosition = get(leftBorderLine,'XData');
                    rbPosition = get(rightBorderLine,'XData');
                    middleNum = (rbPosition(1) + lbPosition(1))/2;
                    if clickPosition(1) < lbPosition(1)
                        set(leftBorderLine,'XData',[clickPosition(1) clickPosition(2)]);
                        set(selectedPart,'XData',[clickPosition(1) clickPosition(2) rbPosition(1) rbPosition(2)],...
                            'YData',[AxisLim(3) AxisLim(4) AxisLim(4) AxisLim(3)]);
                        userData.leftBorderLine = leftBorderLine;
                        userData.selectedPart = selectedPart;
                        set(handles.selectionDisplay,'String',...
                        sprintf('%f - %f',clickPosition(1),rbPosition(1)));
                        drawnow
                    elseif clickPosition(1) > rbPosition(1)
                        set(rightBorderLine,'XData',[clickPosition(1) clickPosition(2)]);
                        set(selectedPart,'XData',[lbPosition(1) lbPosition(2) clickPosition(1) clickPosition(2)],...
                            'YData',[AxisLim(3) AxisLim(4) AxisLim(4) AxisLim(3)]);
                        userData.rightBorderLine = rightBorderLine;
                        userData.selectedPart = selectedPart;
                        set(handles.selectionDisplay,'String',...
                        sprintf('%f - %f',lbPosition(1),clickPosition(1)));
                        drawnow
                    elseif clickPosition(1) > lbPosition(1) && clickPosition(1) < middleNum
                        set(leftBorderLine,'XData',[clickPosition(1) clickPosition(2)]);
                        set(selectedPart,'XData',[clickPosition(1) clickPosition(2) rbPosition(1) rbPosition(2)],...
                            'YData',[AxisLim(3) AxisLim(4) AxisLim(4) AxisLim(3)]);
                        userData.leftBorderLine = leftBorderLine;
                        userData.selectedPart = selectedPart;
                        set(handles.selectionDisplay,'String',...
                        sprintf('%f - %f',clickPosition(1),rbPosition(1)));
                        drawnow
                    elseif clickPosition(1) < rbPosition(1) && clickPosition(1) > middleNum
                        set(rightBorderLine,'XData',[clickPosition(1) clickPosition(2)]);
                        set(selectedPart,'XData',[lbPosition(1) lbPosition(1) clickPosition(1) clickPosition(2)],...
                            'YData',[AxisLim(3) AxisLim(4) AxisLim(4) AxisLim(3)]);
                        userData.rightBorderLine = rightBorderLine;
                        userData.selectedPart = selectedPart;
                        set(handles.selectionDisplay,'String',...
                        sprintf('%f - %f',lbPosition(1),clickPosition(1)));
                        drawnow
                    end
                end
            end
        elseif strcmp(type,'extend')
            if isfield(userData,'leftBorderLine') && ~isfield(userData,'rightBorderLine')
                delete(userData.leftBorderLine);
                userData = rmfield(userData,'leftBorderLine');
            elseif isfield(userData,'leftBorderLine') && isfield(userData,'rightBorderLine')
                delete(userData.selectedPart);
                delete(userData.leftBorderLine);
                delete(userData.rightBorderLine);
                userData = rmfield(userData,{'selectedPart','leftBorderLine',...
                    'rightBorderLine'});
                set(handles.selectionDisplay,'String','');
            else
                shift = (AxisLim(2)-AxisLim(1))/10;
                leftBorderLine = line([clickPosition(1)-shift clickPosition(2)-shift],...
                    [AxisLim(3) AxisLim(4)],'color','g',...
                        'LineStyle','-','linewidth',2); 
                uistack(leftBorderLine,'down');
                rightBorderLine = line([clickPosition(1)+shift clickPosition(2)+shift],...
                    [AxisLim(3) AxisLim(4)],'color','g',...
                        'LineStyle','-','linewidth',2);     
                uistack(rightBorderLine,'down');
                selectedPart = patch([clickPosition(1)-shift clickPosition(2)-shift clickPosition(1)+shift clickPosition(2)+shift],...
                    [AxisLim(3) AxisLim(4) AxisLim(4) AxisLim(3)],'k',...
                        'facecolor','g','edgecolor','none','facealpha',.2);
                set(handles.selectionDisplay,'String',...
                        sprintf('%f - %f',clickPosition(1)-shift,clickPosition(1)+shift));    
                set(selectedPart,'ButtonDownFcn',@axes_ButtonDownFcn);
                userData.selectedPart = selectedPart;
                userData.leftBorderLine = leftBorderLine;
                userData.rightBorderLine = rightBorderLine;
            end
        end
        set(handles.appGui,'userdata',userData);
    end
end
% --- Executes on button press in openSelection.
function openSelection_Callback(hObject, eventdata, handles)
% hObject    handle to openSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userData = get(handles.appGui,'userdata');
if isfield(userData,'audio')
    if ~get(handles.play,'Value')
        if isfield(userData,'selectedPart')
            selectedPart = userData.selectedPart.XData;
            audio = userData.audio;
            audioFs = userData.audioFs;
            if isfield(userData,'savingExíst')
                if isequal(audio,userData.savedAudioData)
                    openingSelection(audio,audioFs,selectedPart);
                else        
                    selection = checkSaving();
                    if selection == 1
                        saveSound(audioFs,audio);
                        if isfield(userData,'savedAudioData')
                            openingSelection(audio,audioFs,selectedPart);
                        end
                    elseif selection == -1 || selection == 0 || selection == 2
                        openingSelection(audio,audioFs,selectedPart);
                    end
                end
            else
                selection = checkSaving();
                if selection == 1
                    saveSound(audioFs,audio);
                    if isfield(userData,'savedAudioData')
                        openingSelection(audio,audioFs,selectedPart);
                    end
                elseif selection == -1 || selection == 0 || selection == 2
                    openingSelection(audio,audioFs,selectedPart);
                end
            end
        else
            msgbox('No selection!');
        end
    end
else
    msgbox('No record!');
end
% --- Executes on button press in saveSelection.
function saveSelection_Callback(hObject, eventdata, handles)
% hObject    handle to saveSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userData = get(handles.appGui,'userdata');
if isfield(userData,'audio')
    if isfield(userData,'selectedPart')
        lbPosition = userData.leftBorderLine.XData;
        rbPosition = userData.rightBorderLine.XData;
        audio = userData.audio;
        [nfname,path]=uiputfile('.wav','Save sound','new_sound');
        if isequal(nfname,0) || isequal(path,0)
            return
        else
            selectedPart = audio((lbPosition(1)*userData.audioFs):(rbPosition(1)*userData.audioFs),:);
            wavFile = fullfile(path, nfname);
            afw = dsp.AudioFileWriter(wavFile,'SampleRate', userData.audioFs);
            afw(selectedPart);
            release(afw);
            msgbox('Selected part was successfully saved!');
        end
    end
else
    msgbox('No record!');
end

% --- Executes on button press in closeSelect.
function closeSelect_Callback(hObject, eventdata, handles)
% hObject    handle to closeSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userData = get(handles.appGui,'userdata');
if isfield(userData,'audio')
    if isfield(userData,'leftBorderLine') && ~isfield(userData,'rightBorderLine')
        delete(userData.leftBorderLine);
        userData = rmfield(userData,'leftBorderLine');
    elseif isfield(userData,'leftBorderLine') && isfield(userData,'rightBorderLine')
        delete(userData.selectedPart);
        delete(userData.leftBorderLine);
        delete(userData.rightBorderLine);
        userData = rmfield(userData,{'selectedPart','leftBorderLine','rightBorderLine'});
        set(handles.selectionDisplay,'String','');
    else
        msgbox('Nothing is selected!');
    end
    set(handles.appGui,'userdata',userData);
end

% --- Executes on button press in zoomInSelection.
function zoomInSelection_Callback(hObject, eventdata, handles)
% hObject    handle to zoomInSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userData = get(handles.appGui,'userdata');
if isfield(userData,'audio')
    if isfield(userData,'selectedPart')
        selectedPosition = get(userData.selectedPart,'XData');
        xlim([selectedPosition(1) selectedPosition(3)])
    else
        msgbox('No Selection!');
    end
else
    msgbox('No Audio!');
end
% --- Executes on button press in zoomOutSelection.
function zoomOutSelection_Callback(hObject, eventdata, handles)
% hObject    handle to zoomOutSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userData = get(handles.appGui,'userdata');
if isfield(userData,'audio')
    if isfield(userData,'selectedPart')
        length = userData.length;
        zooming = get(handles.zoomSlider,'Value');
        xlim([0 length/zooming])
    else
        msgbox('No selection!');
    end
else
    msgbox('No audio!');
end

% --- Executes on slider movement.
function zoomSlider_Callback(hObject, eventdata, handles)
% hObject    handle to zoomSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
userData = get(handles.appGui,'userdata');
if isfield(userData,'audio')
    zooming = get(hObject,'Value')
    length = userData.length;
    if zooming == 1
        set(handles.sliderX,'enable','off');
        xlim([0 length])
        userData.zooming = zooming;
    else
        xlim([0 length/zooming])
        set(handles.sliderX,'min',0,'max',length - (length/zooming),...
            'Value',0,'enable','on');
        userData.zooming = zooming;
    end
    set(handles.appGui,'userdata',userData);
end

 
% --- Executes during object creation, after setting all properties.
function zoomSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zoomSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in cut.
function cut_Callback(hObject, eventdata, handles)
% hObject    handle to cut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userData = get(handles.appGui,'userdata');
if isfield(userData,'audio')
    if ~get(handles.play,'Value')
        if isfield(userData,'selectedPart')
            selectedPart = userData.selectedPart.XData;
            audio = userData.audio;
            audioFs = userData.audioFs;
            zooming = userData.zooming;
            audio((selectedPart(1)*audioFs):(selectedPart(3)*audioFs),:) = [];
            length = size(audio,1)/audioFs;
            delete(userData.selectedPart);
            delete(userData.leftBorderLine);
            delete(userData.rightBorderLine);
            userData = rmfield(userData,{'selectedPart','leftBorderLine',...
                'rightBorderLine'});
            userData.audio = audio;
            userData.length = length;
            plotSound(audio,audioFs);
            AxisLim = axis;
            xlim([0 length/zooming]);
            playingLine = line([AxisLim(1) AxisLim(1)],[AxisLim(3) AxisLim(4)],'color','b',...
                'Marker','*','MarkerEdgeColor','b','LineStyle','-','linewidth',2);
            userData.playingLine = playingLine;
            set(handles.appGui,'userdata',userData);
            if zooming ~= 1
                set(handles.sliderX,'min',0,'max',length - (length/zooming),...
                    'Value',0,'enable','on');
            end
            setInfo(length,audioFs,userData.numOfChannels);
            set(handles.selectionDisplay,'String','');
            set(handles.playTime,'String',sprintf('%d / %g s',0, round(length*100)/100));
            set(findall(handles.axes),'HitTest','on','ButtonDownFcn',@axes_ButtonDownFcn);
            msgbox('Selected part was successfully cut!');
        else
            msgbox('No selection!');
        end
    end
else
    msgbox('No record!');
end


function turnButtons(option, button)
handles = guidata(gcf); 
userData = get(handles.appGui,'userdata');
numOfChannels = userData.numOfChannels;
if strcmp(button,'rec')
    set(handles.play,'enable',option);
    set(handles.stop_button,'enable',option);
    for i = 1:numOfChannels
        set(handles.(strcat('channelN',num2str(i))), 'enable', option);
    end   
elseif strcmp(button,'play')
    set(handles.rec,'enable',option);
end
set(handles.previousTrack,'enable',option);
set(handles.nextTrack,'enable',option);
set(handles.new_record ,'enable',option);
set(handles.open_file,'enable',option);
set(handles.save,'enable',option);
set(handles.saveAs,'enable',option);
set(handles.addToList,'enable',option);
set(handles.deleteFromList,'enable',option);
set(handles.deleteList,'enable',option);
set(handles.listOfAudioFiles,'enable',option);
set(handles.chooseSettings,'enable',option);
set(handles.driver,'enable',option);
set(handles.sampleRate,'enable',option);
set(handles.bitDepth,'enable',option);
set(handles.cut,'enable',option);
set(handles.openSelection,'enable',option);
set(handles.saveSelection,'enable',option);
set(handles.closeSelect,'enable',option);
set(handles.addChannel,'enable',option);
set(handles.deleteChannel,'enable',option);
set(handles.zoomInSelection,'enable',option);
set(handles.zoomOutSelection,'enable',option);

function setInfo(length,Fs,numOfChannels)
handles = guidata(gcf); 
text = '';
text = sprintf('%sLength: %g s\n',text, round(length*100)/100);
text = sprintf('%sSampling: %d Hz\n',text, Fs);
text = sprintf('%sChannels: %d\n',text, numOfChannels);
set(handles.infoText,'String',text);

function openingSelection(audio,audioFs,selectedPart)
handles = guidata(gcf); 
userData = get(handles.appGui,'userdata');
audio = audio((selectedPart(1)*audioFs):(selectedPart(3)*audioFs),:);
cla;
plotSound(audio,audioFs);
length = size(audio,1)/audioFs;
delete(userData.selectedPart);
delete(userData.leftBorderLine);
delete(userData.rightBorderLine);
userData = rmfield(userData,{'selectedPart','leftBorderLine','savingDirectory',...
    'savedAudioData'});
userData.audio = audio;
userData.length = length;
setInfo(length,audioFs,size(audio,2));  
AxisLim = axis;
playingLine = line([AxisLim(1) AxisLim(1)],[AxisLim(3) AxisLim(4)],'color','b',...
        'Marker','*','MarkerEdgeColor','b','LineStyle','-','linewidth',2); 
userData.playingLine = playingLine;
set(handles.zoomSlider,'Value',1);
set(handles.playTime,'String',sprintf('%d / %g s',0, round(length*100)/100));
set(handles.selectionDisplay,'String','');
set(handles.appGui,'userdata',userData);
set(findall(handles.axes),'HitTest','on','ButtonDownFcn',@axes_ButtonDownFcn);


% --- Executes on button press in playrec.
function playrec_Callback(hObject, eventdata, handles)
% hObject    handle to playrec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of playrec


% --- Executes on key press with focus on appGui or any of its controls.
function appGui_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to appGui (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
key = get(gcf,'CurrentKey');
if(strcmp(key,'space'))
    uicontrol(handles.play);
end    

% --- Executes on button press in saveToWorkspace.
function saveToWorkspace_Callback(hObject, eventdata, handles)
% hObject    handle to saveToWorkspace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userData = get(handles.appGui,'userdata');
if isfield(userData,'audio')
    if isfield(userData,'selectedPart')
        prompt={'Name selection:'};
        name = 'Save';
        defaultName = {''};
        answer = newid(prompt,name,[1 40],defaultName);
        if isempty(answer)
            button = questdlg('Are you sure you want to close?','Exit Saving','Yes','No','No');
            switch button
                case 'Yes'
                    return
                otherwise
                    saveToWorkspace_Callback(hObject, eventdata, handles);
            end
        end           
        lbPosition = userData.leftBorderLine.XData;
        rbPosition = userData.rightBorderLine.XData;
        audio = userData.audio;
        assignin('base','answer',...
            audio((lbPosition(1)*userData.audioFs):(rbPosition(1)*userData.audioFs),:));
        else
        msgbox('No selection!');
    end
else
    msgbox('No record!');
end




