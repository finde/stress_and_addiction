function plot_ecg_waveform(ecgData, range)

    Fs = 1000;
    tm = 0:1/Fs:(length(ecgData)-1)/Fs;
    
if nargin > 1
    plot(tm(1:range), ecgData(1:range))
else
    plot(tm, ecgData)
end 

    xlabel('[s]');
%     ylim([-1000,1000]);
end