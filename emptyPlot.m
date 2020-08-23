function [] = emptyPlot(x)
zLine = zeros(2,1);
if(x ~= 1)
    shift = x*2;
    hold on 
    for i = 1:x-1
        shift = shift - 2;
        plot(zLine+shift,'k');
    end
    hold off
end
set(gca, 'XTick', []);
set(gca, 'YTick', []);
end
