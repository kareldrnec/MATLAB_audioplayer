function [selection] = checkSaving()
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
selection = -1;
handles = guidata(gcf);
userData = get(handles.appGui,'userdata');
if isfield(userData,'savingDirectory')
    if ~isequal(userData.audio,userData.savedAudioData)
        answer = questdlg('Do you want to save changes in record?',...
        'Warning','Yes','No','Storno','Yes');
        switch answer
            case 'Yes'
                selection = 1;
            case 'No'
                selection = 2;
            otherwise
                selection = 3;
                return
        end    
    end    
else
    if isfield(userData,'audio')
        answer = questdlg('Do you want to save record?',...
            'Warning', 'Yes','No','Storno','Yes');
        switch answer
            case 'Yes'
                selection = 1;
            case 'No'
                selection = 2;
            otherwise
                selection = 3;
                return
        end
    else
        selection = 0;
    end
end
end

