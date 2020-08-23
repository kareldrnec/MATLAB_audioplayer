function [] = plotSound(x,Fs)
cla;
t=0:1/Fs:(length(x)-1)/Fs;
if(size(x,2) == 1)
    plot(t,x(:,1));
    ylim([-1 1])  
else
    zline = zeros(size(x,1),1);
    shift = size(x,2)*2;
    plot(t,x(:,1)+(shift-1));
    hold on
    for i = 2:size(x,2)
       shift = shift - 2; 
       plot(t,zline+shift,'k');
       plot(t,x(:,i)+(shift-1));
    end 
    %ylim([0 2])
    hold off
end
xlim([0 size(x,1)/Fs])
set(gca, 'YTick', []); 
end

