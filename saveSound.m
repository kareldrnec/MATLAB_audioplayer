function [] = saveSound(Fs, audio)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
handles = guidata(gcf);
userData = get(handles.appGui,'userdata');
if isfield(userData,'savingDirectory')
    if ~isequal(audio,userData.savedAudioData)
        afw = dsp.AudioFileWriter(userData.savingDirectory,'SampleRate', Fs);
        afw(audio);
        release(afw);
        userData.savedAudioData = audio;
        set(handles.appGui,'userdata',userData);
    end
else
    saveSoundAs(Fs,audio);
end    
set(handles.appGui,'userdata',userData);
end

