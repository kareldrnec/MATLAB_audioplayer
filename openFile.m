function [] = openFile(fullPath)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
[audio, fs] = audioread(fullPath);
cla;
plotSound(audio,fs);
handles = guidata(gcf);
userData = get(handles.appGui,'userdata');
AxisLim = axis;
userData.playingLine = line([AxisLim(1) AxisLim(1)],[AxisLim(3) AxisLim(4)],'color','b',...
        'Marker','*','MarkerEdgeColor','b','LineStyle','-','linewidth',2); 
userData.audio = audio;
userData.savedAudioData = audio;
if size(audio,2) > userData.numOfChannels
    for i = (userData.numOfChannels+1):size(audio,2)
        set(handles.(strcat('channelN',num2str(i))),'Value',1,...
          'enable','on');
    end
elseif size(audio,2) < userData.numOfChannels
    for i = (size(audio,2)+1):userData.numOfChannels
        set(handles.(strcat('channelN',num2str(i))),'Value',0,...
            'enable','off');
    end    
end
userData.recordedSound = zeros(1024,size(audio,2));
userData.numOfChannels = size(audio,2);
userData.savingDirectory = fullPath;
userData.audioFs = fs;
userData.length = size(audio,1)/fs;
userData.zooming = 1;
if(size(audio,2) == 1 || size(audio,2))
    set(handles.sliderY,'enable','off');
else
    ylim([size(audio,2)*2-4 size(audio,2)*2])
    set(handles.sliderY, 'min', -size(audio,2),'max',0,'Value',0);
end  
if size(audio,1)/fs > 100
    set(handles.zoomSlider,'max',100,'enable','on','Value',1);
else
    set(handles.zoomSlider,'max',10,'enable','on','Value',1);
end
set(handles.sliderX,'enable','off');
set(handles.appGui,'userdata',userData);
end
