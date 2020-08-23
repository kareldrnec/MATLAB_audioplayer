function [] = saveSoundAs(Fs,audio)
[nfname,path]=uiputfile('.wav','Save sound','new_sound');
if isequal(nfname,0) || isequal(path,0)
    return
else
    handles = guidata(gcf);
    userData = get(handles.appGui,'userdata');
    wavFile = fullfile(path, nfname);
    afw = dsp.AudioFileWriter...
        (wavFile, ...
        'SampleRate', Fs);
    afw(audio);
    release(afw);
    userData.savingDirectory = wavFile;
    userData.savedAudioData = audio;
    userData.y = 4;
    set(handles.appGui,'userdata',userData);
end
end
