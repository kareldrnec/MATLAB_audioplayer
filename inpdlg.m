function [y] = inpdlg()
prompt={'Enter number of channels (1-8)'};
name = 'Settings';
defaultnum = {'1'};
answer = newid(prompt,name,[1 40],defaultnum);
if isempty(answer)
        button = questdlg('Are you sure you want to close?','Exit Dialog','Yes','No','No');
        switch button
            case 'Yes'
                y = 0;
            otherwise
                y = -1;
        end
else
    if isnan(str2double(answer))
        uiwait(msgbox('Wrong value! Enter integer in range 1-8.', 'Error','error','modal'));
        y = -1;
    else
        x = str2double(answer);
        if ~((x > 0) && (x <= 8) && (x == floor(x)))
            uiwait(msgbox('Wrong value! Enter integer in range 1-8.', 'Error','error','modal'));
            y = -1;
        else
            y = x;
        end   
    end
end
end